#!/usr/bin/env python3
"""The save-and-send check. Runs as a Claude Code PreToolUse hook on the tools that write text into a
shared system: Linear (save_issue, save_comment, save_document), Slack (send_message, canvases) and
Gmail (send, reply, forward, drafts).

It reads the tool call from stdin, takes every string in the call that is fifteen words or longer,
drops quoted material, and runs housestyle.check_text over it. If a sentence fails, the call is
denied and the failing sentences are handed back to Claude, who rewrites and calls again.

Two safeguards: the same tool denied twice within ten minutes in one session goes through on the
third try with the list attached, so an unfixable sentence (a quote, a list of names) cannot loop;
and any error in the check itself lets the call through and is written to errors.log.

Advisory mode (HOUSE_SEND_ADVISE=1): never denies, only attaches the list.
Every check is logged to ~/.claude/writing-check/log.jsonl with the surface (linear, slack, email).
"""
import json, os, sys, time, datetime, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(os.path.expanduser('~'), '.claude', 'writing-check')
LOG = os.path.join(BASE, 'log.jsonl')
STATE = os.path.join(BASE, 'send-state.json')
MIN_WORDS = 15
MAX_DENIALS = 2
WINDOW = 600

def surface_of(tool):
    t = tool.lower()
    if 'slack' in t: return 'slack'
    if re.search(r'(send_message|reply|forward|draft)', t): return 'email'
    if re.search(r'(save_issue|save_comment|save_document|release_note|status_update)', t): return 'linear'
    return 'other'

def long_strings(v, out):
    if isinstance(v, str):
        if len(v.split()) >= MIN_WORDS: out.append(v)
    elif isinstance(v, dict):
        for k, x in v.items():
            if k.lower() in ('id', 'issueid', 'issue_id', 'teamid', 'team_id', 'projectid', 'project_id', 'parentid', 'channel_id', 'channelid', 'thread_ts', 'to', 'cc', 'bcc'): continue
            long_strings(x, out)
    elif isinstance(v, list):
        for x in v: long_strings(x, out)
    return out

def denials(session, tool):
    try: st = json.load(open(STATE))
    except Exception: st = {}
    now = time.time()
    key = f'{session}:{tool}'
    rec = st.get(key, {'n': 0, 'ts': 0})
    if now - rec['ts'] > WINDOW: rec = {'n': 0, 'ts': 0}
    return st, key, rec

def main():
    try: hook = json.load(sys.stdin)
    except Exception: return
    tool = hook.get('tool_name', ''); session = hook.get('session_id', 'unknown')
    texts = long_strings(hook.get('tool_input', {}), [])
    if not texts: return
    from housestyle import check_text, note_for
    text = '\n\n'.join(texts)
    r = check_text(text, strip_quoted=True, surface=surface_of(tool))
    os.makedirs(BASE, exist_ok=True)
    advise = os.environ.get('HOUSE_SEND_ADVISE') == '1'
    st, key, rec = denials(session, tool)
    rec_log = {'ts': datetime.datetime.now().isoformat(timespec='seconds'), 'session': session, 'surface': r['surface'],
               'tool': tool, 'words': r['words'], 'prose': r['prose'], 'prose_fail': r['prose_fail'], 'bullets': r['bullets'],
               'bullet_fail': r['bullet_fail'], 'mode': 'advise' if advise else 'block', 'denials_before': rec['n'], 'items': r['items']}
    with open(LOG, 'a') as fh: fh.write(json.dumps(rec_log, ensure_ascii=False) + '\n')
    if not r['items']:
        if key in st: st.pop(key, None); json.dump(st, open(STATE, 'w'))
        return
    what = {'linear': 'the text going into Linear', 'slack': 'the Slack message', 'email': 'the email'}.get(r['surface'], 'the text being saved')
    note = note_for(r, what)
    if advise or rec['n'] >= MAX_DENIALS:
        st.pop(key, None); json.dump(st, open(STATE, 'w'))
        print(json.dumps({'hookSpecificOutput': {'hookEventName': 'PreToolUse', 'additionalContext': note + ('\nThe call went through after two rewrites.' if not advise else '')}}))
        return
    st[key] = {'n': rec['n'] + 1, 'ts': time.time()}; json.dump(st, open(STATE, 'w'))
    print(json.dumps({'hookSpecificOutput': {'hookEventName': 'PreToolUse', 'permissionDecision': 'deny',
                      'permissionDecisionReason': note + f'\nRewrite those sentences in the same call and send it again (attempt {rec["n"] + 1} of {MAX_DENIALS + 1}; the third goes through).'}}))

if __name__ == '__main__':
    try: main()
    except Exception as e:
        try:
            os.makedirs(BASE, exist_ok=True)
            with open(os.path.join(BASE, 'errors.log'), 'a') as fh: fh.write(f"{datetime.datetime.now().isoformat()} send-check.py {e!r}\n")
        except Exception: pass
