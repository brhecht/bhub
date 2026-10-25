#!/bin/bash
# install.sh — set up the writing check on this Mac.
# Copies the scripts to ~/.claude/writing-check/, creates the parser venv there if missing,
# and prints the hook entries to merge into ~/.claude/settings.json.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; DST="$HOME/.claude/writing-check"
mkdir -p "$DST"; cp "$SRC"/check.py "$SRC"/feedback.py "$SRC"/flag.py "$SRC"/review.py "$DST"/
if [[ ! -x "$DST/venv/bin/python" ]]; then
  # Exact pins: spaCy 3.7 is the last line for the system Python 3.9, and newer preshed,
  # murmurhash and srsly releases make the model fail to load (OverflowError in the tokenizer).
  python3 -m venv "$DST/venv"; "$DST/venv/bin/pip" install -q --upgrade pip
  "$DST/venv/bin/pip" install -q -r "$SRC/requirements.txt"; "$DST/venv/bin/python" -m spacy download en_core_web_sm -q
fi
"$DST/venv/bin/python" -W ignore -c "import spacy; spacy.load('en_core_web_sm')" && echo "parser ok"
echo "scripts installed in $DST"
echo 'Hooks for ~/.claude/settings.json (merge, do not replace):'
cat <<'JSON'
"hooks": {
  "Stop": [{"hooks": [{"type": "command", "command": "~/.claude/writing-check/venv/bin/python -W ignore ~/.claude/writing-check/check.py", "timeout": 20, "statusMessage": "Checking the reply against WRITING-TO-BRIAN.md"}]}],
  "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "~/.claude/writing-check/venv/bin/python -W ignore ~/.claude/writing-check/feedback.py", "timeout": 5}]}]
}
JSON
