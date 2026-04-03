---
name: handoff
description: "Project handoff skill for maintaining continuity across devices and sessions. Triggers on \"handoff away\" (write or amend a single HANDOFF.md file in the project folder) or \"handoff here\" (find and read the HANDOFF.md file and load full project context). Use this skill whenever the user says \"handoff away\", \"handoff here\", or references switching devices, picking up where they left off, or syncing project state. Also triggers when the user starts a session and mentions any B-Suite app by name — treat that as an implicit \"handoff here\" for that app."
---

# Handoff Skill

This skill manages project continuity across devices and Cowork sessions. It uses three layers of resilience:

1. **bsync.sh** (the belt) — a bash script that pulls all repos from GitHub, cross-checks handoff freshness against git history, checks skill versions, and outputs a structured JSON report. Claude runs this once at session start. It works regardless of what the previous session did or didn't do.
2. **Stamp-on-push** (the belt+) — lightweight context stamps appended to HANDOFF.md on meaningful pushes during a session. Captures intent, known issues, and next steps that git commits alone can't convey.
3. **Handoff away** (the suspenders) — a full handoff rewrite when the user explicitly requests it. Captures rich context. The system doesn't break if this is skipped — bsync + stamps cover the gap.

## Architecture: What Lives Where

- **`HANDOFF-MASTER.md`** lives in **bhub** repo root. Cross-session index summarizing every app's status. **Auto-generated** from per-app handoffs — never hand-edited.
- **Per-app `HANDOFF.md`** files live in each repo's root. Full detail on one app.
- **`bsync.sh`** lives in **bhub** repo root. The single bootstrap command.
- **GitHub is the source of truth**, not the mounted drive.

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
| hc-strategy | brhecht/hc-strategy | hc strategy (archived — superseded by tnb-strategy) |
| tnb-strategy | brhecht/tnb-strategy | tnb, the new builder, tnb strategy, new builder strategy, war room (private — Brian only) |
| pitch-scorer | brhecht/pitch-scorer | pitch scorer (archived) |

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

---

## Commands

### "handoff here"

This is the session bootstrap. One command does everything.

**The user does NOT need to specify which app.** They can say "handoff here" and then start talking about what they want to do, or they can say "handoff here b-people" explicitly. Either works.

#### Step 1: Run bsync

```bash
BSUITE_DIR="<mounted-bsuite-path>" bash <bhub-path>/bsync.sh
```

If bsync.sh isn't available locally (e.g., bhub not cloned on this device), clone bhub to `/tmp/` first:
```bash
git clone https://github.com/brhecht/bhub.git /tmp/bhub 2>/dev/null
BSUITE_DIR="<mounted-bsuite-path>" bash /tmp/bhub/bsync.sh
```

bsync handles git credential setup, lock file detection, repo pulls (with automatic `/tmp/` fallback for EPERM issues), handoff freshness checks, and skill version verification. It outputs structured JSON.

#### Step 2: Act on bsync results

**Repos:** Check that all repos pulled successfully. If any show `"status": "failed"`, clone them to `/tmp/` yourself — do NOT ask the user to do this. If any show `"status": "cloned_to_tmp"`, note their `/tmp/` path — use that for reads/writes instead of the mounted path.

**Locks:** If `"found": true`, report the locked files. The user needs to clean them on their Mac (bsync can't fix EPERM locks on mounted drives).

**Handoffs — stale detection:** For each entry where `"stale": true`:
- If `commits_since_handoff > 0`: the handoff is behind the code. Read the `recent_commits` field — these are the commit messages since the handoff was last written. Use them to understand what changed. If the user is going to work on this app, read the full HANDOFF.md (it's still useful as a base), then layer the commit history on top.
- If `handoff_exists` is `false`: this repo has never had a HANDOFF.md, or its handoff info lives only in the master. If the user works on it, write one at session end.
- **Do NOT auto-rewrite stale handoffs at bootstrap.** Just note which are stale. Handoffs get updated at push time (stamps) or via explicit "handoff away." Auto-rewriting at bootstrap wastes tokens on apps the user may not touch this session.

**Skills:** For each entry where `"match": false`:
- Present the install link: `[Install <skill>.skill](computer://<install_path>)`
- Tell the user: "**<skill> is outdated (v<version>).** Click to install, then restart the session."
- **This is a blocking gate.** Do not proceed to work until skills are current or the user explicitly acknowledges the mismatch.

#### Step 3: Read the master

Read `HANDOFF-MASTER.md` from bhub (use the path bsync reported — could be mounted or `/tmp/`). This gives you the cross-app index.

#### Step 4: Load app context

Once you know which app the user wants (from their message or by asking):

1. Find the repo path from bsync results
2. Read the app's `HANDOFF.md`
3. If bsync flagged it as stale, also read the `recent_commits` to understand what changed since the handoff
4. If the app's skill references additional docs (e.g., hc-strategy references `STRATEGY-CONTEXT.md` and `operating-plan.md`), read those too. If they're not on the local drive, clone the repo to `/tmp/` yourself — do NOT ask the user to clone repos.
5. Internalize cross-app context from the master (shared infra, deploy safety, user registry)
6. Respond with a brief status summary and ask: **"What do you want to work on?"**

#### Step 5: Clean up legacy files

If the app's repo has legacy date-stamped handoff files (e.g., `HANDOFF-BPeople-2026-03-14.md`) alongside a proper `HANDOFF.md`, delete the dated copies and commit.

---

### Stamp-on-Push Protocol

**This is the belt.** It runs automatically as part of every meaningful git push — not every debug push, but every push where direction or state actually changes (feature shipped, bug fixed, approach pivoted).

**What a stamp looks like** — append to the `## Session Log` section of the app's HANDOFF.md:

```markdown
### [date] — [brief description]
- **What shipped:** [1-2 lines]
- **Known issues:** [anything broken or degraded, or "None"]
- **Next:** [what to do next, or "Continuing"]
```

**Rules:**
- Stamps are appended, not replaced. They accumulate within a session.
- Keep each stamp to 3-5 lines. This is a breadcrumb, not a full handoff.
- If the `## Session Log` section doesn't exist, create it at the bottom of HANDOFF.md.
- The stamp is committed alongside the code change — same commit, not a separate one.
- If there's no HANDOFF.md yet, don't create one just for a stamp. Stamps are amendments to existing handoffs.

**When to stamp:**
- After pushing a feature or meaningful fix
- When pivoting approach (e.g., "tried X, didn't work, switching to Y")
- Before a push that changes known-issues state (new bug discovered, old bug fixed)

**When NOT to stamp:**
- Debug iterations (fix typo, rebuild, push again)
- Dependency updates or trivial config changes
- If you just stamped on the previous push and nothing meaningful changed

**Integration with dev-deploy push chain:** The stamp happens BEFORE the git add/commit/push. The dev-deploy skill's push protocol includes the stamp step. See dev-deploy SKILL.md for the exact sequence.

---

### "handoff away"

Write or amend a single `HANDOFF.md` file in the project's root directory. If one already exists, update it in place. This is the comprehensive snapshot — everything a fresh Claude session would need.

**This is the suspenders.** The system works without it (bsync + stamps provide continuity), but a full handoff-away captures richer context: design reasoning, open questions, planned features, and the kind of nuance that commits and stamps can't convey.

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

## Session Log
[Accumulated stamps from this and previous sessions — preserve, don't remove]
```

**Rules:**
- Be specific and concrete, not vague. "Fixed the date picker bug on the settings page" not "Made some fixes."
- If a section has nothing to report, write "None" — don't omit the section.
- Always amend the existing `HANDOFF.md` in place. Never create date-stamped copies.
- When amending, update the "Last updated" timestamp and revise all sections to reflect current state. Don't just append — the file should read as a clean, current snapshot. But preserve the Session Log section — stamps are historical.
- After writing, commit and push the handoff file to git.

#### Multi-app sessions

If you touched multiple repos during the session, hand off ALL of them. Track which repos you modified and update each one's HANDOFF.md.

#### Master update (mandatory — part of every handoff away)

After writing per-app handoffs, ALWAYS rebuild the master:

1. Read `HANDOFF-MASTER.md` from bhub
2. For each app you're handing off: update its section with current status, date, and key context
3. Commit and push bhub

This is part of every "handoff away" — not a separate step. If the master update fails, tell the user explicitly.

#### Verification step

After pushing, sanity check: does the master's "last updated" date for each app match the per-app HANDOFF.md timestamps? If not, fix it.
