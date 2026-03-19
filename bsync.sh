#!/bin/bash
# B-Suite repo sync — pulls all 10 repos to latest main
# Runs automatically via LaunchAgent on login, or manually: bash ~/Developer/B-Suite/bsync.sh

BSUITE_DIR="$HOME/Developer/B-Suite"
TOKEN_FILE="$BSUITE_DIR/.git-token"
LOG_FILE="$BSUITE_DIR/.bsync-log"

REPOS="things-app brain-inbox content-calendar b-marketing eddy bhub b-people b-resources pitch-scorer hc-funnel"

if [ ! -f "$TOKEN_FILE" ]; then
  echo "$(date): ERROR — .git-token not found" >> "$LOG_FILE"
  exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")

echo "$(date): bsync started" >> "$LOG_FILE"

for d in $REPOS; do
  REPO_DIR="$BSUITE_DIR/$d"
  if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    # Remove stale lock files from any previous crashed git process
    rm -f .git/index.lock .git/HEAD.lock
    REMOTE=$(git remote get-url origin | sed 's|https://||')
    OUTPUT=$(git pull "https://brhecht:${TOKEN}@${REMOTE}" main 2>&1)
    STATUS=$?
    if [ $STATUS -eq 0 ]; then
      echo "$(date): $d — OK" >> "$LOG_FILE"
    else
      echo "$(date): $d — FAILED ($OUTPUT)" >> "$LOG_FILE"
    fi
  else
    echo "$(date): $d — repo not found, skipping" >> "$LOG_FILE"
  fi
done

echo "$(date): bsync complete" >> "$LOG_FILE"
