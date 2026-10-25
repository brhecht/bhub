#!/usr/bin/env python3
"""Record a sentence Brian flagged by hand. Usage: flag.py "the sentence" [surface] [note]
Claude runs this when Brian points at a line; the weekly review reads these alongside the
automatic log."""
import json, os, sys, datetime
BASE = os.path.join(os.path.expanduser('~'), '.claude', 'writing-check'); os.makedirs(BASE, exist_ok=True)
s = sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read().strip()
rec = {'ts': datetime.datetime.now().isoformat(timespec='seconds'), 'session': 'manual', 'surface': sys.argv[2] if len(sys.argv) > 2 else 'unknown',
       'manual': True, 'items': [{'ctx': 'prose', 'kind': 'brian-flagged', 's': s[:300], 'note': sys.argv[3] if len(sys.argv) > 3 else ''}]}
with open(os.path.join(BASE, 'log.jsonl'), 'a') as fh: fh.write(json.dumps(rec, ensure_ascii=False) + '\n')
print('logged')
