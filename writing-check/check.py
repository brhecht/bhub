#!/usr/bin/env python3
"""The reply check. Runs as a Claude Code Stop hook.

Reads the hook JSON on stdin, finds the last assistant reply in the session transcript, runs
housestyle.check_text over it, and records the sentences that break HOUSE-STYLE.md.

Advisory mode (default): appends a record to ~/.claude/writing-check/log.jsonl and writes a pending
note that the UserPromptSubmit hook (feedback.py) shows Claude on the next turn. The hook is
installed with "async": true, so the second it takes runs in the background and never delays the
next message; if the next message is sent inside that second, the note arrives one turn later.
Blocking mode (BRIAN_WRITING_BLOCK=1 or --block, for unattended runs): if any prose sentence fails,
returns decision=block so Claude rewrites before the reply is delivered. Blocking needs a hook that
is not async, since an async hook's output is not read.
"""
import json, os, sys, datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
HOME = os.path.expanduser('~')
BASE = os.path.join(HOME, '.claude', 'writing-check')
LOG = os.path.join(BASE, 'log.jsonl')

def last_reply(transcript_path):
    last = None
    try:
        with open(transcript_path, errors='ignore') as fh:
            for line in fh:
                try: d = json.loads(line)
                except Exception: continue
                if d.get('type') != 'assistant' or d.get('isSidechain'): continue
                m = d.get('message')
                if not isinstance(m, dict): continue
                texts = [b.get('text', '') for b in m.get('content', []) if isinstance(b, dict) and b.get('type') == 'text']
                if any(t.strip() for t in texts): last = '\n'.join(texts)
    except FileNotFoundError:
        return None
    return last

def main():
    try: hook = json.load(sys.stdin)
    except Exception: hook = {}
    transcript = hook.get('transcript_path'); session = hook.get('session_id', 'unknown')
    block = os.environ.get('BRIAN_WRITING_BLOCK') == '1' or '--block' in sys.argv
    if hook.get('stop_hook_active') and block: return   # never block twice in a row
    text = last_reply(transcript) if transcript else None
    if not text or len(text.split()) < 15: return        # short acks are not worth checking
    from housestyle import check_text, note_for
    r = check_text(text, surface='code')
    os.makedirs(BASE, exist_ok=True)
    rec = {'ts': datetime.datetime.now().isoformat(timespec='seconds'), 'session': session, 'surface': 'code',
           'words': r['words'], 'prose': r['prose'], 'prose_fail': r['prose_fail'], 'bullets': r['bullets'],
           'bullet_fail': r['bullet_fail'], 'mode': 'block' if block else 'advise', 'items': r['items']}
    with open(LOG, 'a') as fh: fh.write(json.dumps(rec, ensure_ascii=False) + '\n')
    if not r['items']: return
    note = note_for(r, 'your last reply')
    if block and r['prose_fail']:
        print(json.dumps({'decision': 'block', 'reason': note + '\nRewrite the reply so every sentence states a fact with a stated subject and a literal verb, then send it again.'}))
        return
    with open(os.path.join(BASE, f'pending-{session}.md'), 'w') as fh: fh.write(note + '\n')

if __name__ == '__main__':
    try: main()
    except Exception as e:
        try:
            os.makedirs(BASE, exist_ok=True)
            with open(os.path.join(BASE, 'errors.log'), 'a') as fh: fh.write(f"{datetime.datetime.now().isoformat()} check.py {e!r}\n")
        except Exception: pass
