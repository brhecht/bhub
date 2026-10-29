#!/bin/bash
# install-house-style.sh — one command that puts the B-Suite house style on a Mac.
#
#   curl -fsSL https://raw.githubusercontent.com/brhecht/bhub/main/install-house-style.sh | bash
#
# What it does, in order:
#   1. Gets a copy of the public bhub repo. On a Mac with ~/Developer/B-Suite/bhub (Brian's Macs) it
#      uses that copy; otherwise it clones to ~/.claude/house-style/bhub.
#   2. Makes ~/.claude/CLAUDE.md import HOUSE-STYLE.md, so every Claude Code session reads the rules.
#   3. Installs the writing check (writing-check/install.sh): the parser, the reply check, the
#      save-and-send check, the weekly review.
#   4. Merges four hooks into ~/.claude/settings.json without touching anything else in it:
#      the reply check, the next-turn feedback, the save-and-send check, and a session-start updater.
#   5. Writes ~/.claude/house-style/update.sh, which the updater hook runs in the background at each
#      session start: it pulls bhub and copies any changed check scripts into place.
# Running it again is safe; every step checks before it writes.
set -euo pipefail
HS="$HOME/.claude/house-style"; mkdir -p "$HS"
if [[ -d "$HOME/Developer/B-Suite/bhub/.git" ]]; then
  BHUB="$HOME/Developer/B-Suite/bhub"; echo "using the bhub checkout at $BHUB"
else
  BHUB="$HS/bhub"
  if [[ -d "$BHUB/.git" ]]; then git -C "$BHUB" pull -q --ff-only && echo "updated $BHUB"
  else git clone -q --depth 1 https://github.com/brhecht/bhub.git "$BHUB" && echo "cloned bhub to $BHUB"; fi
fi
[[ -f "$BHUB/HOUSE-STYLE.md" ]] || { echo "HOUSE-STYLE.md not found in $BHUB" >&2; exit 1; }

# 2. The import line in ~/.claude/CLAUDE.md.
TILDE_BHUB="${BHUB/#$HOME/~}"
IMPORT="@$TILDE_BHUB/HOUSE-STYLE.md"
CM="$HOME/.claude/CLAUDE.md"; mkdir -p "$HOME/.claude"
if [[ -f "$CM" ]] && grep -qF -- "$IMPORT" "$CM"; then echo "CLAUDE.md already imports the house style"
elif [[ -f "$CM" ]]; then printf '\n# B-Suite house style (kept current by the house-style updater; edit it in the bhub repo, never here)\n%s\n' "$IMPORT" >> "$CM"; echo "added the import to $CM"
else printf '# Standing instructions for Claude Code\n\n# B-Suite house style (kept current by the house-style updater; edit it in the bhub repo, never here)\n%s\n' "$IMPORT" > "$CM"; echo "created $CM"; fi

# 3. The writing check.
bash "$BHUB/writing-check/install.sh" | grep -vE '^(Hooks for|"hooks"|  "|}|JSON)' || true

# 5. The updater script (written before the hook that calls it).
cat > "$HS/update.sh" <<EOF
#!/bin/bash
# Pulls bhub and copies changed check scripts into place. Run by a SessionStart hook in the background.
BHUB="$BHUB"; DST="\$HOME/.claude/writing-check"
[[ -d "\$BHUB/.git" ]] || exit 0
if [[ "\$BHUB" == "\$HOME/.claude/house-style/bhub" ]]; then git -C "\$BHUB" pull -q --ff-only >/dev/null 2>&1 || exit 0; fi
for f in housestyle check feedback flag review send-check tests; do
  [[ -f "\$BHUB/writing-check/\$f.py" ]] && ! cmp -s "\$BHUB/writing-check/\$f.py" "\$DST/\$f.py" && cp "\$BHUB/writing-check/\$f.py" "\$DST/\$f.py"
done
exit 0
EOF
chmod +x "$HS/update.sh"

# 4. The hooks, merged into settings.json by a small Python program that leaves every other setting as it is.
python3 - "$HOME/.claude/settings.json" <<'PY'
import json, os, sys
path = sys.argv[1]
try: s = json.load(open(path))
except Exception: s = {}
hooks = s.setdefault('hooks', {})
PY_ = '~/.claude/writing-check/venv/bin/python -W ignore ~/.claude/writing-check/'
want = {
  'Stop': (None, {'type': 'command', 'command': PY_ + 'check.py', 'timeout': 20, 'statusMessage': 'Checking the reply against HOUSE-STYLE.md'}),
  'UserPromptSubmit': (None, {'type': 'command', 'command': PY_ + 'feedback.py', 'timeout': 5}),
  'PreToolUse': ('mcp__.*__(save_issue|save_comment|save_document|save_release_note|save_status_update|slack_send_message|slack_send_message_draft|slack_create_canvas|slack_update_canvas|send_message|reply|forward|create_draft|update_draft)$',
                 {'type': 'command', 'command': PY_ + 'send-check.py', 'timeout': 20, 'statusMessage': 'Checking the text against HOUSE-STYLE.md before it is saved'}),
  'SessionStart': (None, {'type': 'command', 'command': '~/.claude/house-style/update.sh', 'timeout': 60, 'async': True}),
}
added = []
for event, (matcher, hook) in want.items():
    groups = hooks.setdefault(event, [])
    if any(h.get('command') == hook['command'] for g in groups for h in g.get('hooks', [])): continue
    g = {'hooks': [hook]}
    if matcher: g['matcher'] = matcher
    groups.append(g); added.append(event)
json.dump(s, open(path, 'w'), indent=2); open(path, 'a').write('\n')
print('hooks added: ' + (', '.join(added) if added else 'none, all four were already there'))
PY
echo
echo "Done. The house style is installed. Open a new Claude Code session for the hooks to start."
echo "For claude.ai or Cowork, paste the text in $BHUB/HOUSE-STYLE-claudeai.md into a custom Style."
