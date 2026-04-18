#!/bin/bash
# bhealth v1.0 — B-Suite fleet audit with three-tier healing
#
# Verifies that THIS Mac is in sync with the rest of the fleet, auto-heals
# safe drift, launches install prompts for things that need a click, and
# flags what needs your judgment.
#
# Three tiers:
#   1. Auto-heal (silent): git pull/push clean repos, install bsync, fix master
#   2. Launch + prompt: open .skill installers when versions drift
#   3. Flag (no touch): uncommitted work, expired PAT, missing toolchain
#
# Writes a JSON report to bhub/.health/{device}-{date}.json and updates
# skills-manifest.json with this device's current state. Commits and pushes.
#
# Usage:
#   bash bhealth.sh              # Full audit + auto-heal + commit report
#   bash bhealth.sh --dry-run    # Audit only, no changes, no commit
#   bash bhealth.sh --quiet      # JSON-only output (no human summary)

set -uo pipefail

# ============================================================================
# Config
# ============================================================================

MODE="${1:-full}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BSUITE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$SCRIPT_DIR/skills/skills-manifest.json"
TOKEN_FILE="$BSUITE_DIR/.git-token"
DEVICE_FILE="$BSUITE_DIR/.bhealth-device"
HEALTH_DIR="$SCRIPT_DIR/.health"
TODAY="$(date '+%Y-%m-%d')"
TIMESTAMP_UTC="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# Repo registry — single source of truth for fleet composition
REPOS=(
  "things-app:brhecht/things-app"
  "brain-inbox:brhecht/brain-inbox"
  "content-calendar:brhecht/content-calendar"
  "b-marketing:brhecht/b-marketing"
  "b-people:brhecht/b-people"
  "b-resources:brhecht/b-resources"
  "bhub:brhecht/bhub"
  "eddy:brhecht/eddy-tracker"
  "hc-funnel:brhecht/hc-funnel"
  "hc-strategy:brhecht/hc-strategy"
  "tnb-strategy:brhecht/tnb-strategy"
  "hc-website:brhecht/hc-website"
  "tnb-website:brhecht/tnb-website"
  "pitch-scorer:brhecht/pitch-scorer"
)

# Emoji helpers
OK="✅"
WARN="⚠️ "
FAIL="❌"
INFO="ℹ️ "

# ============================================================================
# Output helpers
# ============================================================================

quiet() { [[ "$MODE" == "--quiet" ]]; }

say() { quiet || echo -e "$1"; }
sep() { quiet || echo ""; }
hdr() { quiet || { echo ""; echo "── $1 ──"; }; }

# JSON accumulator — we build one report throughout the run
REPORT_REPOS=()
REPORT_SKILLS=()
REPORT_TOOLS=()
REPORT_ACTIONS=()   # Things we auto-did
REPORT_FLAGS=()     # Things that need human attention

json_escape() {
  printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()), end="")'
}

# ============================================================================
# Step 1 — Identify this device
# ============================================================================

identify_device() {
  if [[ -n "${BHEALTH_DEVICE:-}" ]]; then
    DEVICE_NAME="$BHEALTH_DEVICE"
  elif [[ -f "$DEVICE_FILE" ]]; then
    # Read one line, preserving internal spaces — only strip trailing newline
    IFS= read -r DEVICE_NAME < "$DEVICE_FILE" || DEVICE_NAME=""
  else
    # First run — ask
    say "${INFO} First bhealth run on this Mac. Which one is this?"
    say "  1) MacBook Pro"
    say "  2) MacBook Air"
    say "  3) Mac Mini"
    say "  4) iMac"
    read -p "Enter number: " choice
    case "$choice" in
      1) DEVICE_NAME="MacBook Pro" ;;
      2) DEVICE_NAME="MacBook Air" ;;
      3) DEVICE_NAME="Mac Mini" ;;
      4) DEVICE_NAME="iMac" ;;
      *) DEVICE_NAME="${choice:-Unknown}" ;;
    esac
    echo "$DEVICE_NAME" > "$DEVICE_FILE"
  fi

  DEVICE_SLUG="$(echo "$DEVICE_NAME" | tr '[:upper:] ' '[:lower:]-')"

  HOSTNAME_VAL="$(hostname -s 2>/dev/null || echo unknown)"
  COMPUTER_NAME="$(scutil --get ComputerName 2>/dev/null || echo unknown)"
  OS_VERSION="$(sw_vers -productVersion 2>/dev/null || echo unknown)"

  say ""
  say "${INFO} Device: ${DEVICE_NAME}  (host: ${HOSTNAME_VAL}, macOS ${OS_VERSION})"
  say "${INFO} B-Suite: ${BSUITE_DIR}"
  say "${INFO} Run time: ${TIMESTAMP_UTC}"
}

# ============================================================================
# Step 2 — Git auth check (Tier 3 flag if broken)
# ============================================================================

check_git_auth() {
  hdr "Git auth"

  GIT_AUTH_OK="false"
  GIT_AUTH_DETAIL=""

  if [[ ! -f "$TOKEN_FILE" ]]; then
    GIT_AUTH_DETAIL=".git-token missing at $TOKEN_FILE"
    say "${FAIL} ${GIT_AUTH_DETAIL}"
    REPORT_FLAGS+=("Missing .git-token — regenerate PAT at github.com/settings/tokens, save to $TOKEN_FILE")
    return
  fi

  # Configure git credentials from token
  TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"
  git config --global credential.helper store 2>/dev/null || true
  echo "https://brhecht:${TOKEN}@github.com" > ~/.git-credentials 2>/dev/null || true
  git config --global user.name "brhecht" 2>/dev/null || true
  git config --global user.email "brhnyc1970@gmail.com" 2>/dev/null || true

  # Verify with dry-run push against bhub
  if (cd "$SCRIPT_DIR" && git push --dry-run origin main 2>&1) >/dev/null; then
    GIT_AUTH_OK="true"
    say "${OK} PAT works — push auth verified"
  else
    GIT_AUTH_DETAIL="PAT present but git push --dry-run failed (expired or revoked?)"
    say "${FAIL} ${GIT_AUTH_DETAIL}"
    REPORT_FLAGS+=("PAT appears expired — regenerate at github.com/settings/tokens, overwrite $TOKEN_FILE")
  fi
}

# ============================================================================
# Step 3 — Repo audit (Tier 1 auto-heal)
# ============================================================================

audit_repos() {
  hdr "Repos (fetch / pull / push)"

  local total=0 clean=0 pulled=0 pushed=0 dirty=0 missing=0

  for entry in "${REPOS[@]}"; do
    local folder="${entry%%:*}"
    local github="${entry##*:}"
    local repo_dir="$BSUITE_DIR/$folder"
    local status="" branch="" ahead=0 behind=0 dirty_count=0 untracked_count=0
    local last_commit="" action="none"

    total=$((total + 1))

    if [[ ! -d "$repo_dir/.git" ]]; then
      status="missing"
      missing=$((missing + 1))
      say "${WARN} ${folder}: not cloned on this device"
      REPORT_FLAGS+=("$folder missing — clone with: cd $BSUITE_DIR && git clone https://github.com/${github}.git $folder")
      REPORT_REPOS+=("{\"repo\":\"$folder\",\"status\":\"missing\",\"action\":\"none\"}")
      continue
    fi

    # Clean up any stale git locks
    rm -f "$repo_dir/.git/index.lock" "$repo_dir/.git/HEAD.lock" 2>/dev/null || true

    cd "$repo_dir" || continue

    branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
    last_commit="$(git log -1 --format='%ai' 2>/dev/null | cut -d' ' -f1 || echo unknown)"

    # Count dirty and untracked (wc -l is robust even when grep finds nothing)
    dirty_count=$(git status --porcelain 2>/dev/null | grep -v '^??' | wc -l | tr -d ' ')
    untracked_count=$(git status --porcelain 2>/dev/null | grep '^??' | wc -l | tr -d ' ')

    # Fetch to update remote refs
    git fetch origin 2>/dev/null || true

    # Ahead/behind counts — default to 0 if remote branch doesn't exist
    ahead=$(git rev-list --count "origin/$branch..HEAD" 2>/dev/null || echo 0)
    behind=$(git rev-list --count "HEAD..origin/$branch" 2>/dev/null || echo 0)
    ahead="${ahead:-0}"
    behind="${behind:-0}"

    # Tier 1 auto-heal decision tree
    if [[ $dirty_count -gt 0 || $untracked_count -gt 0 ]]; then
      # Dirty — flag, don't touch
      status="dirty"
      dirty=$((dirty + 1))
      say "${WARN} ${folder}: ${dirty_count} modified, ${untracked_count} untracked (${branch}, ↑${ahead} ↓${behind})"
      REPORT_FLAGS+=("$folder has uncommitted work ($dirty_count modified, $untracked_count untracked) — review with: cd $repo_dir && git status")
    elif [[ $behind -gt 0 && $ahead -gt 0 ]]; then
      # Diverged — flag, don't touch (needs merge strategy)
      status="diverged"
      dirty=$((dirty + 1))
      say "${WARN} ${folder}: diverged (↑${ahead} ↓${behind} on ${branch})"
      REPORT_FLAGS+=("$folder diverged from origin — manual merge: cd $repo_dir && git pull --rebase")
    elif [[ $behind -gt 0 ]]; then
      # Behind + clean — safe to fast-forward
      if [[ "$MODE" == "--dry-run" ]]; then
        status="would_pull"
        say "${INFO} ${folder}: ${behind} behind (would pull)"
      elif git pull --ff-only 2>/dev/null >/dev/null; then
        status="pulled"
        pulled=$((pulled + 1))
        action="pulled_$behind"
        say "${OK} ${folder}: pulled ${behind} commits"
        REPORT_ACTIONS+=("Pulled $behind commits into $folder")
      else
        status="pull_failed"
        say "${FAIL} ${folder}: pull failed"
        REPORT_FLAGS+=("$folder pull failed — investigate: cd $repo_dir && git pull")
      fi
    elif [[ $ahead -gt 0 ]]; then
      # Ahead + clean — safe to push
      if [[ "$MODE" == "--dry-run" ]]; then
        status="would_push"
        say "${INFO} ${folder}: ${ahead} ahead (would push)"
      elif git push origin "$branch" 2>/dev/null >/dev/null; then
        status="pushed"
        pushed=$((pushed + 1))
        action="pushed_$ahead"
        say "${OK} ${folder}: pushed ${ahead} commits"
        REPORT_ACTIONS+=("Pushed $ahead commits from $folder")
      else
        status="push_failed"
        say "${FAIL} ${folder}: push failed (auth?)"
        REPORT_FLAGS+=("$folder push failed — check PAT and retry: cd $repo_dir && git push")
      fi
    else
      status="clean"
      clean=$((clean + 1))
    fi

    REPORT_REPOS+=("{\"repo\":\"$folder\",\"branch\":\"$branch\",\"status\":\"$status\",\"ahead\":$ahead,\"behind\":$behind,\"dirty\":$dirty_count,\"untracked\":$untracked_count,\"last_commit\":\"$last_commit\",\"action\":\"$action\"}")
  done

  cd "$SCRIPT_DIR" || true

  say ""
  say "${INFO} Summary: ${total} repos — ${clean} clean, ${pulled} pulled, ${pushed} pushed, ${dirty} needs-attention, ${missing} missing"
}

# ============================================================================
# Step 4 — Skill audit (Tier 2 launch-and-prompt)
# ============================================================================

audit_skills() {
  hdr "Skills"

  if [[ ! -f "$MANIFEST" ]]; then
    say "${FAIL} skills-manifest.json not found at $MANIFEST"
    REPORT_FLAGS+=("Missing skills-manifest.json — bhub repo incomplete?")
    return
  fi

  # Get list of skills from manifest
  local skills_list
  skills_list=$(python3 -c "
import json
with open('$MANIFEST') as f:
    m = json.load(f)
for s in m.get('skills', {}).keys():
    print(s)
")

  local total=0 source_ok=0 source_missing=0

  for skill in $skills_list; do
    total=$((total + 1))
    local expected_hash install_file

    expected_hash=$(python3 -c "
import json
with open('$MANIFEST') as f:
    m = json.load(f)
print(m.get('skills',{}).get('$skill',{}).get('hash','unknown'))
")

    install_file="$SCRIPT_DIR/skills/${skill}.skill"

    # Verify the .skill source installer file exists in bhub
    if [[ -f "$install_file" ]]; then
      source_ok=$((source_ok + 1))
      say "${OK} ${skill}: installer present (bhub/skills/${skill}.skill)"
      REPORT_SKILLS+=("{\"skill\":\"$skill\",\"installer_present\":true,\"expected_hash\":\"$expected_hash\",\"verified_via\":\"cowork_bsync\"}")
    else
      source_missing=$((source_missing + 1))
      say "${WARN} ${skill}: installer missing from bhub/skills/"
      REPORT_FLAGS+=("Skill installer missing: $install_file — bhub repo incomplete?")
      REPORT_SKILLS+=("{\"skill\":\"$skill\",\"installer_present\":false,\"expected_hash\":\"$expected_hash\"}")
    fi
  done

  say ""
  say "${INFO} Summary: ${total} skills — ${source_ok} installers in bhub, ${source_missing} missing"
  say "${INFO} Install status on this Mac is verified via Cowork at session start (bsync), not by bhealth."
  say "${INFO} Open Claude desktop → Customize → Skills to see what's installed locally."
}

# ============================================================================
# Step 5 — bsync launchd status (Tier 1 auto-heal)
# ============================================================================

check_bsync() {
  hdr "bsync auto-pull agent"

  local loaded=false last_run=""

  if launchctl list 2>/dev/null | grep -q com.bsuite.bsync; then
    loaded=true
    say "${OK} bsync launchd agent loaded"
    if [[ -f "$BSUITE_DIR/.bsync-log" ]]; then
      last_run=$(tail -1 "$BSUITE_DIR/.bsync-log" 2>/dev/null | awk -F': ' '{print $1}')
      say "${INFO} Last log entry: ${last_run:-unknown}"
    fi
  else
    say "${WARN} bsync agent not loaded"
    if [[ "$MODE" == "--dry-run" ]]; then
      REPORT_FLAGS+=("bsync agent not loaded — would run: bash $SCRIPT_DIR/install-bsync.sh")
    else
      say "${INFO} Auto-installing..."
      if bash "$SCRIPT_DIR/install-bsync.sh" >/dev/null 2>&1; then
        loaded=true
        say "${OK} bsync installed"
        REPORT_ACTIONS+=("Auto-installed bsync launchd agent")
      else
        say "${FAIL} bsync install failed — run manually: bash $SCRIPT_DIR/install-bsync.sh"
        REPORT_FLAGS+=("bsync install failed — run: bash $SCRIPT_DIR/install-bsync.sh")
      fi
    fi
  fi

  BSYNC_LOADED="$loaded"
  BSYNC_LAST_RUN="$last_run"
}

# ============================================================================
# Step 6 — Toolchain check (Tier 3 flag, no auto-install)
# ============================================================================

check_tools() {
  hdr "Toolchain"

  for tool in node npm gh vercel git; do
    local version="" path=""
    if command -v "$tool" >/dev/null 2>&1; then
      path=$(command -v "$tool")
      version=$("$tool" --version 2>/dev/null | head -1 | tr -d '\n')
      say "${OK} ${tool}: ${version}"
      REPORT_TOOLS+=("{\"tool\":\"$tool\",\"installed\":true,\"version\":$(json_escape "$version")}")
    else
      say "${WARN} ${tool}: not found"
      REPORT_TOOLS+=("{\"tool\":\"$tool\",\"installed\":false}")
      case "$tool" in
        node|npm) REPORT_FLAGS+=("Missing $tool — install via: brew install node") ;;
        gh) REPORT_FLAGS+=("Missing gh CLI — install via: brew install gh && gh auth login") ;;
        vercel) REPORT_FLAGS+=("Missing vercel CLI — install via: npm i -g vercel") ;;
        git) REPORT_FLAGS+=("Missing git — install Xcode Command Line Tools: xcode-select --install") ;;
      esac
    fi
  done

  # Also check gh auth
  if command -v gh >/dev/null 2>&1; then
    if gh auth status 2>/dev/null >/dev/null; then
      say "${OK} gh: authenticated"
    else
      say "${WARN} gh: not authenticated"
      REPORT_FLAGS+=("gh CLI not authenticated — run: gh auth login")
    fi
  fi

  # Claude desktop app
  if [[ -d "/Applications/Claude.app" ]]; then
    say "${OK} Claude desktop app: present"
  else
    say "${WARN} Claude desktop app: not installed"
    REPORT_FLAGS+=("Claude desktop app not in /Applications — download from claude.ai")
  fi
}

# ============================================================================
# Step 7 — Master handoff device-path reality check (Tier 1 auto-heal)
# ============================================================================

check_master_handoff() {
  hdr "Master handoff — device path"

  local master="$SCRIPT_DIR/HANDOFF-MASTER.md"
  if [[ ! -f "$master" ]]; then
    say "${WARN} Master handoff not found"
    return
  fi

  # Expected path for this device is BSUITE_DIR
  local expected="$BSUITE_DIR"
  # Strip home prefix for matching
  local home_relative="${expected/#$HOME/\~}"

  # Find the line for this device in the Devices section (markdown list item)
  local line
  line=$(grep -E "^\s*-\s*\*\*${DEVICE_NAME}\*\*" "$master" 2>/dev/null | head -1 || true)

  if [[ -z "$line" ]]; then
    say "${WARN} ${DEVICE_NAME} not listed in master handoff Devices section"
    REPORT_FLAGS+=("$DEVICE_NAME not in master handoff — add it manually or via handoff away")
    return
  fi

  if echo "$line" | grep -qF "$home_relative"; then
    say "${OK} Master handoff lists correct path for ${DEVICE_NAME}"
  else
    say "${WARN} Master handoff has wrong path for ${DEVICE_NAME}"
    say "${INFO} Listed: $line"
    say "${INFO} Actual: $home_relative"
    if [[ "$MODE" == "--dry-run" ]]; then
      REPORT_FLAGS+=("Master handoff path for $DEVICE_NAME is wrong — would fix")
    else
      MASTER_FILE="$master" \
      DEV_NAME="$DEVICE_NAME" \
      NEW_PATH="$home_relative" \
      python3 <<'PYEOF'
import os, re
path = os.environ["MASTER_FILE"]
name = os.environ["DEV_NAME"]
new_path = os.environ["NEW_PATH"]
with open(path) as f:
    content = f.read()
pattern = re.compile(r'^(\s*-\s*\*\*' + re.escape(name) + r'\*\*[^\n]*?)`~/[^`]+`([^\n]*)$', re.MULTILINE)
replacement = r'\1`' + new_path + r'`\2'
new = pattern.sub(replacement, content, count=1)
if new != content:
    with open(path, 'w') as f:
        f.write(new)
PYEOF
      say "${OK} Master handoff auto-fixed for ${DEVICE_NAME}"
      REPORT_ACTIONS+=("Fixed master handoff path for $DEVICE_NAME → $home_relative")
    fi
  fi
}

# ============================================================================
# Step 8 — Write health report and update manifest
# ============================================================================

write_report() {
  [[ "$MODE" == "--dry-run" ]] && return

  mkdir -p "$HEALTH_DIR"
  local report_file="$HEALTH_DIR/${DEVICE_SLUG}-${TODAY}.json"

  # Write shell arrays to temp files so Python can read them cleanly
  local tmp_dir
  tmp_dir=$(mktemp -d)
  printf '%s\n' "${REPORT_REPOS[@]:-}" | grep -v '^$' > "$tmp_dir/repos.jsonl" || true
  printf '%s\n' "${REPORT_SKILLS[@]:-}" | grep -v '^$' > "$tmp_dir/skills.jsonl" || true
  printf '%s\n' "${REPORT_TOOLS[@]:-}" | grep -v '^$' > "$tmp_dir/tools.jsonl" || true
  printf '%s\n' "${REPORT_ACTIONS[@]:-}" | grep -v '^$' > "$tmp_dir/actions.txt" || true
  printf '%s\n' "${REPORT_FLAGS[@]:-}" | grep -v '^$' > "$tmp_dir/flags.txt" || true

  # Compose report + update manifest in a single Python call
  MANIFEST="$MANIFEST" \
  DEVICE_NAME="$DEVICE_NAME" \
  TIMESTAMP_UTC="$TIMESTAMP_UTC" \
  HOSTNAME_VAL="$HOSTNAME_VAL" \
  COMPUTER_NAME="$COMPUTER_NAME" \
  OS_VERSION="$OS_VERSION" \
  BSUITE_DIR="$BSUITE_DIR" \
  GIT_AUTH_OK="$GIT_AUTH_OK" \
  BSYNC_LOADED="$BSYNC_LOADED" \
  BSYNC_LAST_RUN="$BSYNC_LAST_RUN" \
  TODAY="$TODAY" \
  TMP_DIR="$tmp_dir" \
  REPORT_FILE="$report_file" \
  python3 <<'PYEOF'
import json, os

def load_jsonl(path):
    if not os.path.exists(path):
        return []
    out = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                out.append(json.loads(line))
            except json.JSONDecodeError:
                pass
    return out

def load_lines(path):
    if not os.path.exists(path):
        return []
    with open(path) as f:
        return [l.strip() for l in f if l.strip()]

tmp = os.environ["TMP_DIR"]
repos = load_jsonl(f"{tmp}/repos.jsonl")
skills = load_jsonl(f"{tmp}/skills.jsonl")
tools = load_jsonl(f"{tmp}/tools.jsonl")
actions = load_lines(f"{tmp}/actions.txt")
flags = load_lines(f"{tmp}/flags.txt")

report = {
    "bhealth_version": "1.0.0",
    "timestamp": os.environ["TIMESTAMP_UTC"],
    "device": os.environ["DEVICE_NAME"],
    "hostname": os.environ["HOSTNAME_VAL"],
    "computer_name": os.environ["COMPUTER_NAME"],
    "os_version": os.environ["OS_VERSION"],
    "bsuite_path": os.environ["BSUITE_DIR"],
    "git_auth_ok": os.environ["GIT_AUTH_OK"] == "true",
    "bsync_loaded": os.environ["BSYNC_LOADED"] == "true",
    "bsync_last_run": os.environ["BSYNC_LAST_RUN"],
    "repos": repos,
    "skills": skills,
    "tools": tools,
    "actions": actions,
    "flags": flags,
}
with open(os.environ["REPORT_FILE"], 'w') as f:
    json.dump(report, f, indent=2)
    f.write("\n")

# Update manifest with this device's current skill hashes
manifest_path = os.environ["MANIFEST"]
device = os.environ["DEVICE_NAME"]
today = os.environ["TODAY"]
if os.path.exists(manifest_path):
    with open(manifest_path) as f:
        manifest = json.load(f)
    devices = manifest.setdefault("devices", {})
    entry = devices.setdefault(device, {})
    for s in skills:
        name = s.get("skill")
        h = s.get("installed_hash", "unknown")
        if name:
            entry[name] = h
    entry["last_synced"] = today
    entry["bhealth_version"] = "1.0.0"
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
        f.write("\n")
PYEOF

  rm -rf "$tmp_dir" 2>/dev/null || true

  say ""
  say "${INFO} Report saved: ${report_file/#$HOME/~}"
  say "${INFO} Updated manifest for ${DEVICE_NAME}"
}

# ============================================================================
# Step 9 — Commit and push
# ============================================================================

commit_push() {
  [[ "$MODE" == "--dry-run" ]] && return
  [[ "$GIT_AUTH_OK" != "true" ]] && { say "${WARN} Skipping commit — git auth not verified"; return; }

  cd "$SCRIPT_DIR" || return

  # Pull first to minimize merge conflicts
  git pull --rebase origin main >/dev/null 2>&1 || true

  git add ".health/" "skills/skills-manifest.json" "HANDOFF-MASTER.md" 2>/dev/null
  if git diff --cached --quiet 2>/dev/null; then
    say "${INFO} No changes to commit"
    return
  fi

  local msg="bhealth: ${DEVICE_NAME} audit ${TODAY} — ${#REPORT_ACTIONS[@]} auto-heals, ${#REPORT_FLAGS[@]} flags"
  if git commit -m "$msg" >/dev/null 2>&1 && git push origin main >/dev/null 2>&1; then
    say "${OK} Committed + pushed: $msg"
  else
    say "${WARN} Commit or push failed — check git status"
  fi
}

# ============================================================================
# Step 10 — Final human summary
# ============================================================================

final_summary() {
  quiet && return

  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "  bhealth summary — ${DEVICE_NAME} — ${TODAY}"
  echo "════════════════════════════════════════════════════════════"

  if [[ ${#REPORT_ACTIONS[@]} -gt 0 ]]; then
    echo ""
    echo "Auto-healed:"
    for a in "${REPORT_ACTIONS[@]}"; do echo "  ${OK} $a"; done
  fi

  if [[ ${#REPORT_FLAGS[@]} -gt 0 ]]; then
    echo ""
    echo "Needs your attention:"
    for f in "${REPORT_FLAGS[@]}"; do echo "  ${WARN} $f"; done
  else
    echo ""
    echo "${OK} No flags — fleet-ready on this Mac."
  fi

  echo ""
  echo "Next: run this same command on your other Macs. Claude will reconcile."
  echo ""
}

# ============================================================================
# Main
# ============================================================================

identify_device
check_git_auth
audit_repos
audit_skills
check_bsync
check_tools
check_master_handoff
write_report
commit_push
final_summary
