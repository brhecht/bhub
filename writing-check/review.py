#!/usr/bin/env python3
"""Weekly review: failing-sentence rate over the trailing 14 days, against Brian's own rates
from the Oct 2026 audit. Usage: review.py [days]  (default 14). Prints markdown."""
import json, os, sys, datetime, collections
BASE = os.path.join(os.path.expanduser('~'), '.claude', 'writing-check'); LOG = os.path.join(BASE, 'log.jsonl')
days = int(sys.argv[1]) if len(sys.argv) > 1 else 14
since = datetime.datetime.now() - datetime.timedelta(days=days)
recs = []
if os.path.exists(LOG):
    for line in open(LOG):
        try: d = json.loads(line)
        except Exception: continue
        if datetime.datetime.fromisoformat(d['ts']) >= since: recs.append(d)
auto = [r for r in recs if not r.get('manual')]; manual = [r for r in recs if r.get('manual')]
prose = sum(r['prose'] for r in auto); fail = sum(r['prose_fail'] for r in auto)
kinds = collections.Counter(it['kind'] for r in auto for it in r['items'] if it['ctx'] == 'prose')
today = datetime.date.today().isoformat()
print(f"## Writing check, {today}, trailing {days} days\n")
if not auto:
    print("No replies were logged in this window. Either no Claude Code sessions ran on this Mac, or the hook is not firing (check ~/.claude/settings.json and ~/.claude/writing-check/errors.log)."); sys.exit()
rate = 100 * fail / prose if prose else 0
clean = sum(1 for r in auto if r['prose_fail'] == 0)
print(f"Replies checked: {len(auto)}. Prose sentences: {prose}. Failing: {fail} ({rate:.1f}%). Replies with no failure: {clean} of {len(auto)}.")
print("Brian's own rates from the Oct 24 2026 audit, for comparison: dropped subject 1.7%, demonstrative opener 1.7%, not-tail 0.6%, about 4% combined. Claude's baseline before the rules: about 25% combined.\n")
print("Failures by kind:")
for k, n in kinds.most_common(): print(f"- {k}: {n}")
worst = sorted((it['s'] for r in auto for it in r['items'] if it['ctx'] == 'prose'), key=len)[:5]
print("\nFive failing sentences, shortest first:")
for s in worst: print(f"- {s}")
if manual:
    print(f"\nSentences Brian flagged by hand ({len(manual)}):")
    for r in manual:
        for it in r['items']: print(f"- [{r['surface']}] {it['s']}" + (f"  ({it['note']})" if it.get('note') else ''))
print("\nIf the combined rate is above 8% for two reviews in a row, turn on blocking for long replies (BRIAN_WRITING_BLOCK=1 in the hook command) or revisit the principle in WRITING-TO-BRIAN.md.")
