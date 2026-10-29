#!/bin/bash
# install.sh — set up the writing check on this Mac.
# Copies the scripts to ~/.claude/writing-check/, creates the parser venv there if missing,
# runs the tests, and prints the hook entries to merge into ~/.claude/settings.json.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; DST="$HOME/.claude/writing-check"
mkdir -p "$DST"; cp "$SRC"/housestyle.py "$SRC"/check.py "$SRC"/feedback.py "$SRC"/flag.py "$SRC"/review.py "$SRC"/tests.py "$DST"/
[[ -f "$SRC/send-check.py" ]] && cp "$SRC/send-check.py" "$DST"/
if [[ ! -x "$DST/venv/bin/python" ]]; then
  command -v python3 >/dev/null || { echo "python3 is missing. Open Terminal, run: xcode-select --install, then run this installer again." >&2; exit 1; }
  PYMINOR="$(python3 -c 'import sys; print(sys.version_info.minor)')"
  python3 -m venv "$DST/venv"; "$DST/venv/bin/pip" install -q --upgrade pip
  if [[ "$PYMINOR" -le 9 ]]; then
    # Exact pins: spaCy 3.7 is the last line for the system Python 3.9, and newer preshed,
    # murmurhash and srsly releases make the model fail to load (OverflowError in the tokenizer).
    "$DST/venv/bin/pip" install -q -r "$SRC/requirements.txt"
  else
    # A newer Python takes current spaCy; the pins above do not build there.
    "$DST/venv/bin/pip" install -q "spacy>=3.7,<3.9"
  fi
  "$DST/venv/bin/python" -m spacy download en_core_web_sm -q
fi
"$DST/venv/bin/python" -W ignore -c "import spacy; spacy.load('en_core_web_sm')" && echo "parser ok"
(cd "$DST" && "$DST/venv/bin/python" -W ignore tests.py | tail -1)
echo "scripts installed in $DST"
echo 'Hooks for ~/.claude/settings.json (merge, do not replace):'
cat <<'JSON'
"hooks": {
  "Stop": [{"hooks": [{"type": "command", "command": "~/.claude/writing-check/venv/bin/python -W ignore ~/.claude/writing-check/check.py", "timeout": 20, "async": true, "statusMessage": "Checking the reply against HOUSE-STYLE.md"}]}],
  "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "~/.claude/writing-check/venv/bin/python -W ignore ~/.claude/writing-check/feedback.py", "timeout": 5}]}]
}
JSON
