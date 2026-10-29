---
name: weekly-writing-check
description: Sunday review of the house-style check log on this Mac; Brian's Macs comment on the Athena issue "Weekly writing check", Nico's Mac sends the review to Brian as a Slack DM
---

> **This file is the canonical definition of the weekly writing check.**
>
> It runs as a device-bound scheduled task in the Claude desktop app on each Mac that has the
> writing check installed: Sundays at 07:06 local time, task id `weekly-writing-check`. It is
> device-bound because the log it reads is local. Brian's MacBook Air has had a version of it since
> Oct 25, 2026; the MacBook Pro and Nico's Mac register it from this file. To register it, paste
> into Claude Code: "Read scheduled/weekly-writing-check.md in the bhub checkout and create the
> scheduled task it describes, Sundays at 7:06am." The prompt is the text below from "You are
> running" onward. If you edit the task, update this file too, or the two drift.
>
> Last synced: Oct 29, 2026 (HOUSE-STYLE.md 3.0; the log now also holds save-and-send checks and
> Linear sweep results, which the review counts by surface).

You are running the weekly writing check. Nobody is watching this session, so do not ask questions.

1. Check today's real date with bash. Run the review:
   ```bash
   ~/.claude/writing-check/venv/bin/python -W ignore ~/.claude/writing-check/review.py 14
   ```
   If the script or its folder is missing, stop and make your final message exactly "FAILED: writing check not installed on this Mac". The output is markdown: the failing-sentence rate over the trailing fourteen days, the rate by surface when more than one surface was logged (code replies, Linear, Slack, email, the Linear sweep), the failing kinds, five failing sentences, and any sentences flagged by hand.
2. Work out whose Mac this is from the `<user>` tag in your context (Name and Email). Add one line at the top of the review: "Writing check for <Name>'s Mac (<hostname from `hostname`>), <today's date>."
3. Deliver it.
   - If the user is Brian: add the review as a comment on the Athena issue titled "Weekly writing check" (search the Athena team by title; create the issue if it does not exist), and append it to `~/Developer/B-Suite/bsuite-handoffs/personal/claude-speak-reviews.md` under a dated heading, then commit and push that repo with the message "writing check: <date>".
   - If the user is Nico: send the review to Brian as a Slack direct message with the Slack connector (Brian's Slack user is the one named Brian Hecht in the TNB workspace). If Slack is not connected, send it by email to brhnyc1970@gmail.com with the subject "Weekly writing check, Nico's Mac, <date>".
4. If the combined rate is above 8 percent for the second review in a row, say so in one line at the end of the review: "Two reviews above 8 percent: decide on blocking mode for long replies."

Final message, in this format and nothing else:
RATE: the combined failing rate and the number of sentences, plus the rate per surface if more than one
DELIVERED: where the review went (the Athena issue and the handoffs file, or the Slack DM or email); or what failed
TOP KINDS: the three most common failing kinds
