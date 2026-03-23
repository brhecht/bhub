---
name: handoff
description: Project handoff skill for maintaining continuity across devices and sessions. Triggers on "handoff away" (write or amend a single HANDOFF.md file in the project folder) or "handoff here" (find and read the HANDOFF.md file and load full project context). Use this skill whenever the user says "handoff away", "handoff here", or references switching devices, picking up where they left off, or syncing project state.
---

# Handoff Skill

This skill manages project continuity across devices and Cowork sessions by writing and reading a single `HANDOFF.md` file in each project's root folder. One file per repo, amended in place — git history preserves the timeline. No date-stamped filenames, no accumulating files.

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
echo "YOUR_TOKEN" > .git-token && \
echo "Done — all 10 repos cloned and token saved"
```
4. Revoke the PAT at github.com/settings/tokens (token is saved in .git-token for Cowork to use)
5. Mount `~/Developer/B-Suite` in Cowork
6. After setup, update the "Devices set up" list in the master handoff (in bhub) with the device name and date

### Devices Already Set Up
Check the master handoff in bhub (`HANDOFF-MASTER.md`) for the current list. If this device isn't listed, run setup.

## B-Suite Master Handoff Convention

The master B-Suite handoff (`HANDOFF-MASTER.md`) lives in the **bhub** repo root — not at the parent B-Suite directory level. This ensures it's tracked in git and syncs across devices automatically.

- **"handoff away" — ALWAYS update the master too.** Every "handoff away" — whether for a single app or multiple — must also amend that app's section in `HANDOFF-MASTER.md` (in the bhub repo root). This is automatic, not optional. The master is the cross-session index that future "handoff here" sessions rely on. If only the per-app HANDOFF.md is updated, the master goes stale and the next session on a different app gets wrong context. Update the app's section in the master (status, last updated date, key context bullet points) to reflect what changed this session. Commit and push bhub alongside the app repo.
- **"handoff here" for B-Suite / master / all apps:** Look in the bhub repo for `HANDOFF-MASTER.md`. If bhub isn't mounted, ask the user to mount it.
- **Per-app handoffs** are a single `HANDOFF.md` in each app's repo root.

**B-Suite repo locations:** All repos live under `~/Developer/B-Suite/` (local, NOT iCloud). The apps are: things-app, brain-inbox, content-calendar, b-marketing, b-people, b-resources, bhub, eddy, hc-funnel, pitch-scorer. All are git repos under `github.com/brhecht/`.

## Commands

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
- After writing, commit the handoff file to git. If a .git-token exists in the B-Suite root, use it to push. If not, give the user a single copy-paste terminal command to commit and push.
- **Always update the master handoff in bhub** after writing the per-app handoff. Read `HANDOFF-MASTER.md` from the bhub repo, find the section for this app, and update its status, last-updated date, and key context bullets to reflect what changed. Commit and push bhub too. This is part of every "handoff away" — not a separate step the user should have to request.

### "handoff here"

**First: check device setup** (see "B-Suite Device Setup Protocol" above). If the device isn't set up, handle that before proceeding.

**Then:** Look for `HANDOFF.md` in the project's root directory. For the B-Suite master, look for `HANDOFF-MASTER.md` in bhub. Internalize the full context. Then respond with a brief summary of:
1. What this project is
2. Where things stand
3. What the most likely next steps are

Then ask: **"What do you want to work on?"**

**Migration note:** If no `HANDOFF.md` exists but legacy date-stamped files do (e.g., `HANDOFF-BPeople-2026-03-14.md`), read the most recent one, then rename it to `HANDOFF.md` and delete the old dated copies. If nothing exists at all, say so and offer to explore the codebase to build context manually.
