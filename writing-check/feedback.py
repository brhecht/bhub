#!/usr/bin/env python3
"""UserPromptSubmit hook: if check.py left a pending note for this session, hand it to Claude
as additional context for the turn that is starting, then delete it. No delay, no tokens
beyond the note itself."""
import json, os, sys
BASE = os.path.join(os.path.expanduser('~'), '.claude', 'writing-check')
try: hook = json.load(sys.stdin)
except Exception: hook = {}
p = os.path.join(BASE, f"pending-{hook.get('session_id', 'unknown')}.md")
if os.path.exists(p):
    note = open(p).read().strip()
    os.remove(p)
    print(json.dumps({'hookSpecificOutput': {'hookEventName': 'UserPromptSubmit', 'additionalContext': note}}))
