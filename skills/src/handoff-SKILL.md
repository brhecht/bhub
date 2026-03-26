---
name: handoff
description: "Project handoff skill for maintaining continuity across devices and sessions. Triggers on \"handoff away\" (write or amend a single HANDOFF.md file in the project folder) or \"handoff here\" (find and read the HANDOFF.md file and load full project context). Use this skill whenever the user says \"handoff away\", \"handoff here\", or references switching devices, picking up where they left off, or syncing project state. Also triggers when the user starts a session and mentions any B-Suite app by name — treat that as an implicit \"handoff here\" for that app."
---

# Handoff Skill

This skill manages project continuity across devices and Cowork sessions by writing and reading a single `HANDOFF.md` file in each project's root folder. One file per repo, amended in place — git history preserves the timeline. No date-stamped filenames, no accumulating files.

## Architecture: What Lives Where

Understanding the hierarchy prevents the #1 failure mode (stale context):

- **`HANDOFF-MASTER.md`** lives in the **bhub** repo root. It's the cross-session index — a summary of every app's status, last-updated date, and key context. Think of it as the table of contents.
- **Per-app `HANDOFF.md`** files live in each repo's root. These are the chapters — full detail on one app.
- **GitHub is the source of truth**, not the mounted drive. The mounted drive is a convenience for reading/writing, but it's only as fresh as the last `git pull` on this device. A session on a different device may have pushed updates that this device hasn't fetched yet.

This means: never trust a local file's "last updated" date without verifying against GitHub. The cross-check protocol below handles this automatically.

## B-Suite Device Setup Protocol

Before doing anything else on a "handoff here", check whether the B-Suite repos exist on this machine. The repos should be at `~/Developer/B-Suite/`. If the mounted folder is at a different path (e.g., `~/Desktop/B-Suite`) or if `~/Developer/B-Suite/` doesn't exist, this device needs one-time setup.

### Detection
- If the user mounts `~/Developer/B-Suite` and repos are present → device is set up. Proceed normally.
- If the user mounts `~/Desktop/B-Suite` → tell them: "The B-Suite repos moved to ~/Developer/B-Suite on March 12. Desktop/B-Suite is deprecated (iCloud, stale git repos). Let's mount the Developer folder instead."
- If `~/Developer/B-Suite` doesn't exist → this is a new device. Walk them through setup below.

### New Device Setup (One-Time)
Walk the user through these steps. They should not need to touch terminal except to paste one block:

1. Open Terminal and paste:
```bash
mkdir -p ~/Developer/B-Suite
```
2. Go to github.com/settings/tokens → Generate new token (classic) → name "B-Suite Cowork" → check `repo` scope → set expiration (90 days recommended)
3. Copy the token and paste this block in Terminal (replacing YOUR_TOKEN):
```bash
cd ~/Developer/B-Suite && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/things-app.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/brain-inbox.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/content-calendar.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/b-marketing.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/eddy-tracker.git eddy && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/bhub.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/b-people.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/b-resources.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/pitch-scorer.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/hc-funnel.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/hc-strategy.git && \
echo "YOUR_TOKEN" > .git-token && \
echo "Done — all 11 repos cloned and token saved"
```
4. Revoke the PAT at github.com/settings/tokens (token is saved in .git-token for Cowork to use)
5. Mount `~/Developer/B-Suite` in Cowork
6. After setup, update the "Devices set up" list in the master handoff (in bhub) with the device name and date

### Devices Already Set Up
Check the master handoff in bhub (`HANDOFF-MASTER.md`) for the current list. If this device isn't listed, run setup.

## B-Suite Repo Registry

All repos live under `~/Developer/B-Suite/` (local, NOT iCloud). All are git repos under `github.com/brhecht/`.

| Repo folder | GitHub repo | App keywords (for auto-detection) |
|-------------|------------|----------------------------------|
| things-app | brhecht/things-app | things, tasks, kanban, task board |
| brain-inbox | brhecht/brain-inbox | brain inbox, nico, b nico, nicoOS |
| content-calendar | brhecht/content-calendar | content, calendar, content calendar, youtube, linkedin, beehiiv |
| b-marketing | brhecht/b-marketing | marketing, b marketing |
| b-people | brhecht/b-people | people, contacts, relationships, reach out, nudge, b people |
| b-resources | brhecht/b-resources | resources, library, vault |
| bhub | brhecht/bhub | hub, b hub, suite, master |
| eddy | brhecht/eddy-tracker | eddy, tracker, course launch, gantt |
| hc-funnel | brhecht/hc-funnel | funnel, quiz, ads, meta ads, landing page, pitch assessment |
| hc-strategy | brhecht/hc-strategy | hc strategy, operating plan, revenue model (private — Brian only) |
| pitch-scorer | brhecht/pitch-scorer | pitch scorer (archived) |

## Commands

### "handoff here"

This is the session bootstrap. It has three jobs: (1) sync the master to ground truth, (2) load context for the app the user wants to work on, (3) clean up legacy files.

**The user does NOT need to specify which app.** They can say "handoff here" and then start talking about what they want to do, or they can say "handoff here b-people" explicitly. Either works. If they don't specify, show them a quick status summary from the master and ask what they want to work on. If they mention something that maps to an app (via the keyword table above), load that app's handoff automatically.

#### Step 1: Pull bhub and read the master

```bash
cd <bhub-path> && rm -f .git/index.lock .git/ORIG_HEAD.lock && git checkout -- . && git clean -fd && git pull
```

Read `HANDOFF-MASTER.md`. This gives you the cross-app index.

#### Step 2: Cross-check master against GitHub

This is the critical step that prevents stale context. The mounted drive may be behind GitHub. The master itself may be behind individual per-app handoffs (if a prior session updated one but not the other).

For every app listed in the master, check whether GitHub has a newer HANDOFF.md than what the master claims. The fastest way is to clone bare repos to `/tmp/`:

```bash
cd /tmp && git clone --bare https://github.com/brhecht/<repo>.git <repo>-check 2>/dev/null
git -C /tmp/<repo>-check log -1 --format="%ai %s" -- HANDOFF.md 2>/dev/null
```

Compare the dates from GitHub against what the master claims as "last updated" for each app. If any per-app handoff on GitHub is newer than the master's date:

1. Clone that repo (or pull if mounted copy works) and read the newer HANDOFF.md
2. Update the master's section for that app with current status, date, and key context
3. Push the updated master to GitHub
4. Tell the user what you found: "B People's handoff was updated on March 23 from another device — I've synced the master."

This catches two failure modes: (a) a prior session updated a per-app handoff but not the master, and (b) the mounted drive is simply behind GitHub because another device pushed changes.

**Performance note:** You don't need to check every repo every time. Prioritize: the repo the user wants to work on, any repos the master shows as recently active (last 2 weeks), and any repos the user mentions. Skip archived/dormant repos (pitch-scorer, b-resources) unless specifically asked.

#### Step 3: Check device setup

See "B-Suite Device Setup Protocol" above. If the device isn't set up, handle that before proceeding.

#### Step 4: Load app context

Once you know which app the user wants:

1. Pull that repo from GitHub (always — don't trust the local copy):
   ```bash
   cd <repo-path> && git fetch origin && git reset --hard origin/main
   ```
   If that fails due to EPERM on the mounted volume, clone to `/tmp/` and read from there.

2. Read the app's `HANDOFF.md`
3. Internalize cross-app context from the master (shared infra, deploy safety, user registry)
4. Respond with a brief summary:
   - What this project is
   - Where things stand
   - What the most likely next steps are

Then ask: **"What do you want to work on?"**

#### Step 5: Clean up legacy files

If the app's repo has legacy date-stamped handoff files (e.g., `HANDOFF-BPeople-2026-03-14.md`) alongside a proper `HANDOFF.md`, delete the dated copies and commit. The migration to single-file handoffs is complete — dated files are just clutter now.

### "handoff away"

Write or amend a single `HANDOFF.md` file in the project's root directory. If one already exists, update it in place — don't create a new file. This should be a comprehensive snapshot of everything a fresh Claude session would need to be fully productive immediately.

**Gather this information from the current session context, codebase, and conversation history. Ask the user to fill gaps only if critical information is genuinely unavailable.**

Write the file with these sections:

```
# HANDOFF — [Project Name]
*Last updated: [date and time]*

## Project Overview
What this app/project is, who it's for, core purpose and goals.

## Tech Stack
Frameworks, libraries, languages, hosting, deployment platform, database, key dependencies.

## Folder Structure
Key files and directories with brief descriptions of what they do. Not exhaustive — focus on what matters.

## Current Status
What's working, what's partially built, what's broken. Overall project phase.

## Recent Changes
What specifically happened in this session. What was added, changed, fixed, or attempted.

## Known Bugs / Issues
Anything broken, degraded, or behaving unexpectedly.

## Planned Features / Backlog
Features discussed but not yet built. Prioritize if possible.

## Design Decisions & Constraints
Important "why we did it this way" context. Architectural choices, tradeoffs, user preferences.

## Environment & Config
API keys (reference only, not values), env variables, deployment targets, live URLs, database locations.

## Open Questions / Decisions Pending
Things that need the user's input before proceeding.
```

**Rules:**
- Be specific and concrete, not vague. "Fixed the date picker bug on the settings page" not "Made some fixes."
- If a section has nothing to report, write "None" — don't omit the section.
- Always amend the existing `HANDOFF.md` in place. Never create date-stamped copies — git history preserves the timeline if you ever need to look back.
- When amending, update the "Last updated" timestamp and revise all sections to reflect current state. Don't just append — the file should always read as a clean, current snapshot.
- If you created or significantly modified any documents during the session that a future session would need to understand the project state, make sure they are referenced in HANDOFF.md.
- After writing, commit the handoff file to git. If a .git-token exists in the B-Suite root, use it to push. If not, give the user a single copy-paste terminal command to commit and push.

#### Multi-app sessions

If you touched multiple repos during the session (e.g., worked on b-people and also modified something in things-app), hand off ALL of them. Track which repos you modified during the session and update each one's HANDOFF.md.

#### Master update (mandatory — part of every handoff away)

After writing per-app handoffs, ALWAYS update the master:

1. Read `HANDOFF-MASTER.md` from bhub
2. Find the section for each app you're handing off
3. Update status, last-updated date, and key context bullets to reflect what changed
4. Commit and push bhub

This is part of every "handoff away" — not a separate step the user should have to request. If the master update fails (network issues, lock files), tell the user explicitly so it can be fixed. A handoff away without a master update is incomplete.

#### Verification step

After pushing both the per-app handoff and the master update, do a quick sanity check: does the master's "last updated" date for this app match the per-app HANDOFF.md's timestamp? If not, something went wrong — fix it before declaring the handoff complete.
