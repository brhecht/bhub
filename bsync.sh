#!/bin/bash
# bsync v2.2 — B-Suite session bootstrap & reconciliation
# v2.2: Suppress stale lock-file warnings in Cowork mode (FUSE mount can't delete
#       Mac-owned files, so stale locks pile up forever; only fresh locks matter).
# Pulls all repos, cross-checks handoffs against git history, reconciles skills, rebuilds master.
# Claude executes this at session start, reads the JSON output, acts on findings.
# Also runs on Mac via LaunchAgent (--pull-only) or manually.
#
# Usage:
#   bash bsync.sh                    # Full bootstrap (pulls + handoff check + skills check)
#   bash bsync.sh --pull-only        # Just pull all repos (LaunchAgent mode)
#   bash bsync.sh --status           # Report status without pulling (fast, offline)

set -uo pipefail

# --- Config ---
# Detect environment: Cowork VM vs local Mac
if [[ -d "/sessions" ]]; then
  BSUITE_DIR="${BSUITE_DIR:-$(find /sessions -maxdepth 3 -name 'B-Suite' -type d 2>/dev/null | head -1)}"
  # Use session-unique work dir to avoid stale /tmp dirs from previous sessions
  SESSION_ID=$(echo "$BSUITE_DIR" | grep -o '/sessions/[^/]*' | cut -d'/' -f3)
  WORK_DIR="/tmp/bsync-${SESSION_ID:-$$}"
  ENV="cowork"
else
  BSUITE_DIR="${BSUITE_DIR:-$HOME/Developer/clients/hc/B-Suite}"
  WORK_DIR="/tmp/bsync-work"
  ENV="local"
fi

if [[ -z "$BSUITE_DIR" ]]; then
  echo '{"error": "B-Suite directory not found. Mount ~/Developer/B-Suite or set BSUITE_DIR."}'
  exit 1
fi

TOKEN_FILE="$BSUITE_DIR/.git-token"
LOG_FILE="$BSUITE_DIR/.bsync-log"
OUTPUT_FILE="$WORK_DIR/bsync-report.json"

# Repo registry: folder:github-repo
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

# Skip deep handoff check on dormant/archived repos
SKIP_HANDOFF_CHECK="pitch-scorer b-marketing hc-strategy"

# Skills tracked in manifest
TRACKED_SKILLS="handoff dev-deploy comms expert hc-strategy pm create-content"

MODE="${1:-full}"

# --- Helpers ---
mkdir -p "$WORK_DIR"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE" 2>/dev/null || true
}

json_escape() {
  printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()), end="")'
}

# --- Step 0: Git credentials ---
setup_git() {
  if [[ ! -f "$TOKEN_FILE" ]]; then
    echo '{"error": "git-token not found at '"$TOKEN_FILE"'. Generate a classic PAT at github.com/settings/tokens (repo scope) and save to .git-token in B-Suite root."}'
    exit 1
  fi
  TOKEN=$(cat "$TOKEN_FILE" | tr -d '[:space:]')
  git config --global credential.helper store 2>/dev/null
  echo "https://brhecht:${TOKEN}@github.com" > ~/.git-credentials 2>/dev/null
  git config --global user.name "brhecht" 2>/dev/null
  git config --global user.email "brhnyc1970@gmail.com" 2>/dev/null
  log "Git credentials configured"
}

# --- Step 1: Pull all repos ---
# For each repo: try git pull on mounted dir. If EPERM, clone to /tmp.
# If repo doesn't exist locally at all, clone to /tmp.
pull_repos() {
  local first="true"
  for entry in "${REPOS[@]}"; do
    local folder="${entry%%:*}"
    local github="${entry##*:}"
    local repo_dir="$BSUITE_DIR/$folder"
    local status="skipped"
    local detail=""
    local path="$repo_dir"

    if [[ "$ENV" == "cowork" ]]; then
      # Cowork sandbox: mounted drive is read-only. Always clone fresh to /tmp.
      # This is fast (shallow clone) and avoids all EPERM issues.
      local tmp_dir="$WORK_DIR/$folder"
      if git clone --depth 1 "https://github.com/${github}.git" "$tmp_dir" 2>/dev/null; then
        status="ok"
        path="$tmp_dir"
      else
        status="failed"
        detail="Clone to $WORK_DIR failed"
      fi
    elif [[ -d "$repo_dir/.git" ]]; then
      # Local Mac: pull directly on the repo
      rm -f "$repo_dir/.git/index.lock" "$repo_dir/.git/HEAD.lock" "$repo_dir/.git/ORIG_HEAD.lock" 2>/dev/null
      local output
      output=$(cd "$repo_dir" && git fetch origin 2>&1 && git reset --hard origin/main 2>&1) && status="ok" || {
        status="failed"
        detail=$(echo "$output" | head -3)
      }
    else
      # Repo doesn't exist locally — clone it
      if git clone "https://github.com/${github}.git" "$WORK_DIR/$folder" 2>/dev/null; then
        status="cloned_to_tmp"
        path="$WORK_DIR/$folder"
      else
        status="clone_failed"
        detail="Not local, clone failed"
      fi
    fi

    [[ "$first" == "true" ]] && first="false" || echo ","
    printf '    {"repo": "%s", "github": "%s", "status": "%s", "path": %s, "detail": %s}' \
      "$folder" "$github" "$status" "$(json_escape "$path")" "$(json_escape "${detail:-}")"

    log "$folder: $status"
  done
}

# --- Step 2: Handoff reconciliation ---
# Compare each HANDOFF.md date against git log. If commits are newer, report as stale
# with commit summaries so Claude can auto-reconcile.
check_handoffs() {
  local first="true"
  for entry in "${REPOS[@]}"; do
    local folder="${entry%%:*}"
    local github="${entry##*:}"

    # Skip dormant repos
    if echo "$SKIP_HANDOFF_CHECK" | grep -qw "$folder"; then
      continue
    fi

    # Find the repo — prefer /tmp clone (guaranteed fresh), fall back to mounted
    local repo_path=""
    if [[ -d "$WORK_DIR/$folder/.git" ]]; then
      repo_path="$WORK_DIR/$folder"
    elif [[ -d "$BSUITE_DIR/$folder/.git" ]]; then
      repo_path="$BSUITE_DIR/$folder"
    else
      continue
    fi

    local handoff_file="$repo_path/HANDOFF.md"
    local handoff_exists="false"
    local handoff_date=""
    local handoff_commit_date=""
    local latest_commit_date=""
    local latest_commit_msg=""
    local commits_since_handoff=0
    local recent_commits=""
    local stale="false"

    if [[ -f "$handoff_file" ]]; then
      handoff_exists="true"
      handoff_date=$(grep -i 'last updated' "$handoff_file" 2>/dev/null | head -1 | sed 's/.*[Ll]ast [Uu]pdated[: ]*//' | sed 's/\*.*//' | sed 's/~.*//' | xargs)
    fi

    if cd "$repo_path" 2>/dev/null; then
      latest_commit_date=$(git log -1 --format="%ai" 2>/dev/null | cut -d' ' -f1)
      latest_commit_msg=$(git log -1 --format="%s" 2>/dev/null)
      handoff_commit_date=$(git log -1 --format="%ai" -- HANDOFF.md 2>/dev/null | cut -d' ' -f1)

      if [[ -n "$handoff_commit_date" ]]; then
        commits_since_handoff=$(git log --oneline --after="$handoff_commit_date" 2>/dev/null | wc -l | xargs)
      elif [[ "$handoff_exists" == "true" ]]; then
        commits_since_handoff=$(git log --oneline -20 2>/dev/null | wc -l | xargs)
      fi

      if [[ $commits_since_handoff -gt 0 ]]; then
        stale="true"
        if [[ -n "$handoff_commit_date" ]]; then
          recent_commits=$(git log --oneline --after="$handoff_commit_date" --format="%h %s" 2>/dev/null | head -15)
        else
          recent_commits=$(git log --oneline -10 --format="%h %s" 2>/dev/null)
        fi
      fi
      if [[ "$handoff_exists" == "false" ]]; then
        stale="true"
        recent_commits=$(git log --oneline -10 --format="%h %s" 2>/dev/null)
      fi
    fi

    [[ "$first" == "true" ]] && first="false" || echo ","
    printf '    {"repo": "%s", "handoff_exists": %s, "handoff_date": %s, "handoff_commit_date": %s, "latest_commit_date": %s, "commits_since_handoff": %d, "stale": %s, "recent_commits": %s}' \
      "$folder" "$handoff_exists" "$(json_escape "${handoff_date:-}")" "$(json_escape "${handoff_commit_date:-}")" \
      "$(json_escape "${latest_commit_date:-}")" "$commits_since_handoff" "$stale" "$(json_escape "${recent_commits:-}")"
  done
}

# --- Step 3: Skills check ---
# Compare installed skill hashes against manifest. Report mismatches with install paths.
check_skills() {
  local manifest="${MANIFEST_FILE:-}"
  if [[ -z "$manifest" || ! -f "$manifest" ]]; then
    manifest="$WORK_DIR/bhub/skills/skills-manifest.json"
  fi
  if [[ ! -f "$manifest" ]]; then
    echo '    {"error": "skills-manifest.json not found"}'
    return
  fi

  local first="true"
  for skill in $TRACKED_SKILLS; do
    local expected_hash expected_version
    expected_hash=$(python3 -c "
import json
with open('$manifest') as f:
    m = json.load(f)
print(m.get('skills',{}).get('$skill',{}).get('hash','unknown'))
" 2>/dev/null)
    expected_version=$(python3 -c "
import json
with open('$manifest') as f:
    m = json.load(f)
print(m.get('skills',{}).get('$skill',{}).get('version','unknown'))
" 2>/dev/null)

    # Find installed SKILL.md
    local installed_hash="not_found"
    local skill_path=""
    for search_dir in \
      "/sessions/"*"/mnt/.claude/skills/$skill" \
      "$HOME/.claude/skills/$skill"; do
      if [[ -f "$search_dir/SKILL.md" ]]; then
        skill_path="$search_dir/SKILL.md"
        installed_hash=$(md5sum "$skill_path" 2>/dev/null | awk '{print $1}')
        break
      fi
    done

    local match="false"
    [[ "$installed_hash" == "$expected_hash" ]] && match="true"

    # Find .skill installer path
    local install_path=""
    for search_dir in "$BSUITE_DIR/bhub/skills" "$WORK_DIR/bhub/skills"; do
      if [[ -f "$search_dir/${skill}.skill" ]]; then
        install_path="$search_dir/${skill}.skill"
        break
      fi
    done

    [[ "$first" == "true" ]] && first="false" || echo ","
    printf '    {"skill": "%s", "expected_version": "%s", "expected_hash": "%s", "installed_hash": "%s", "match": %s, "install_path": %s}' \
      "$skill" "${expected_version:-unknown}" "${expected_hash:-unknown}" "$installed_hash" "$match" "$(json_escape "${install_path:-}")"
  done
}

# --- Step 4: Lock file check ---
# In Cowork, the FUSE mount blocks `rm` from the Linux VM, so stale .git/index.lock
# files (left over from previous Cowork sessions that died mid-git-op) accumulate
# on the mount. They're irrelevant — bsync clones fresh to /tmp/ in Cowork mode and
# never touches the mounted .git. Only report locks <60s old (indicating a real
# live concurrent git op on the Mac side). On local Mac, report all locks since
# they actually block git ops there.
check_locks() {
  local locks
  if [[ "$ENV" == "cowork" ]]; then
    locks=$(find "$BSUITE_DIR" -name "index.lock" -path "*/.git/*" -mmin -1 2>/dev/null || true)
  else
    locks=$(find "$BSUITE_DIR" -name "index.lock" -path "*/.git/*" 2>/dev/null || true)
  fi
  if [[ -n "$locks" ]]; then
    printf '"found": true, "files": %s' "$(json_escape "$locks")"
  else
    printf '"found": false, "files": ""'
  fi
}

# --- Main ---
log "bsync v2 started (mode: $MODE, env: $ENV)"
setup_git

if [[ "$MODE" == "--pull-only" ]]; then
  pull_repos > /dev/null
  log "bsync pull-only complete"
  echo '{"mode": "pull-only", "status": "complete"}'
  exit 0
fi

# Output structured JSON report
cat <<HEADER
{
  "bsync_version": "2.2.0",
  "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "environment": "$ENV",
  "bsuite_path": "$BSUITE_DIR",
  "locks": {
    $(check_locks)
  },
  "repos": [
HEADER

pull_repos

echo ""
echo "  ],"

if [[ "$MODE" != "--status" ]]; then
  echo '  "handoffs": ['
  check_handoffs
  echo ""
  echo "  ],"
  echo '  "skills": ['
  check_skills
  echo ""
  echo "  ]"
else
  echo '  "handoffs": [],'
  echo '  "skills": []'
fi

echo "}"

log "bsync v2 complete"
