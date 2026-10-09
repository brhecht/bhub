---
name: weekly-fleet-audit-check
description: Weekly B-Suite fleet health check — reads bhealth JSON reports from GitHub and posts a summary to B Things
---

> **This file is the canonical definition of the weekly fleet audit task.**
>
> Claude's scheduled tasks are stored per-machine at
> `~/Documents/Claude/Scheduled/<taskId>/SKILL.md` and are NOT synced between
> Macs. This copy lives in bhub so every Mac can reach it via bsync.
>
> **Designated host: the Mac Mini.** It is the only machine that is reliably
> awake at the 3:00 AM Monday run time. To install it there, open Cowork on the
> Mini and say: *"Create a weekly scheduled task from
> `~/Developer/B-Suite/bhub/scheduled/weekly-fleet-audit-check.md`, Mondays at
> 3am."*
>
> If you edit the task on a machine, update this file too, or the two drift.
> Last synced: Oct 9, 2026.

You are running the weekly B-Suite fleet health check. Your job is to read the latest bhealth JSON reports from each Mac, summarize the fleet state, and create a B Things task with the findings.

## Path rule (read first)

Every bash call starts in `/sessions/<session>`, so `$PWD` is the session root and the mounted Developer folder is always `$PWD/mnt/Developer`.

**Never use `/sessions/$(ls /sessions)/...`.** There are often a hundred-plus session directories on this machine, so that expands to garbage and the command fails. Use `$PWD` everywhere.

## Step 1: Pull latest bhub

Run bsync to get the latest bhub repo (which contains .health/ JSON files committed by bhealth runs on each Mac):

```bash
BSUITE_DIR="$PWD/mnt/Developer/B-Suite" timeout 100 bash "$PWD/mnt/Developer/B-Suite/bhub/bsync.sh" 2>/dev/null | tail -5
```

If that times out, errors, or returns nothing useful, go straight to the clone fallback. Do not retry bsync — on a machine with broken git auth it will hang every time.

```bash
rm -rf /tmp/bhub-fleet-check && git clone --depth 1 https://github.com/brhecht/bhub.git /tmp/bhub-fleet-check 2>&1 | tail -3
```

## Step 2: Read health reports

Read all JSON files from bhub/.health/:
- mac-mini-*.json (most recent)
- imac-*.json (most recent)
- macbook-pro-*.json (most recent)
- macbook-air-*.json (most recent)

From `/tmp/bsync-*/bhub/.health/` if bsync succeeded, or `/tmp/bhub-fleet-check/.health/` if you cloned directly.

For each device, find the most recent JSON file (by filename date) and read it.

## Step 3: Analyze each device

For each device report, extract:
- `device` name
- `timestamp` (when bhealth last ran on that Mac)
- `git_auth_ok` — if false, that is the highest-priority finding for that device
- `repos` — count how many are clean vs dirty vs missing
- `flags` — list all flags, categorized as:
  - **Toolchain-only** (missing node/npm/gh/vercel) — low priority, cosmetic
  - **Repo issues** (dirty, missing, ahead/behind) — medium priority, needs attention
  - **Auth issues** (git auth failed, PAT expired) — high priority, blocking
- `skills` — any missing skill installers

Calculate days since last bhealth run for each device.

### Staleness flag (system-level rot detection)

bhealth runs automatically every week via the `com.bsuite.bhealth` launchd agent on each Mac (installed via `bhub/install-bhealth.sh`). If a device's most recent report is **older than 8 days**, flag this LOUDLY as an **infra issue**, not a cosmetic note. The likely causes are:

- launchd agent never installed → run `cd ~/Developer/B-Suite/bhub && git pull && bash install-bhealth.sh` on that Mac
- launchd agent installed but failing → check `$BSUITE_DIR/.bhealth-stderr.log` on that Mac
- bsync auto-push failing → check `$BSUITE_DIR/.bsync-stderr.log`
- Mac has been off or asleep (laptops, or a desktop during travel) — note it and re-check next run

**Distinguish "not running" from "running but not pushing."** A device can run bhealth faithfully every day and still look silent in bhub if its git auth is broken. Before calling a device rotted, check whether recent reports for it exist locally but unpushed:

```bash
ls "$PWD/mnt/Developer/B-Suite/bhub/.health/" | tail -20
cd "$PWD/mnt/Developer/B-Suite/bhub" && timeout 20 git --no-optional-locks status --short 2>/dev/null | grep '.health/'
```

If recent reports for a device exist locally as untracked or uncommitted files, the agent is fine and the push is broken. Report it as an auth failure, not agent rot, and say so plainly.

In the Step 4 summary, surface staleness as a separate **Infra alert** line, not lumped in with toolchain flags.

If a device has no health report at all on file, treat that as the same class of problem (launchd never installed).

**Travel and sleep exceptions:** If Brian is away and specific Macs are known to be asleep for the duration, their staleness is expected and should be reported as a single quiet line rather than a loud alert. Any such exception must carry explicit start and end dates. **Before applying one, check today's date against its end date. If the window has passed, ignore the exception entirely and report normally.** Do not leave an expired exception in force.

There is no active exception as of this revision (Oct 9, 2026).

**Known low-use machine:** the iMac is rarely used and is not reliably awake. Its staleness is lower-urgency than the other three, but it still gets reported, and `git_auth_ok: false` on it is always loud.

## Step 3b: Live-verify local repo flags

This machine's Developer folder is mounted at `$PWD/mnt/Developer/`. Work out which device this is — read the local `bhealth` output or match the `device` name in the report whose `hostname` matches this machine — and state in your summary which Mac you are running on. If that device's report flags any repos as dirty, verify them live before reporting, because the report may be stale:

```bash
cd "$PWD/mnt/Developer/B-Suite/[repo-name]" && timeout 20 git --no-optional-locks status --short 2>/dev/null
```

Only report a repo as dirty if `git status --short` confirms it still has uncommitted changes. If it's clean, drop the flag silently — do not mention it.

You can only live-verify the machine you are running on. Flags on other devices are reported as the report gives them. Say which is which.

## Step 4: Build summary

Write a plain-English summary in this format:

```
Fleet check — [date]. Running on [device].

[Device]: clean / [N flags] / [critical issue] — last audited [X days ago]
[Device]: ...
[Device]: ...
[Device]: ...

Infra alerts: [any device with report > 8 days old, or any device with git_auth_ok false, with the likely cause and the one-line fix command; or "None"]
Action needed: [any confirmed repo/auth flags requiring attention; or "None"]
```

Keep it under 200 words. Be specific about what needs fixing. The Infra alerts line is the loud signal — staleness or broken auth means the auto-audit pipeline is broken, not just that a Mac was idle.

## Step 5: Load B Things API key

The `/api/add-task` endpoint requires `x-api-key: <API_SECRET>`. Try both sources in order:

```bash
API_KEY=$(grep -E "^API_SECRET=" "$PWD/mnt/Developer/B-Suite/things-app/.env.local" 2>/dev/null | cut -d= -f2-)
if [ -z "$API_KEY" ] && [ -f "$PWD/mnt/Developer/B-Suite/.bthings-key" ]; then
  API_KEY=$(tr -d ' \t\n\r' < "$PWD/mnt/Developer/B-Suite/.bthings-key")
fi
if [ -n "$API_KEY" ]; then echo "KEY_FOUND len=${#API_KEY}"; else echo "KEY_MISSING"; fi
```

`.env.local` holds it as `API_SECRET=<value>`; `.bthings-key` holds the same secret as a bare value with no key name.

**If neither exists or `API_KEY` is empty, fail loudly.** Do NOT silently skip the B Things post. Write the summary to `/Users/BRHPro/Developer/fleet-check-[YYYY-MM-DD].md` as a fallback, and surface the missing-key error clearly in your response. Tell Brian to run `cd ~/Developer/B-Suite/things-app && vercel env pull .env.local` to restore it. Never print the key value itself.

## Step 6: Create B Things task

POST to https://things-app-gamma.vercel.app/api/add-task with the loaded key:

```bash
curl -sS -X POST https://things-app-gamma.vercel.app/api/add-task \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d '{
    "title": "Fleet check — [Mon DD]",
    "notes": "[your summary]",
    "project": "Infra",
    "idempotencyKey": "fleet-check-[YYYY-MM-DD]"
  }'
```

Expect `{"ok":true, ...}` on success. If you get `{"error":"Unauthorized"}`, the key is stale — same fallback path as Step 5.

## Important notes
- This task reads reports only — it does NOT run bhealth on any Mac. bhealth runs autonomously via the `com.bsuite.bhealth` launchd agent installed by `bhub/install-bhealth.sh`.
- Use `$PWD`, never `/sessions/$(ls /sessions)/...`. See the path rule at the top.
- Local repo flags must be live-verified (Step 3b) before being reported. Never report a flag from a stale bhealth report without confirming it still exists on the machine you are running on.
- A report > 8 days old, or `git_auth_ok: false`, is an **Infra alert** (the autonomous pipeline is broken on that Mac), not a routine "audit overdue" note. Surface it loudly. Check any travel exception's end date before honouring it.
- Broken git auth masquerades as agent rot. Check for unpushed local reports before blaming the launchd agent.
- If bhub can't be reached (network issue), fail gracefully and skip the B Things post.
- Toolchain flags: the old `/opt/homebrew` hardcode in bhealth.sh was fixed Oct 9 2026 so Intel Macs (the iMac) now find Homebrew at `/usr/local`. Toolchain flags should therefore be rare. Do not wave them away as "expected on iMac and Air" any more — if they reappear, something actually regressed.
- Auth failures on `/api/add-task` are loud, not silent — Brian needs to know the secret is broken so he can rotate it.
- The `idempotencyKey` means a duplicate copy of this task on another Mac cannot create a second card on the same date. **The Mac Mini is the designated host.** If a copy on another Mac ever runs, disable that one, not the Mini's.
