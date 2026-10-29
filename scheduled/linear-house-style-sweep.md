---
name: linear-house-style-sweep
description: Daily sweep of the previous day's new Linear text in the TNB and TNB CRM teams; rewrites sentences that break HOUSE-STYLE.md in place
---

> **This file is the canonical definition of the daily Linear house-style sweep.**
>
> The live registration is a device-bound scheduled task in the Claude desktop app on the
> MacBook Pro, task id `linear-house-style-sweep`, every day at 07:15 local time (the app adds a
> few minutes of delay and shows it as 07:24), with the Linear connector attached. It is device-bound because it runs the local grammar checker in
> `~/.claude/writing-check/`. It runs while the app is open; if the app is closed at 07:15 it runs
> at the next launch. Its prompt is the text below from "You are running" onward. If you edit the
> task, update this file too, or the two drift.
>
> Created: Oct 29, 2026, with HOUSE-STYLE.md 3.0. Brian chose rewrite-in-place over flagging.

You are running the daily Linear house-style sweep. Nobody is watching this session, so do not ask questions. Your job is to find the text written into Linear in the last 24 hours, check it against the B-Suite house style with the local checker, and rewrite the sentences that fail, changing nothing else.

## Step 1: Preconditions

Check today's real date and time with bash (`date`). Confirm the checker exists: `ls ~/.claude/writing-check/housestyle.py ~/.claude/writing-check/venv/bin/python`. If either is missing, stop and make your final message exactly "FAILED: writing check not installed on this Mac". If no Linear tools are available, stop and make your final message "FAILED: no Linear connector".

Read the rules once: `~/Developer/B-Suite/bhub/HOUSE-STYLE.md`. If that file is missing, clone the public repo and read it from there: `git clone -q --depth 1 https://github.com/brhecht/bhub.git /tmp/bhub-sweep`.

## Step 2: Collect the texts

Teams: "The New Builder" (key TNB) and "TNB CRM" (key CRM). Never touch the Athena team.

Collect, for the last 24 hours:
1. Issues updated in the window (`list_issues` with `updatedAt` set to `-P1D`, one call per team). For each, the `description`.
2. Comments created in the window on those issues and on any other issue in the two teams (`list_comments` with `createdAt` `-P1D` where the tool supports it; otherwise list comments on the issues from step 1 and keep those created in the window). For each, the `body`.
3. Documents updated in the window in the two teams or their projects (`list_documents` with `updatedAt` `-P1D`). For each, the `content`.

Keep only texts of fifteen words or more. Stop collecting at 25 texts; if there were more, say so in the final message.

## Step 3: Check each text

Write the text to a temp file and run the checker:

```bash
~/.claude/writing-check/venv/bin/python -W ignore ~/.claude/writing-check/housestyle.py --strip-quotes --log linear-sweep --session sweep < /tmp/sweep-text.md
```

The JSON has `items`, one per failing sentence, each with `kinds` naming the catalogue entries it breaks and `s` holding the sentence. An empty `items` means the text passes; move on.

## Step 4: Rewrite the failing sentences

For a text with failing sentences, produce a new version with these rules:
- Rewrite only the sentences in `items`. Every other character stays byte-identical: markdown, links, @mentions, issue identifiers, code, lists, headings, tables, names, numbers, dates.
- A rewrite states the same fact with a stated subject and a literal verb, following HOUSE-STYLE.md. It never adds a fact, drops a fact, or changes a decision, a date, a number, an owner or a name. If a sentence cannot be rewritten without guessing at a fact, leave it as it is and report it.
- Text inside a quote block (lines starting with `>`) or inside quotation marks is someone's words and is never changed.
- Run the checker again on the new version. It must report fewer failing sentences than before; if it does not, leave the original in place and report it.

## Step 5: Save

Save the new version back with the matching tool: `save_issue` with the issue id and the new `description` only; `save_comment` with the comment id and the new `body`; `save_document` with the document id and the new `content`. Change no other field: not the title, status, assignee, labels, dates or project. Never delete anything. A save-and-send hook checks the saved text again; if it denies the save, rewrite the sentences it names and save once more.

## Final message, in this format and nothing else

TEXTS CHECKED: the count, by kind (issues, comments, documents), and the teams
REWRITTEN: each text by identifier (TNB-123, comment on TNB-123, document title) with the number of sentences changed; or "none"
LEFT ALONE: each text that failed but could not be rewritten without guessing, with the sentence; or "none"
OVER LIMIT: "yes, N texts not checked" or "no"
ERRORS: any tool or checker error; or "none"
