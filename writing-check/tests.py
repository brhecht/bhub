#!/usr/bin/env python3
"""Tests for housestyle.py against the broken and repaired sentences in HOUSE-STYLE.md and the audit.
Run: venv/bin/python -W ignore tests.py    Exits 1 if any expectation fails."""
import sys
from housestyle import classify, check_text

BROKEN = [  # (sentence, expected kind among the kinds returned)
    ("Pushed.", 'no-subject'),
    ("Found the memo on the Composio stack as a Linear document.", 'no-subject'),
    ("Worth knowing which is which before you keep going.", 'no-subject'),
    ("Want me to prove it end to end?", 'no-subject'),
    ("Drafted, awaiting review.", 'no-subject'),
    ("Writing the revised skill now.", 'no-subject'),
    ("Still wrong.", 'no-verb'),
    ("No advantage.", 'no-verb'),
    ("Small, pleasant, not urgent.", 'no-verb'),
    ("Blocked on assets.", 'no-subject'),
    ("Two changes.", 'count-first'),
    ("Three things it costs you, though, and one gap.", 'count-first'),
    ("Six real fixes.", 'count-first'),
    ("That is the easy half and Composio handles it.", 'that-is'),
    ("That's by design in the skill.", 'that-is'),
    ("It's the reason the piece exists.", 'that-is'),
    ("This is ready once the assets land.", 'that-is'),
    ("This rule is a rule, not a mechanism.", 'not-tail'),
    ("The clean fix is on the Gmail side, not Composio.", 'not-tail'),
    ("The fix is not willpower, it is the system you already built.", 'not-tail'),
    ("Due date is the publish date, not the writing deadline.", 'not-tail'),
    ("The link is sitting in the asymmetry between your two days.", 'metaphor-verb'),
    ("Then the pin becomes redundant instead of load-bearing.", 'metaphor-verb'),
    ("Leipzig announced itself as the hard part.", 'metaphor-verb'),
    ("Composio's multi-account Gmail only earns its keep if you want Claude to send as the other addresses on its own.", 'metaphor-verb'),
    ("So: hygiene, and low-value hygiene at that.", 'label-line'),
    ("Real answer: the master handoff should live in a git repo too.", 'label-line'),
    ("Status: drafted.", 'label-line'),
    ("A chat is pull-only, which is why everything today runs on a clock.", 'which-clause'),
    ("That is his call as much as yours, which is why I did not just do it.", 'which-clause'),
    ("One thing I want to be honest about rather than let stand as reassurance.", 'confessional'),
    ("My honest read: the gain for you is latency.", 'confessional'),
    ("Not quite, and I would rather be straight than send you off feeling finished.", 'grade-first'),
    ("Almost, but not quite.", 'grade-first'),
    ("One structural thing worth naming before you go on.", 'announced-aside'),
    ("There are two things worth knowing while it runs.", 'announced-aside'),
    ("Here's where things stand: the quiz is live and the ad is paused.", 'reveal-opener'),
    ("I pushed it — the first four columns are now three times as wide.", 'em-dash'),
    ("Eleven repos pulled (auto-falls back to the temp clones when the mounted drive has EPERM).", 'parenthetical'),
    ("That's fragile.", 'bare-verdict'),
    ("The plan is the plan.", 'bare-verdict'),
    ("Nothing else was changed, and my Chrome tab is closed.", 'conduct-report'),
    ("I left it alone rather than edit B-Suite docs outside the handoff flow.", 'conduct-report'),
    ("You're right on both counts.", 'agreement-opener'),
    ("Good call, my miss.", 'agreement-opener'),
    ("That is Claude's job, not yours.", 'third-person'),
]
REPAIRED = [
    "I pushed the change to bhub.",
    "I found the memo on the Composio stack.",
    "Before you keep going, you should know which change helps and which two hurt.",
    "Do you want me to prove it end to end?",
    "I drafted the post.",
    "It is waiting for Brian's review.",
    "The paragraph is still wrong.",
    "Composio's browser has no advantage over your Chrome.",
    "It is small and pleasant, and it is not urgent.",
    "This issue is blocked until Nico sends the thumbnail.",
    "I changed two things.",
    "The new version weakens three things and leaves one gap.",
    "I found six errors.",
    "Watching the app for changes is the easy half, and Composio handles it.",
    "The skill keeps old handoff files on purpose.",
    "The Leipzig story is the reason the piece exists.",
    "The page is ready to review once the thumbnail arrives.",
    "This rule exists only in the skill text.",
    "Nothing in Linear enforces it.",
    "The clean fix is in Gmail's settings.",
    "The system you already built is the fix.",
    "The due date on this issue is the publish date.",
    "Saturday produced a story and Sunday produced nothing you can point at.",
    "Then the pinned note is a backup instead of the only reminder.",
    "Leipzig looked like the hard part from the start.",
    "The remaining work is hygiene, and low-value hygiene.",
    "The master handoff should also be in a git repo.",
    "I drafted the page.",
    "A chat only shows what someone asks for.",
    "For that reason everything today runs on a clock.",
    "Nico decides this as much as you do, so I did not do it without asking.",
    "I do not want the last paragraph read as reassurance, so I will say it plainly.",
    "The gain for you is speed.",
    "The last paragraph has to go.",
    "The intro and the close make the same claim, so one of them should go.",
    "The quiz is live, the ad is paused, and the landing page still shows the old price.",
    "I pushed it.",
    "The first four columns are now three times as wide as the last two.",
    "A local-only file will drift the next time you work from another machine.",
    "Nothing in today's results changes the plan.",
    "I did not edit the B-Suite docs.",
    "The handoff skill owns them.",
    "The file is on the Air, and the token in it expires on November 29.",
    "I missed the second file.",
    "That is my job.",
    "That was my mistake.",
    "Check this before 7.",
    "Build Nico's installer.",
    "Run those two commands and paste me the output.",
    "Look at this line on your editing pass.",
    "Bring the branch up to date with main, then raise the version number in skills-manifest.json.",
    "The writing check is already running in this session.",
    "Your worry is right, and the fix is to separate two questions that the current setup has merged.",
    "I ran the installer from the bhub repo in a terminal tab.",
]

def main():
    bad = 0
    for s, want in BROKEN:
        got = classify(s, is_last=False)
        if want not in got:
            bad += 1; print(f"MISS   want {want:16} got {got or '-'}  | {s}")
    for s in REPAIRED:
        got = classify(s, is_last=False)
        if got:
            bad += 1; print(f"FALSE  {got}  | {s}")
    # Reply-level checks: trailing offer, bold label, label line, numbers in prose, stitch.
    r = check_text("I pushed it.\n\n**Mode:** Auto, inherited from this session.\n\nTwo changes.\nSo the DM half stays in Chrome.\n\nYour Today lane has 10 cards: ATH-16, ATH-24, ATH-25.\n\nThe files I changed:\n\nWant me to go ahead?")
    kinds = {k for it in r['items'] for k in it['kinds']}
    for want in ('bold-label', 'stitch', 'numbers-in-prose', 'label-line', 'trailing-offer', 'count-first'):
        if want not in kinds: bad += 1; print(f"MISS   reply-level {want}: {kinds}")
    r2 = check_text("The files are:\n\n- one.md\n- two.md\n\nThe check skips quoted text.\n\n> Pushed. Worth a look.\n\nNico wrote \"worth knowing which is which before you keep going\" in the issue.", strip_quoted=True)
    if r2['items']: bad += 1; print(f"FALSE  reply-level: {r2['items']}")
    print(f"{len(BROKEN)} broken, {len(REPAIRED)} repaired, 2 reply-level blocks; {bad} failures")
    sys.exit(1 if bad else 0)

if __name__ == '__main__':
    main()
