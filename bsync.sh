#!/bin/bash
# bsync v2.8 — B-Suite session bootstrap & reconciliation
# v2.8: check_skills now also reports manifest integrity per skill — source_hash,
#       bundle_hash, and manifest_synced (manifest hash == source hash). Catches the
#       silent-drift failure where a skill source/bundle is edited but the manifest
#       version+hash are not bumped (version tracking then lies). manifest_synced=false
#       is a loud flag to fix the manifest. null = externally-authored skill (no src).
# v2.7: Three bottleneck fixes that cut full bootstrap from >60s to ~10s:
#       (1) sync_mount_to_origin now fans out parallel git fetches (cap 8) instead
#           of sequential — eliminates the ~8-60s wall at session start.
#       (2) pull_repos capped at 8 concurrent clones — prevents GitHub rate-limit
#           failures that caused ~11/19 repos to fail on full runs.
#       (3) check_skills rewired to a single Python subprocess that reads all skills
#           from skills-manifest.json — drops hardcoded TRACKED_SKILLS, picks up
#           new manifest entries automatically (e.g. the June 8 +9 skills patch).
# v2.6: --app=name1,name2 flag scopes pull/handoff/mount-sync to listed apps
#       (bhub always included). Cuts a typical session bootstrap from ~45s to
#       ~8s by cloning 2 repos instead of 15. sync_mount_to_origin skipped in
#       scoped mode (focused work doesn't need fleet-wide mount sync).
#       Also fixes the spurious "No such file or directory" stderr leakage in
#       sync_mount_to_origin's file-restore path (now mkdir -p before write).
# v2.5: sync_mount_to_origin() — auto-fast-forward the mounted .git after Cowork
#       pushes, so the Mac's working tree never shows phantom "modified" state
#       from edits Cowork made directly on the mount. Eliminates the need to ever
#       run `git pull` on the Mac terminal. Auto-runs at start of every Cowork
#       bsync, also exposed as --sync-mount for explicit post-push invocation.
# v2.4: Pre-flight clean_stale_locks() — scrub orphan .git/*.lock* files >5min old
#       on Mac side every run (so launchd auto-pull also auto-cleans the FUSE-stuck
#       orphans Cowork can't delete).
# v2.3: Suppress stale .git/index.lock warnings in Cowork mode (FUSE mount blocks
#       rm of Mac-owned files, so stale locks pile up forever; only fresh locks matter).
# Pulls all repos (in parallel), cross-checks handoffs against git history,
# reconciles skills, rebuilds master.
# Claude executes this at session start, reads the JSON output, acts on findings.
# Also runs on Mac via LaunchAgent (--pull-only) or manually.
#
# v2.2 change: pull_repos now runs all 14 clones in parallel. Cuts handoff-here
# time from ~23s to ~5s in Cowork.
#
# Usage:
#   bash bsync.sh                    # Full bootstrap (pulls + handoff check + skills check)
#   bash bsync.sh --app=name1,name2  # Scoped bootstrap — only pull bhub + listed apps.
#                                    # Use for focused sessions; ~5x faster than full.
#   bash bsync.sh --pull-only        # Just pull all repos (LaunchAgent mode)
#   bash bsync.sh --status           # Report status without pulling (fast, offline)
#   bash bsync.sh --sync-mount       # Cowork-only: fast-forward mounted .git to origin
#                                    # after a push (so Mac sees clean state)

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
  BSUITE_DIR="${BSUITE_DIR:-$HOME/Developer/B-Suite}"
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

# Repo registry: folder:github-repo[:base-relative-to-BSUITE_DIR]
# Default base is "." (repo lives at $BSUITE_DIR/$folder). Use ".." for sibling
# repos that live alongside B-Suite under ~/Developer/ (not inside B-Suite/).
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
  "builder-bot:brhecht/builder-bot"
  "bsuite-handoffs:brhecht/bsuite-handoffs"
  # Sibling repos under ~/Developer/ (alongside B-Suite/, not inside it)
  "muscle-anatomy:brhecht/muscle-anatomy:.."
  "saturn-v-anatomy:brhecht/saturn-v-anatomy:.."
  "B-Personal:brhecht/b-personal:.."
)

# Helper: resolve the local mount path for a repo entry.
# Entry format: folder:github[:base_rel]. Default base_rel = "." (use $BSUITE_DIR
# as-is); ".." places the repo alongside B-Suite under ~/Developer/.
# Echoes the absolute path with .. resolved.
repo_dir_for() {
  local entry="$1"
  local folder rest base_rel
  folder="${entry%%:*}"
  rest="${entry#*:}"           # strip folder
  # github is always second field; we don't need it here
  if [[ "$rest" == *:* ]]; then
    base_rel="${rest##*:}"
  else
    base_rel="."
  fi
  if [[ "$base_rel" == "." ]]; then
    echo "$BSUITE_DIR/$folder"
  elif [[ "$base_rel" == ".." ]]; then
    # Sibling repo under ~/Developer/ (alongside B-Suite, not inside it).
    # On host, BSUITE_DIR=~/Developer/B-Suite so the sibling is at $(dirname BSUITE_DIR)/$folder.
    # In Cowork, folders are mounted flat at /sessions/.../mnt/, so the sibling
    # lives at $(dirname BSUITE_DIR)/Developer/$folder (when Developer is mounted).
    local parent
    parent="$(dirname "$BSUITE_DIR")"
    if [[ -d "$parent/Developer/$folder/.git" ]]; then
      echo "$parent/Developer/$folder"
    else
      echo "$parent/$folder"
    fi
  else
    echo "$BSUITE_DIR/$base_rel/$folder"
  fi
}

# Helper: extract github "owner/repo" from an entry (handles 2- or 3-field form).
github_for() {
  local entry="$1"
  local rest="${entry#*:}"      # strip folder → "github[:base]"
  echo "${rest%%:*}"
}

# Skip deep handoff check on dormant/archived repos and on the handoffs repo itself
SKIP_HANDOFF_CHECK="pitch-scorer b-marketing hc-strategy bsuite-handoffs"

# Argument parsing: positional MODE flag + optional --app=name1,name2 anywhere
MODE="full"
APPS=""
for arg in "$@"; do
  case "$arg" in
    --app=*) APPS="${arg#--app=}" ;;
    --pull-only|--status|--sync-mount) MODE="$arg" ;;
    *) ;;
  esac
done
# Build APPS_FILTER as a space-padded string for fast lookup; bhub always included.
APPS_FILTER=""
if [[ -n "$APPS" ]]; then
  APPS_FILTER=" $(echo "$APPS" | tr ',' ' ') bhub "
fi

# is_app_in_scope folder
# Returns 0 if folder should be processed, 1 otherwise.
# When APPS_FILTER is empty, everything is in scope.
is_app_in_scope() {
  [[ -z "$APPS_FILTER" ]] && return 0
  [[ "$APPS_FILTER" == *" $1 "* ]] && return 0
  return 1
}

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

# --- Step 1: Pull all repos (in parallel) ---
# Each repo is cloned/pulled in its own background subshell, writing a JSON
# fragment to a temp file. After all finish, fragments are concatenated in
# REPOS-array order so output is deterministic.

# Clone/pull one repo and write JSON fragment to $3. Safe to run in parallel.
pull_one_repo() {
  local folder="$1"
  local github="$2"
  local out_file="$3"
  local repo_dir="$4"
  local status="skipped"
  local detail=""
  local path="$repo_dir"

  if [[ "$ENV" == "cowork" ]]; then
    # Cowork sandbox: always clone fresh to /tmp (shallow = fast).
    # Exception: reuse the Phase 1 bhub clone if it exists — Phase 1 already
    # cloned bhub to /tmp/bhub-bootstrap, so cloning it again here is pure waste.
    local tmp_dir="$WORK_DIR/$folder"
    if [[ "$folder" == "bhub" && -d "/tmp/bhub-bootstrap/.git" ]]; then
      status="ok"
      path="/tmp/bhub-bootstrap"
    else
      [[ -d "$tmp_dir" ]] && rm -rf "$tmp_dir"
      if git clone --depth 1 "https://github.com/${github}.git" "$tmp_dir" 2>/dev/null; then
        status="ok"
        path="$tmp_dir"
      else
        status="failed"
        detail="Clone to $WORK_DIR failed"
      fi
    fi
  elif [[ -d "$repo_dir/.git" ]]; then
    # Local Mac: fetch + hard reset to origin/main
    rm -f "$repo_dir/.git/index.lock" "$repo_dir/.git/HEAD.lock" "$repo_dir/.git/ORIG_HEAD.lock" 2>/dev/null
    local output
    output=$(cd "$repo_dir" && git fetch origin 2>&1 && git reset --hard origin/main 2>&1) && status="ok" || {
      status="failed"
      detail=$(echo "$output" | head -3)
    }
  else
    # Repo doesn't exist locally — clone to /tmp
    [[ -d "$WORK_DIR/$folder" ]] && rm -rf "$WORK_DIR/$folder"
    if git clone "https://github.com/${github}.git" "$WORK_DIR/$folder" 2>/dev/null; then
      status="cloned_to_tmp"
      path="$WORK_DIR/$folder"
    else
      status="clone_failed"
      detail="Not local, clone failed"
    fi
  fi

  printf '    {"repo": "%s", "github": "%s", "status": "%s", "path": %s, "detail": %s}' \
    "$folder" "$github" "$status" "$(json_escape "$path")" "$(json_escape "${detail:-}")" \
    > "$out_file"
}

pull_repos() {
  local frag_dir="$WORK_DIR/pull-fragments"
  mkdir -p "$frag_dir"
  rm -f "$frag_dir"/*.json 2>/dev/null

  # Fan out clones in parallel, capped at 8 to avoid GitHub rate-limit failures.
  # Previous uncapped approach (19 simultaneous) caused ~11/19 repos to fail.
  local MAX_PARALLEL=8
  local pids=()
  for entry in "${REPOS[@]}"; do
    local folder="${entry%%:*}"
    local github="$(github_for "$entry")"
    local repo_dir="$(repo_dir_for "$entry")"
    is_app_in_scope "$folder" || continue
    pull_one_repo "$folder" "$github" "$frag_dir/${folder}.json" "$repo_dir" &
    pids+=($!)
    # When we hit the cap, wait for the oldest job before spawning the next.
    if [[ ${#pids[@]} -ge $MAX_PARALLEL ]]; then
      wait "${pids[0]}" 2>/dev/null || true
      pids=("${pids[@]:1}")
    fi
  done

  # Wait for remaining in-flight jobs
  for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done

  # Emit fragments in REPOS order. Out-of-scope repos never wrote a fragment,
  # so the file-existence guard naturally filters them out.
  local first="true"
  for entry in "${REPOS[@]}"; do
    local folder="${entry%%:*}"
    is_app_in_scope "$folder" || continue
    local frag="$frag_dir/${folder}.json"
    if [[ -f "$frag" ]]; then
      [[ "$first" == "true" ]] && first="false" || echo ","
      cat "$frag"
      log "$folder: emitted"
    fi
  done
}

# --- Step 2: Handoff reconciliation ---
# Compare each HANDOFF.md date against git log. If commits are newer, report as stale
# with commit summaries so Claude can auto-reconcile.
check_handoffs() {
  local first="true"
  for entry in "${REPOS[@]}"; do
    local folder="${entry%%:*}"
    local github="$(github_for "$entry")"

    # Skip dormant repos
    if echo "$SKIP_HANDOFF_CHECK" | grep -qw "$folder"; then
      continue
    fi

    # Skip out-of-scope repos when --app= filter is active
    is_app_in_scope "$folder" || continue

    # Find the repo — prefer /tmp clone (guaranteed fresh), fall back to mounted
    local repo_path=""
    if [[ -d "$WORK_DIR/$folder/.git" ]]; then
      repo_path="$WORK_DIR/$folder"
    elif [[ -d "$(repo_dir_for "$entry")/.git" ]]; then
      repo_path="$(repo_dir_for "$entry")"
    else
      continue
    fi

    # HANDOFFs now live in a dedicated private repo (bsuite-handoffs)
    # to avoid leaking strategy/architecture from any public app repo.
    # See migration entry in bsuite-handoffs/HANDOFF-MASTER.md (May 25, 2026).
    local handoffs_repo=""
    if [[ -d "$WORK_DIR/bsuite-handoffs/.git" ]]; then
      handoffs_repo="$WORK_DIR/bsuite-handoffs"
    elif [[ -d "$BSUITE_DIR/bsuite-handoffs/.git" ]]; then
      handoffs_repo="$BSUITE_DIR/bsuite-handoffs"
    fi

    local handoff_file="$handoffs_repo/$folder/HANDOFF.md"
    local handoff_exists="false"
    local handoff_date=""
    local handoff_commit_date=""
    local latest_commit_date=""
    local latest_commit_msg=""
    local commits_since_handoff=0
    local recent_commits=""
    local stale="false"

    if [[ -n "$handoffs_repo" && -f "$handoff_file" ]]; then
      handoff_exists="true"
      handoff_date=$(grep -i 'last updated' "$handoff_file" 2>/dev/null | head -1 | sed 's/.*[Ll]ast [Uu]pdated[: ]*//' | sed 's/\*.*//' | sed 's/~.*//' | xargs)
    fi

    # Handoff commit date comes from the bsuite-handoffs repo
    if [[ -n "$handoffs_repo" ]] && cd "$handoffs_repo" 2>/dev/null; then
      handoff_commit_date=$(git log -1 --format="%ai" -- "$folder/HANDOFF.md" 2>/dev/null | cut -d' ' -f1)
    fi

    # App-code commit dates come from the app repo
    if cd "$repo_path" 2>/dev/null; then
      latest_commit_date=$(git log -1 --format="%ai" 2>/dev/null | cut -d' ' -f1)
      latest_commit_msg=$(git log -1 --format="%s" 2>/dev/null)

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
# Single Python subprocess reads the full manifest and checks all skills at once.
# Previously: 2 python3 calls per skill (for hash + version) = N×2 subprocess spawns.
# Now: 1 call total, regardless of how many skills are in the manifest.
# TRACKED_SKILLS variable removed — manifest is the source of truth for which skills
# to check. Add a skill to skills-manifest.json and it's automatically checked here.
check_skills() {
  local manifest="${MANIFEST_FILE:-}"
  if [[ -z "$manifest" || ! -f "$manifest" ]]; then
    manifest="$WORK_DIR/bhub/skills/skills-manifest.json"
  fi
  if [[ ! -f "$manifest" ]]; then
    echo '    {"error": "skills-manifest.json not found"}'
    return
  fi

  python3 - "$manifest" "$BSUITE_DIR/bhub/skills" "$WORK_DIR/bhub/skills" <<'PYEOF'
import json, sys, hashlib, glob, os, zipfile

manifest_path = sys.argv[1]
install_dirs  = sys.argv[2:]

with open(manifest_path) as f:
    manifest = json.load(f)

skills = manifest.get('skills', {})
rows = []

for skill_name in sorted(skills):
    info           = skills[skill_name]
    expected_hash  = info.get('hash', 'unknown')
    expected_ver   = info.get('version', 'unknown')

    # Find installed SKILL.md (one glob per search path; stop at first hit)
    installed_hash = 'not_found'
    for pattern in [f'/sessions/*/mnt/.claude/skills/{skill_name}/SKILL.md',
                    os.path.expanduser(f'~/.claude/skills/{skill_name}/SKILL.md')]:
        matches = glob.glob(pattern)
        if matches:
            with open(matches[0], 'rb') as fh:
                installed_hash = hashlib.md5(fh.read()).hexdigest()
            break

    match = installed_hash == expected_hash

    # Find .skill bundle for the install link
    install_path = ''
    for d in install_dirs:
        candidate = f'{d}/{skill_name}.skill'
        if os.path.exists(candidate):
            install_path = candidate
            break

    # Manifest integrity: does the manifest hash still match the skill's SOURCE and built BUNDLE?
    # Catches the silent-drift failure mode where a skill's source/bundle is edited but the
    # manifest version+hash are NOT bumped, so version tracking quietly lies (the a81d1e3 bug).
    source_hash = 'not_found'
    for d in reversed(install_dirs):  # prefer the freshly-pulled work-dir copy as source of truth
        cand = f'{d}/src/{skill_name}-SKILL.md'
        if os.path.exists(cand):
            with open(cand, 'rb') as fh:
                source_hash = hashlib.md5(fh.read()).hexdigest()
            break
    bundle_hash = 'not_found'
    if install_path:
        try:
            with zipfile.ZipFile(install_path) as z:
                bundle_hash = hashlib.md5(z.read(f'{skill_name}/SKILL.md')).hexdigest()
        except Exception:
            bundle_hash = 'not_found'
    if source_hash == 'not_found':
        manifest_synced = 'null'   # no source file to check (e.g. externally-authored skill)
    else:
        manifest_synced = 'true' if source_hash == expected_hash else 'false'

    rows.append(
        f'    {{"skill": {json.dumps(skill_name)}, '
        f'"expected_version": {json.dumps(expected_ver)}, '
        f'"expected_hash": {json.dumps(expected_hash)}, '
        f'"installed_hash": {json.dumps(installed_hash)}, '
        f'"match": {"true" if match else "false"}, '
        f'"source_hash": {json.dumps(source_hash)}, '
        f'"bundle_hash": {json.dumps(bundle_hash)}, '
        f'"manifest_synced": {manifest_synced}, '
        f'"install_path": {json.dumps(install_path)}}}'
    )

print(',\n'.join(rows))
PYEOF
}

# --- Step 4: Lock file check ---
# In Cowork, the FUSE mount blocks `rm` from the Linux VM, so stale .git/index.lock
# files (left over from previous Cowork sessions that died mid-git-op) accumulate
# on the mount. They're irrelevant — bsync clones fresh to /tmp/ in Cowork mode and
# never touches the mounted .git. Only report locks <60s old (indicating a real
# live concurrent git op). On local Mac, report all locks since they actually
# block git ops there.
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

# --- Pre-flight: scrub stale .git lock-file orphans (Mac-only) ---
# Cowork's FUSE mount can't unlink Mac-owned files, so previous sessions leave
# stale .git/index.lock (and orphan .lock.bak/.lock.old/etc. variants) behind.
# Scrub anything >5 min old — well past any real concurrent git op (which
# completes in seconds for these tiny repos).
clean_stale_locks() {
  if [[ "$ENV" == "local" ]]; then
    local cleaned
    cleaned=$(find "$BSUITE_DIR" -path "*/.git/*" -name "*.lock*" -type f -mmin +5 2>/dev/null | wc -l | xargs)
    find "$BSUITE_DIR" -path "*/.git/*" -name "*.lock*" -type f -mmin +5 -delete 2>/dev/null || true
    [[ "$cleaned" -gt 0 ]] && log "Scrubbed $cleaned stale lock orphan(s)"
  fi
}

# --- Mount sync (Cowork-only) ---
# After Cowork pushes new commits to GitHub, the mounted .git directory on the
# user's Mac stays at the OLD HEAD, while the working tree (which Cowork edited)
# matches the NEW HEAD. Result: `git status` on Mac shows tracked files as
# "modified", and `git pull` fails with "your local changes would be overwritten".
#
# Fix: after pushing, fast-forward the mount's local main ref + index to match
# origin/main. We can't `git pull` on the mount (FUSE blocks unlink), but we CAN:
#   1. `git fetch` (writes objects, no unlink needed)
#   2. echo new SHA into .git/refs/heads/main (file write, no unlink)
#   3. `git read-tree HEAD` (writes index, no working-tree touch)
# For working-tree files that drifted (rare), we overwrite via `git show HEAD:f >f`
# (write+truncate works on FUSE; rm doesn't).
#
# v2.7: Parallelized with cap=8. Was sequential — on a slow connection each
# `git fetch` takes 3-5s, so 19 repos = 60-95s wall time before clones even start.
# Now all in-scope fetches fire concurrently (capped to avoid GitHub limits).

# Sync one mounted repo. Designed to run in a background subshell.
sync_one_mount() {
  local repo_dir="$1"
  [[ ! -d "$repo_dir/.git" ]] && return
  cd "$repo_dir" 2>/dev/null || return

  [[ -f .git/index.lock ]] && mv .git/index.lock ".git/index.lock.cwk_$$" 2>/dev/null

  local branch="main"
  git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null || branch="master"

  git fetch origin "$branch" --quiet 2>/dev/null

  local new_sha cur_sha
  new_sha=$(git rev-parse "origin/$branch" 2>/dev/null)
  cur_sha=$(git rev-parse HEAD 2>/dev/null)
  [[ -z "$new_sha" ]] && return

  if [[ "$cur_sha" != "$new_sha" ]]; then
    echo "$new_sha" > ".git/refs/heads/$branch"
  fi

  [[ -f .git/index.lock ]] && mv .git/index.lock ".git/index.lock.cwk2_$$" 2>/dev/null
  git read-tree HEAD 2>/dev/null

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local code="${line:0:2}"
    local file="${line:3}"
    case "$code" in
      " M"|"M "|" D"|"D ")
        mkdir -p "$(dirname "$file")" 2>/dev/null
        git show "HEAD:$file" > "$file" 2>/dev/null
        ;;
    esac
  done < <(git status --porcelain 2>/dev/null | grep -v "^??")
}

sync_mount_to_origin() {
  [[ "$ENV" != "cowork" ]] && return
  # Scoped runs sync only in-scope repos on the mount (bhub always included
  # so newly-pushed skill bundles + bsync.sh land on the mount immediately,
  # and install-link computer:// paths point to current bundles).
  local MAX_PARALLEL=8
  local pids=()
  for entry in "${REPOS[@]}"; do
    local folder="${entry%%:*}"
    is_app_in_scope "$folder" || continue
    local repo_dir="$(repo_dir_for "$entry")"
    sync_one_mount "$repo_dir" &
    pids+=($!)
    if [[ ${#pids[@]} -ge $MAX_PARALLEL ]]; then
      wait "${pids[0]}" 2>/dev/null || true
      pids=("${pids[@]:1}")
    fi
  done
  for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done
  log "sync_mount: parallel complete"
}

# --- Main ---
log "bsync v2.7 started (mode: $MODE, apps: ${APPS:-all}, env: $ENV)"
setup_git
clean_stale_locks

if [[ "$MODE" == "--sync-mount" ]]; then
  sync_mount_to_origin
  log "sync-mount complete"
  echo '{"mode": "sync-mount", "status": "complete"}'
  exit 0
fi

if [[ "$MODE" == "--pull-only" ]]; then
  pull_repos > /dev/null
  log "bsync pull-only complete"
  echo '{"mode": "pull-only", "status": "complete"}'
  exit 0
fi

# In Cowork mode, auto-sync the mount at session start so any drift from prior
# sessions is healed before we do anything else.
sync_mount_to_origin

# Output structured JSON report
cat <<HEADER
{
  "bsync_version": "2.8.0",
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
