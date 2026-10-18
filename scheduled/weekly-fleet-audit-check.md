---
name: weekly-fleet-audit-check
description: Weekly B-Suite fleet health check — reads bhealth JSON reports from GitHub and posts a summary as a comment on the standing Athena issue ATH-92
---

> **This file is the canonical definition of the weekly fleet audit routine.**
>
> The live registration is a cloud routine named "Weekly fleet audit check",
> Mondays 3:00 AM New York, with the Linear connector attached. Its prompt is
> the text below from "You are running" onward. If you edit the routine, update
> this file too, or the two drift.
>
> History: until Oct 18, 2026 this ran from the Mac Mini as a device-bound
> routine and posted a B Things task. B Things was retired (Focus Machine
> Stage 2), and a device-bound routine's prompt cannot be edited remotely, so
> it was replaced by a cloud routine. The cloud routine cannot see any Mac's
> folders, so the old "live-verify dirty repos on this Mac" step is gone; it
> reports from the bhealth files in GitHub only.
> Last synced: Oct 18, 2026.

You are running the weekly B-Suite fleet health check. Nobody is watching this session, so do not ask questions. Your job is to read the latest bhealth JSON reports from each Mac, summarize the fleet state, and add the findings as a comment on the standing Athena issue ATH-92 "Fleet audit reports".

## Step 1: Get the health reports

The bhealth JSON reports are committed to the public bhub repo. Clone it fresh:

```bash
rm -rf /tmp/bhub-fleet-check && git clone --depth 1 https://github.com/brhecht/bhub.git /tmp/bhub-fleet-check 2>&1 | tail -3
ls /tmp/bhub-fleet-check/.health | tail -40
```

If the clone fails, skip to Step 5 and post a one-line comment saying bhub could not be reached.

## Step 2: Read health reports

From `/tmp/bhub-fleet-check/.health/`, read the most recent JSON file (by filename date) for each device:
- mac-mini-*.json
- imac-*.json
- macbook-pro-*.json
- macbook-air-*.json

## Step 3: Analyze each device

For each device report, extract:
- `device` name
- `timestamp` (when bhealth last ran on that Mac)
- `git_auth_ok` — if false, that is the highest-priority finding for that device
- `repos` — count how many are clean vs dirty vs missing
- `flags` — list all flags, categorized as:
  - **Toolchain-only** (missing node/npm/gh/vercel) — low priority
  - **Repo issues** (dirty, missing, ahead/behind) — medium priority, needs attention
  - **Auth issues** (git auth failed, PAT expired) — high priority, blocking
- `skills` — any missing skill installers

Calculate days since last bhealth run for each device, using today's real date from `date`.

### Staleness flag (system-level rot detection)

bhealth runs automatically every week via the `com.bsuite.bhealth` launchd agent on each Mac (installed via `bhub/install-bhealth.sh`). If a device's most recent report is **older than 8 days**, flag this LOUDLY as an **infra issue**, not a cosmetic note. The likely causes are:

- launchd agent never installed → run `cd ~/Developer/B-Suite/bhub && git pull && bash install-bhealth.sh` on that Mac
- launchd agent installed but failing → check `$BSUITE_DIR/.bhealth-stderr.log` on that Mac
- bsync auto-push failing → check `$BSUITE_DIR/.bsync-stderr.log`
- Mac has been off or asleep (laptops, or a desktop during travel) — note it and re-check next run

**Broken git auth masquerades as agent rot.** A device can run bhealth faithfully and still look silent in bhub if its git auth is broken. You cannot see other Macs' local files from here, so if a report is stale, say the cause is unknown and list both possibilities.

If a device has no health report at all on file, treat that as the same class of problem (launchd never installed).

**Travel and sleep exceptions:** If Brian is away and specific Macs are known to be asleep, their staleness is expected and should be reported as a single quiet line. Any such exception must carry explicit start and end dates, and today's date must be checked against the end date first. There is no active exception as of Oct 18, 2026.

**Known low-use machine:** the iMac is rarely used and is not reliably awake. Its staleness is lower-urgency than the other three, but it still gets reported, and `git_auth_ok: false` on it is always loud.

Because this routine runs in the cloud, it cannot check any Mac's folders live. Report repo flags exactly as the health report gives them and say they are as of the report's timestamp.

## Step 4: Build summary

Write a plain-English summary in this format:

```
Fleet check — [Mon DD]. From GitHub health reports only.

[Device]: clean / [N flags] / [critical issue] — last audited [X days ago]
[Device]: ...
[Device]: ...
[Device]: ...

Infra alerts: [any device with report > 8 days old, or any device with git_auth_ok false, with the likely cause and the one-line fix command; or "None"]
Action needed: [any repo/auth flags requiring attention; or "None"]
```

Keep it under 200 words. Be specific about what needs fixing. The Infra alerts line is the loud signal — staleness or broken auth means the auto-audit pipeline is broken, not just that a Mac was idle.

## Step 5: Post the report to Athena

Post the Step 4 summary as a comment on the standing Athena issue **ATH-92 "Fleet audit reports"** (Linear team Athena, team id `880896f2-4c0d-4c3c-b742-6d9c90025f01`). Use the Linear connector. If its tools are deferred, load their schemas with ToolSearch first (you need `list_comments` and `save_comment`).

1. Call `list_comments` for issue `ATH-92`. If a comment whose first line starts with `Fleet check — [Mon DD]` for today's date already exists, stop: the report is already posted.
2. Otherwise call `save_comment` with `issueId` `ATH-92` and a body that begins with the line `Fleet check — [Mon DD]` followed by the Step 4 summary, unchanged.

Only ever write to ATH-92. Never create other issues and never touch any TNB or CRM team issue.

**If ATH-92 cannot be found or the Linear connector is unavailable, fail loudly.** Do NOT silently skip the post. Make your final message start with `FAILED:` followed by the reason, and include the full summary text so it is not lost.

## Important notes
- This routine reads reports only — it does NOT run bhealth on any Mac. bhealth runs autonomously via the `com.bsuite.bhealth` launchd agent installed by `bhub/install-bhealth.sh`.
- A report > 8 days old, or `git_auth_ok: false`, is an **Infra alert**, not a routine "audit overdue" note. Surface it loudly.
- If bhub can't be reached (network issue), fail gracefully, post the one-line comment from Step 1, and say so in your final message.
- Toolchain flags: the old `/opt/homebrew` hardcode in bhealth.sh was fixed Oct 9 2026 so Intel Macs (the iMac) now find Homebrew at `/usr/local`. Toolchain flags should be rare. If they reappear, something actually regressed.
- The duplicate check in Step 5 means a stray second copy of this routine cannot post a second report for the same date. Only one registration should exist; if another ever appears, disable that one.
- Final message: one line saying which issue got the comment, plus any `FAILED:` reason.
