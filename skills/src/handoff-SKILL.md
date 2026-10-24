---
name: handoff
description: "SESSION BOOTSTRAP for editing B-Suite repos. Run it before the first edit, when a repo in the REPOS table (the B-Suite Repo Registry below) is about to be edited, or when Brian asks for a fleet check, 'handoff here', 'handoff away', or a device or project-state sync. It runs bsync, checks skill versions, reads the master handoff and the recent decisions, then loads the app's handoff. It does NOT run for reading or writing Linear, Slack, email, Google Drive or the strategy canon, or for any question that does not edit a repo. Standing rules about how Brian works live in STANDING-RULES.md at the root of the bhub repo, not in this skill. Do not edit a repo before this has run, and do not do 'just one quick fix' first."
---

# Handoff Skill

This skill manages project continuity across devices and Cowork sessions. It uses three layers of resilience, plus a fourth added October 17, 2026:

1. **bsync.sh** (the belt) — a bash script that pulls all repos from GitHub, cross-checks handoff freshness against git history, checks skill versions, and outputs a structured JSON report. Claude runs this once at session start. It works regardless of what the previous session did or didn't do.
2. **Stamp-on-push** (the belt+) — lightweight context stamps appended to HANDOFF.md on meaningful pushes during a session. Captures intent, known issues, and next steps that git commits alone can't convey.
3. **Handoff away** (the suspenders) — a full handoff rewrite when the user explicitly requests it. Captures rich context. The system doesn't break if this is skipped — bsync + stamps cover the gap.
4. **REGISTRY.md** (the inventory) — one file in `bsuite-handoffs` listing every app, skill, published artifact, Linear document and scheduled task Brian has, with its stage and what's next. Handoffs answer "what does a fresh session need to know about app X"; REGISTRY.md answers "what do I have, across everything, and where did I leave it" — a different question, so it gets its own file rather than being squeezed into HANDOFF-MASTER.md (which drifted into an unmaintained narrative log once before, see its own history). `bsync.sh --registry` derives what it can (last-commit dates, skill versions, orphan detection); stage and next are hand-written, never auto-filled or guessed. A row is added in the same turn the thing is created (see "Registry update"), not at handoff-away.

## When this skill runs

Run it when a repo in the REPOS table (the B-Suite Repo Registry below) is about to be edited, or when Brian asks for a fleet check, "handoff here" or "handoff away". Do not run it for reading Linear, Slack, email, Google Drive or the strategy canon, or for answering questions. Brian never has to type "handoff here" or "handoff away": the bootstrap is implicit when a repo edit is coming, and outputs land where they belong when they are made.

Brian does not mount B-Suite by default. When a task needs the git token (`.git-token`), a file he dropped there, or a repo edit, request access to `~/Developer/B-Suite` yourself; do not ask him to mount it.

## Architecture: What Lives Where

- **`HANDOFF-MASTER.md`** lives in the **private `bsuite-handoffs`** repo root. Cross-session index summarizing every app's status. **Auto-generated** from per-app handoffs — never hand-edited.
- **`REGISTRY.md`** also lives in the private `bsuite-handoffs` repo root, alongside `HANDOFF-MASTER.md`. Different job: HANDOFF-MASTER is deep status per app; REGISTRY.md is a flat inventory across every type of thing Brian builds (apps, skills, published artifacts, scheduled tasks), including things with no repo at all.
- **Per-app `HANDOFF.md`** files live in **private `bsuite-handoffs/<app>/HANDOFF.md`**. They do NOT live inside individual app repos — that pattern leaked strategy/architecture from every public app repo until May 25, 2026 when everything was migrated to this dedicated private home.
- **`bsync.sh`** lives in **bhub** repo root. The single bootstrap command. (Stays in bhub because it's deploy infrastructure, not strategy — safe even though bhub is public.)
- **GitHub is the source of truth**, not the mounted drive.
- **`b-personal-hub` carries a stale `HANDOFF-MASTER.md` dated March 31 2026.** It predates the
  May 25 migration and nothing maintains it. Ignore it; the only master is the one in
  `bsuite-handoffs`. Delete it next time that repo is touched.

## Reading B-Suite App DATA from Cowork (canonical — do NOT reach Firestore directly)

**Never query Firestore from the Cowork sandbox.** Two hard failures make it a dead end (confirmed June 8, 2026, after ~5 min of circling):
1. `firebase-admin` uses gRPC; the channel handshake alone exceeds the **45s bash cap**, so every direct read times out.
2. On-disk service-account keys (e.g. `B-Suite/b-things-service-account.json`) go **stale on rotation** — the live key only ever lives in Vercel env. A rotated key returns `Invalid JWT Signature`, so even the fast REST path can't auth.

**Instead, read through the app's own Vercel backend over HTTPS.** The serverless functions already hold the live `FIREBASE_SERVICE_ACCOUNT` and authenticate with their own secret, so one `curl` is sub-second and immune to key rotation. Look up the endpoint and secret name in that app's own HANDOFF.md.

**B Things is retired (Focus Machine Stage 2, October 2026).** Its `/api/tasks` read endpoint and the per-device `.bthings-key` file are gone with it. Do NOT read tasks at session bootstrap. Brian's tasks live in Linear (Athena team, and The New Builder / TNB CRM teams shared with Nico); use the `athena` and `linear-ops` skills when a session needs them.

## B-Suite Repo Registry

Most repos live under `~/Developer/B-Suite/` (local, NOT iCloud). All are git repos under `github.com/brhecht/`.

A few "sibling" repos live alongside B-Suite directly under `~/Developer/` (not inside `B-Suite/`). They're enrolled in the same fleet audit — bsync pulls them, checks handoff freshness, and warns on drift — but they live one directory up to keep them visually separate from the core B-Suite product fleet.

| Repo folder | GitHub repo | Location | App keywords (for auto-detection) |
|-------------|------------|----------|----------------------------------|
| things-app | brhecht/things-app | B-Suite | things, tasks, kanban, task board — RETIRED Oct 2026 (Vercel paused, repo kept as the Game Plan reference) |
| brain-inbox | brhecht/brain-inbox | B-Suite | brain inbox, nico, b nico, nicoOS |
| content-calendar | brhecht/content-calendar | B-Suite | content, calendar, content calendar, youtube, linkedin, beehiiv |
| b-marketing | brhecht/b-marketing | B-Suite | marketing, b marketing |
| b-people | brhecht/b-people | B-Suite | people, contacts, relationships, reach out, nudge, b people |
| b-resources | brhecht/b-resources | B-Suite | resources, library, vault |
| bhub | brhecht/bhub | B-Suite | hub, b hub, suite, master |
| eddy | brhecht/eddy-tracker | B-Suite | eddy, tracker, course launch, gantt |
| hc-funnel | brhecht/hc-funnel | B-Suite | funnel, quiz, ads, meta ads, landing page, pitch assessment |
| hc-strategy | brhecht/hc-strategy | B-Suite | hc strategy — RETIRED Oct 17 2026, superseded by tnb-strategy since April; closing note at top of hc-strategy/STRATEGY-CONTEXT.md |
| tnb-strategy | brhecht/tnb-strategy | B-Suite | tnb, the new builder, tnb strategy, new builder strategy, war room (private — Brian only) |
| hc-website | brhecht/hc-website | B-Suite | hc website, humble conviction website |
| tnb-website | brhecht/tnb-website | B-Suite | tnb website, the new builder website, thenewbuilder.ai |
| pitch-scorer | brhecht/pitch-scorer | B-Suite | pitch scorer (archived) |
| builder-bot | brhecht/builder-bot | B-Suite | builder bot |
| bsuite-handoffs | brhecht/bsuite-handoffs | B-Suite | bsuite handoffs (central handoff store — May 25 migration — also holds REGISTRY.md and scheduled-tasks/) |
| b-line | brhecht/b-line | B-Suite | b-line, bline, athena board, the athena board, linear board, tickler |
| setlist-predictor | brhecht/setlist-predictor | B-Suite | setlist predictor — enrolled in bsync.sh REPOS[] but missing from this table until now; flagged by REGISTRY.md's Oct 17 backfill |
| muscle-anatomy | brhecht/muscle-anatomy | ~/Developer (sibling) | muscle anatomy, anatomy reference, physical therapy reference |
| saturn-v-anatomy | brhecht/saturn-v-anatomy | ~/Developer (sibling) | saturn v, saturn-v, saturn v anatomy, rocket anatomy |
| B-Personal | brhecht/b-personal | ~/Developer (sibling) | b-personal, b personal |
| b-personal-hub | brhecht/b-personal-hub | ~/Developer (sibling) | b personal hub, personal launcher, launcher card |
| photo-cull | brhecht/photo-cull | ~/Developer (sibling) | photo cull, cull my photos, dupe review, photo duplicates |

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
3. Copy the token and paste this block in Terminal (replacing YOUR_TOKEN). Clones the B-Suite repos into `~/Developer/B-Suite/` and the sibling repos one level up under `~/Developer/`:
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
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/hc-website.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/tnb-website.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/tnb-strategy.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/builder-bot.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/bsuite-handoffs.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/b-line.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/setlist-predictor.git && \
echo "YOUR_TOKEN" > .git-token && \
cd ~/Developer && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/muscle-anatomy.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/saturn-v-anatomy.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/b-personal.git B-Personal && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/b-personal-hub.git && \
git clone https://brhecht:YOUR_TOKEN@github.com/brhecht/photo-cull.git && \
echo "Done — all repos cloned (B-Suite fleet + 5 siblings) and token saved"
```
4. Revoke the PAT at github.com/settings/tokens (token is saved in .git-token for Cowork to use)
5. Mount `~/Developer/B-Suite` in Cowork
6. After setup, update the "Devices set up" list in the master handoff (in bhub) with the device name and date

### Devices Already Set Up
Check the master handoff in bhub (`HANDOFF-MASTER.md`) for the current list. If this device isn't listed, run setup.

---

## Commands

### "handoff here"

This is the session bootstrap. The protocol is **two-phase, lazy by design**: first get the user oriented, then bsync only what they're actually going to touch. This cuts a typical "handoff here" from ~45s of network work down to ~10-15s.

**The user does NOT need to specify which app.** They can say "handoff here" and start talking about what they want to do, or say "handoff here b-people" explicitly. Either works.

---

#### Phase 1 — Light bootstrap (always)

**Step 1.1: Pull a fresh `bhub` AND `bsuite-handoffs` to `/tmp/`**

Always pull both from GitHub fresh — never trust the mount's copies. The mount may be stale. `bhub` carries `bsync.sh` (and is public); `bsuite-handoffs` carries `HANDOFF-MASTER.md`, `REGISTRY.md`, and every per-app `HANDOFF.md` (and is private).

```bash
rm -rf /tmp/bhub-bootstrap /tmp/bsuite-handoffs-bootstrap 2>/dev/null
git clone --depth 1 https://github.com/brhecht/bhub.git /tmp/bhub-bootstrap 2>/dev/null
# Source the PAT from .git-token in the mount root — it is ALWAYS present at
# bootstrap time. (~/.git-credentials is NOT populated until git auto-config runs
# in Phase 2, so reading from it here fails the first clone — the May-2026 bug.)
TOKEN=$(cat "$BSUITE_DIR/.git-token" 2>/dev/null | tr -d '\n')
[ -z "$TOKEN" ] && TOKEN=$(cat ~/.git-credentials 2>/dev/null | grep -oE 'brhecht:[^@]+@github\.com' | head -1 | cut -d: -f2 | cut -d@ -f1)
git clone --depth 1 "https://brhecht:${TOKEN}@github.com/brhecht/bsuite-handoffs.git" /tmp/bsuite-handoffs-bootstrap 2>/dev/null
```

`$BSUITE_DIR` is the mounted B-Suite path (e.g. the Cowork mount). If the clone still fails, the PAT in `.git-token` is expired — generate a new classic PAT (`repo` scope) and overwrite `.git-token`.

**Step 1.2: Read the lean master**

Read `HANDOFF-MASTER.md` from `/tmp/bsuite-handoffs-bootstrap/`. This is the cross-app reference: the per-app index plus the repo plumbing notes. It has grown past its intended size before, so check its actual size with `wc -c` and read it in sections if it is large; do not assume it is short. Per-app deep status lives in `/tmp/bsuite-handoffs-bootstrap/<app>/HANDOFF.md` (read on demand in Phase 2). If the session's work might touch anything outside one app — what exists across the fleet, what's live vs. dead, what a skill actually does — also glance at `REGISTRY.md` in the same folder; it's the flat inventory, not the deep-dive.

**Migration note:** Before May 25, 2026, `HANDOFF-MASTER.md` lived in `bhub` and per-app `HANDOFF.md` files lived inside each app's own repo. They were moved to the private `bsuite-handoffs` repo because every public app repo was leaking strategy/architecture content. If you ever see a stub HANDOFF in an app repo pointing here, that's the migration artifact — read the real file from `bsuite-handoffs`.

**Step 1.3: Read recent decisions (before any judgment)**

For the topic of the first message, find what was decided in the last 7 days. Do both:

1. Run past-chat search (`conversation_search`) on the topic's content words, limited to the last 7 days, and read the relevant hits.
2. List Linear documents updated in the last 7 days in every project the topic names, including any "<project> decision log", and read them.

Read these before forming any judgment or recommendation. A decision log entry counts as a decision only if it links to where Brian said it. The 7-day window is an assumed value; widen it when the topic clearly spans longer.

**Step 1.4: Determine target app**

Either the user named it ("handoff here b-people") or their message implies it ("the funnel is broken" → hc-funnel). If neither, ask: "What do you want to work on?"

For sessions that touch multiple apps, you can pass a comma-separated list to bsync. For pure-conversation sessions (strategy, content brainstorm with no code touch), you can skip Phase 2 entirely and proceed without bsync — but you must still complete Step 2 below if you end up writing code.

---

#### Phase 2 — Scoped bsync (when work begins)

**Step 2.1: Run bsync scoped to the target app(s)**

```bash
BSUITE_DIR="<mounted-bsuite-path>" bash /tmp/bhub-bootstrap/bsync.sh --app=<app1>,<app2>
```

(`bsync.sh` already knows about `bsuite-handoffs` — it will clone it alongside the scoped apps and read per-app HANDOFFs from there.)

This pulls only bhub + the listed app(s), checks all skills, and skips the mount-sync step. Typical wall time: 8-15 seconds vs 30-45 for the full sync.

If the user's session genuinely needs the full fleet (e.g., audit, fleet-wide refactor), omit `--app=` to run the full sync.

**Step 2.2: Act on bsync results**

**Repos:** Confirm all listed repos show `"status": "ok"`. If any show `"status": "failed"`, clone them to `/tmp/` yourself — do NOT ask the user.

**Locks:** If `"found": true`, report the locked files. The user needs to clean them on their Mac (bsync can't fix EPERM locks on mounted drives).

**Handoffs — stale detection:** For each entry where `"stale": true`:
- If `commits_since_handoff > 0`: the handoff is behind the code. Read the `recent_commits` field — these are the commit messages since the handoff was last written. Use them to understand what changed. Read the full HANDOFF.md as a base, then layer the commit history on top.
- If `handoff_exists` is `false`: write one at session end.
- **Do NOT auto-rewrite stale handoffs at bootstrap.** Stamp-on-push and explicit handoff-away cover this.

**Skills:** For each entry where `"match": false`:
- Present the install link: `[Install <skill>.skill](computer://<install_path>)`
- Tell the user: "**<skill> is outdated (v<version>).** Click to install, then restart the session."
- **This is a blocking gate.** Do not proceed until skills are current or the user explicitly acknowledges the mismatch.

**Manifest integrity:** For each entry where `"manifest_synced": false`, the manifest hash no longer matches the skill's source — someone edited a skill (source + bundle) without bumping `skills-manifest.json`. This corrupts version tracking for that skill (the install/`match` check above is comparing against a stale hash). Surface it and fix the manifest: set `hash` to the current source MD5, bump `version`, update `changelog`, commit. `null` means the skill has no source in bhub (externally authored) — ignore. This check is the backstop for the dev-deploy "version + hash + bundle move together" rule.

**Step 2.3: Load app context**

1. Find the repo path from bsync results (the `/tmp/bsync-*/` clone)
2. Read the app's `HANDOFF.md`
3. If the app's skill references additional docs (e.g., tnb-strategy references `strategy/STRATEGY-CONTEXT.md`), read those too
4. Respond with a brief status summary and ask **"What do you want to work on?"** — unless the user already told you, in which case start the work

**Step 2.4: Clean up legacy files**

If the app's repo has legacy date-stamped handoff files alongside a proper `HANDOFF.md`, delete the dated copies and commit.

---

#### When to use full bsync (no `--app=`)

- The user explicitly asks for a fleet status check
- You're doing cross-app work (e.g., updating shared infra in bhub, propagating a UX standard)
- The session is a fleet audit or skill refresh

For everything else, prefer the scoped form.

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
- If the push shipped, killed, or materially changed the stage of something that has a REGISTRY.md row, update that row's `stage` and `next` in the same commit (one line each, not a rewrite). Skip this when nothing about stage or next actually changed — a stamp doesn't need a registry touch every time.

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
- **Write to `bsuite-handoffs/<app>/HANDOFF.md`, NOT to the app repo.** As of May 25, 2026, every per-app handoff lives in the private `bsuite-handoffs` repo to prevent strategy/architecture leaks from public app repos.
- After writing, commit and push the handoff file to `bsuite-handoffs` (not to the app repo).

#### Multi-app sessions

If you touched multiple repos during the session, hand off ALL of them. Track which repos you modified and update each one's HANDOFF.md inside `bsuite-handoffs/<app>/HANDOFF.md`.

#### Master update (mandatory — part of every handoff away)

After writing per-app handoffs, ALWAYS rebuild the master:

1. Read `HANDOFF-MASTER.md` from `bsuite-handoffs`
2. For each app you're handing off: update its section with current status, date, and key context
3. Commit and push `bsuite-handoffs`

This is part of every "handoff away" — not a separate step. If the master update fails, tell the user explicitly.

#### Registry rows are added at creation (same turn)

Changed October 24, 2026. When a session creates a skill, a published artifact, a Linear document or a scheduled task (or an app or side project), add its `REGISTRY.md` row in `bsuite-handoffs` in that same turn, with stage and next, and push. Do not wait for handoff-away: Brian often walks away from a session without one, and a row that waits for it never gets written. Handoff-away only revisits rows whose stage or next moved.

#### Registry update at handoff away (stage and next only)

Added October 17, 2026. After the master update, touch `REGISTRY.md` (same repo, same commit) for every row this session's work bears on — not only repo-backed apps:

1. Read `REGISTRY.md` from `bsuite-handoffs`.
2. For each thing this session touched — an app, a skill, a published artifact, a scheduled task, or a side project with no repo at all — find or add its row and update only `stage` and `next`. Those two fields are the only ones this step writes; everything else (last-touched dates, repo links, skill versions) is derived and gets refreshed by `bsync.sh --registry`, not hand-typed here.
3. If something this session built or changed has no row yet (a brand-new skill, a new artifact, a new side project), add one. This is the moment orphans get caught permanently, not just flagged — `bsync.sh --registry` only ever reports an orphan, it never adds the row itself.
4. Stage is one of: idea, building, live, parked, dead. Set it from what actually happened this session, not from a guess about the thing's future. Next is one line, or "—" if there's nothing pending.
5. Before writing a stage, run `bash bhub/bsync.sh --registry` once if it hasn't been run yet this session. It flags orphans (things with no row) and won't rewrite anything itself — it exists so this step isn't relying on a hand-maintained file to audit itself, the same failure mode that let HANDOFF-MASTER.md go stale for months.
6. Commit this alongside the HANDOFF-MASTER.md update in the same `bsuite-handoffs` commit, not a separate one.

If a session is a quick single-app fix with nothing to change about that app's row (same stage, same next), skip this — like stamps, the registry doesn't need a touch every time, only when something about stage or next actually moved.

#### Verification step

After pushing, sanity check: does the master's "last updated" date for each app match the per-app HANDOFF.md timestamps? If not, fix it.
