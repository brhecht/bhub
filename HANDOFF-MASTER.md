# HANDOFF MASTER — B Suite
*Lean cross-app reference. Per-app detail lives in each repo's `HANDOFF.md`. Recent activity log in [HANDOFF-HISTORY.md](./HANDOFF-HISTORY.md).*

---

## Session End Rule

**No session ends without all modified B-Suite files committed and pushed to GitHub.** The mounted drive is not persistent between sessions — if it's not in git, it's gone. This applies even if the user doesn't explicitly say "handoff away." If a session is ending (user says goodbye, switches devices, or context is running low), push all uncommitted work before responding. This is non-negotiable.

---

---

## Session Bootstrap Protocol

**Claude must execute these steps automatically on every "handoff here" — no user prompting required.**

### 1. Git Auto-Config
Read `.git-token` from B-Suite root. If it exists, configure git credentials in the VM:
```bash
git config --global credential.helper store
echo "https://brhecht:$(cat .git-token)@github.com" > ~/.git-credentials
git config --global user.name "brhecht"
git config --global user.email "brhnyc1970@gmail.com"
```
Verify with `git push --dry-run` on any repo. If token is expired/missing, ask user to generate a new classic PAT at github.com/settings/tokens (`repo` scope) and save to `.git-token`.

### 2. File Lock Check
Scan all `.md` files in B-Suite root and active project folders for EDEADLK errors. If any are found, report them immediately — user needs to run the unlock command on their Mac:
```bash
for f in <locked-files>; do cp "$f" "${f}.tmp" && rm "$f" && mv "${f}.tmp" "$f"; done
```

### 3. Device Detection
Check the mounted B-Suite path. If it doesn't match a known device path, ask user which device they're on and record the path in the Devices section below.

### 4. npm Install Check
If the session will involve building an app, check if `node_modules` exists in the target app. If not, run `npm install`. Note: this installs Linux binaries — user must run `npm install` on their Mac before any local builds after Cowork touches the app.

---

---

## Apps Index

Lean status snapshot. For full detail per app — recent changes, open issues, design decisions — read that app's `HANDOFF.md`.

| App | Repo | Live URL | One-line status |
|-----|------|----------|-----------------|
| **B Things** | `things-app/` | https://things-app-gamma.vercel.app | Personal kanban + two-way messaging w/ Nico |
| **B Content** | `content-calendar/` | https://content-calendar-nine.vercel.app | Content pipeline (YT, LinkedIn, Beehiiv) w/ rich text |
| **B People** | `b-people/` | https://b-people.vercel.app | Relationship CRM |
| **B Nico** | `brain-inbox/` | https://brain-inbox-six.vercel.app | Nico's triage inbox + B-Suite notification router + email send |
| **B Projects** | `eddy/` | https://eddy-tracker.vercel.app | Course-launch Gantt (formerly B Eddy); Eddy course killed Apr 11 |
| **B Hub** | `bhub/` | https://b-hub-liard.vercel.app | Suite homepage + app switcher; hosts bsync + master handoff |
| **B Marketing** | `b-marketing/` | https://b-marketing.vercel.app | Marketing tools hub (scaffolded; deploy not wired to GitHub) |
| **B Resources** | `b-resources/` | https://b-resources.vercel.app | Knowledge/library hub |
| **HC Funnel** | `hc-funnel/` | https://quiz.humbleconviction.com | Quiz → action plan email; ads off after Apr 14 |
| **HC Website** | `hc-website/` | https://humbleconviction.com | Legacy HC marketing site |
| **TNB Website** | `tnb-website/` | https://thenewbuilder.ai | TNB homepage + glossary (287 terms) + Substack subscribe |
| **Builder Bot** | `builder-bot/` | — | Daily Slack recap bot for TNB community |
| **Pitch Scorer** | `pitch-scorer/` | https://pitch-scorer.vercel.app | Archived |
| **TNB Strategy** | `tnb-strategy/` | — | Private TNB strategy vault (Brian only) |
| **HC Strategy** | `hc-strategy/` | — | Archived (superseded by tnb-strategy) |

**Cowork build status:** all 8 active web apps build in Cowork as of Mar 5, 2026 except `things-app` (PostCSS/Tailwind issue in VM; builds fine on Mac).

---

## Cross-Project Dependencies

- **eddy + hc-funnel** share Firebase project `eddy-tracker-82486` (same Firestore instance, separate collections: eddy uses `users/{uid}/*`, hc-funnel uses `leads`)
- **hc-funnel** marketing tasks are tracked in **eddy** (W1 tasks: messaging angles, quiz structure, ad creatives, target audiences)
- **hc-course** (not yet started) is gated by waitlist validation data from **hc-funnel**
- **bhub** `index.html` is the design reference for **hc-funnel**'s warm light theme
- **things-app, content-calendar, brain-inbox, b-people** all share Firebase project `b-things` and the AppSwitcher component
- **things-app** has two-way messaging with Nico (viewer + messaging); **brain-inbox** is Nico's inbox + B Suite notification router. Nico creates Brian tasks from Slack via `--notes` flag in nico-slack.js
- **Content Calendar → B Things real-time sync** — Firestore trigger (`syncContentToThings`) fires on any `contentCards` write. If `dueDate` matches today and card isn't published/archived, creates a task in B Things under HC Content / Today. Deduplicates via `sourceCardId`. Function lives in `brain-inbox/functions/index.js` (see tech debt note above). Also has a Vercel cron backup at `things-app/api/content-today.js` (daily at 7am ET) but the Firestore trigger handles real-time.
- **bhub** links to **b-marketing** (standalone app) and **b-resources** (standalone app) as sub-hubs
- **b-marketing** links out to **hc-funnel** for the quiz; will eventually embed or route to more marketing tools
- **b-resources** will use **b-things** Firebase project for Library/Vault data storage
- **tnb-website** email capture wires to Beehiiv (same account as HC newsletter). All copy sourced from **tnb-strategy/POSITIONING-LANGUAGE.md**.
- **hc-website** `tnb-coming-soon` branch is deprecated; **tnb-website** is the replacement. Delete branch after tnb-website is live.
- **gh CLI auth** is resolved — repos can now be archived
- **B-Suite UX Standards** — canonical source for cross-app UX patterns (modals, toasts, inline edit, DnD, nav, responsive, design system, keyboard shortcuts, data patterns, messaging). Lives at `bhub/UX-STANDARDS.md` (source of truth) with HTML viewer at `bhub/ux-standards-view.html`. **PM briefs must reference this doc** — deviations require Brian's approval.

---

---

## UX Standards

`bhub/UX-STANDARDS.md` is the canonical cross-app UX reference. Any PM brief that specs a modal, toast, inline editor, drag-and-drop, keyboard shortcut, auth flow, or messaging component must cite it. If a new pattern emerges that doesn't fit the existing standards, update this doc first (via PR-style commit to bhub), then build against the updated standard.

The HTML viewer (`ux-standards-view.html`) is useful for visual review but is generated from the MD — always edit the MD and regenerate the HTML if layout changes are needed.

---

---

## bhealth — Fleet Audit Playbook

`bhealth.sh` (in bhub root) is the fleet audit tool. It runs on each Mac locally and audits that Mac's B-Suite state. bsync keeps repos synced hourly; bhealth catches what bsync can't self-heal.

**When to run:**
- Weekly (the `weekly-fleet-audit-check` scheduled task creates a B Things reminder Monday mornings with staleness per device)
- When something feels off — sync failures, missing repos, skill drift suspicion
- After setting up a new device

**How to run (on any Mac):**
```bash
cd ~/Developer/B-Suite/bhub && git pull && bash bhealth.sh
```
First run on a device prompts for which Mac (Mini / iMac / Pro / Air). Subsequent runs auto-detect via `.bhealth-device` file.

**Output:** JSON report committed to `bhub/.health/{device-slug}-{YYYY-MM-DD}.json` — so any Cowork session can pull the latest bhub and read the audit result from GitHub.

**Auto-heal tiers (what bhealth fixes by itself):**
- Tier 1 (silent): clean fast-forwards on behind-clean repos, pushes on ahead-clean repos, bsync agent reinstall if missing, master handoff path correction
- Tier 2 (clickthrough): opens `.skill` installer dialogs for drifted skills
- Tier 3 (flag, don't touch): dirty working trees, uncommitted work, missing .git-token, missing toolchain — these require human judgment

**Claude's role when Brian pastes "I ran bhealth, help me triage":**
1. Pull latest bhub from GitHub. Read `bhub/.health/{device-slug}-{most-recent-date}.json`.
2. Classify each flag as **ghost drift** vs **real WIP**:
   - **Ghost drift signals:** Mac's last commit is weeks old + repo is significantly behind origin + the "modified" files' content is identical to origin's current version. This happens when bsync reset worked but left working-tree noise, or local files got touched by iCloud/editors. Brian doesn't code by hand — he codes via Cowork → GitHub. So local Mac modifications are almost always ghost drift.
   - **Real WIP signals:** Mac's last local commit is recent + the dirty files contain actual changes not yet on origin. Rare in Brian's workflow but possible.
3. For ghost drift: safe cleanup is `git stash push -u -m "{device}-ghost-drift-{date}"` followed by `git reset --hard origin/main` per repo. Stash preserves everything in case. Script template:
   ```bash
   cd ~/Developer/B-Suite && for r in {repos-to-clean}; do echo "=== $r ==="; cd ~/Developer/B-Suite/$r && git stash push -u -m "ghost-drift-{date}" 2>&1 | tail -2 && git reset --hard origin/main 2>&1 | tail -1; done
   ```
4. For missing repos: clone command using `.git-token`:
   ```bash
   cd ~/Developer/B-Suite && TOKEN=$(cat .git-token) && for r in {missing-repos}; do git clone "https://brhecht:${TOKEN}@github.com/brhecht/${r}.git"; done
   ```
5. For skill drift on Mac: defer to user (Claude desktop Skills panel is the source of truth; bhealth's filesystem check on Mac is intentionally skipped — it's unreliable).
6. After cleanup, have Brian re-run bhealth to verify zero flags.

**Known gotcha:** running `git` commands from Cowork against the mounted Mac filesystem (`/sessions/.../mnt/Developer/B-Suite/{repo}/`) creates `.git/index.lock` files that the Linux sandbox can't clean. This blocks subsequent git ops on the Mac. Fix: `find ~/Developer/B-Suite -name "index.lock" -path "*/.git/*" -delete`. Avoid running git on the mount from Cowork unless necessary.

---

---

## Status Recap Rules (for Claude)

When Brian says "handoff here" or asks "where do things stand," recaps must stay in the **tech/Cowork lane**:

- **Include:** code state, deploy status, env vars pending, infra issues, git/repo oddities, skill drift, bhealth flags, anything actionable inside Claude Cowork or the tech stack.
- **Exclude:** business to-dos (War Room scheduling, podcast episode cadence, content calendar pacing, strategic deadlines). Those belong in **B Things**, not in Claude status summaries. Brian tracks business work himself — the recap is a tech bridge, not a business dashboard.
- **Gray area:** if a business event has a tech dependency (e.g., "Substack migration next week" implies a code swap on tnb-website), mention the tech dependency, not the business event.

When in doubt, ask: "is this something Claude/Nico needs to DO in code, or is this something Brian needs to DO as a founder?" Only the former belongs in a recap.

---

---

## Notification Routing Rules

**Brain Inbox is Nico's domain.** Brian owns the code and has access to the Slack channel, but Brain Inbox is not a destination for Brian's personal notifications, reminders, or self-scheduled tasks. Route Brian-destined items elsewhere.

**Brian's notifications:**
- Task-oriented items → **B Things** (create a task via `things-app/api/add-task.js`)
- Quick messages → **Slack DM to Brian** (`U096WPV71KK`)
- Longer content → **Gmail** (brhnyc1970@gmail.com) via comms skill

**Nico's notifications:**
- Task-oriented items → **Brain Inbox Slack channel** (his triage inbox)
- Quick messages → **Slack DM to Nico** (`U09GRAMET4H`)
- Longer content → **Email to nico@humbleconviction.com** via comms skill

**Scheduled tasks for Brian → B Things.** Weekly/recurring reminders generated by Claude (fleet audits, briefings that produce action items, etc.) should create B Things tasks, not Slack pings.

**Cross-actor messaging uses the comms skill** — don't hardcode routing elsewhere.

---

---

## User Registry (B Suite)

Central user identifiers used across all B Suite apps. Source of truth: `content-calendar/src/users.js` (and the USER_REGISTRY in `brain-inbox/api/handoff-notify.js` for server-side).

| User | Email | Slack User ID | @handle | Notes |
|------|-------|---------------|---------|-------|
| Brian | brhnyc1970@gmail.com | U096WPV71KK | @brian | Owner. Firebase UID resolved at runtime via Admin Auth. |
| Nico | nico@humbleconviction.com | U09GRAMET4H | @nico | Firebase UID: `N7dBZAH0HkhCCtlAPnfFIWmxn6t1` |
| Nico (alt) | nmejiawork@gmail.com | U09GRAMET4H | @nico | Same person, alternate email |

When adding a new user: update `content-calendar/src/users.js`, `brain-inbox/api/handoff-notify.js` USER_REGISTRY, and the ALLOWED_EMAILS in each app's `store.js`.

---

---

## Devices

Brian uses four machines. All on `~/Developer/B-Suite/` as of April 18, 2026. Desktop/B-Suite is deprecated everywhere (iCloud sync risk).

**Device roles (Brian's actual workflow, NYC-based):**

- **Mac Mini** — primary dev at home. Big screen. Where real work happens. B-Suite path: `~/Developer/B-Suite`
- **iMac** — primary dev at office. Big screen. Where real work happens. B-Suite path: `~/Developer/B-Suite`
- **MacBook Pro** — travel companion. Always with Brian; sits beside the primary in both locations. Full dev toolchain. B-Suite path: `~/Developer/B-Suite`
- **MacBook Air** — light travel only (airplane, coffee shop, reading). Infrequent use. Minimal toolchain by design — Pro is the real travel dev machine. B-Suite path: `~/Developer/B-Suite/`

**The master was corrected on April 18, 2026** — prior versions listed Pro as "primary dev machine," which was wrong. Mini + iMac are the primaries; Pro is the always-carry bridge between them.

---

---

## Local Machine Paths & Cowork Build Status

- **Git push from Cowork:** Now works autonomously. GitHub PAT (classic, `repo` scope) saved to `.git-token` in B-Suite root. At session start, Claude reads this file and configures git credentials in the VM. No terminal handoff needed for deploys. Token expires ~June 2026 — regenerate at github.com/settings/tokens when it does.
- **Git push command pattern (terminal fallback):** `cd ~/Desktop/B-Suite-Clean.nosync/<app-folder> && git push` (adjust path per device)
- **Cowork npm install:** Done for all 8 apps as of March 5, 2026. Linux binaries installed. If user needs to build locally on their Mac, run `npm install` in that app first to restore Mac binaries.

**Cowork build status (March 5, 2026):**
| App | Cowork Build | Notes |
|-----|-------------|-------|
| eddy | ✅ | |
| brain-inbox | ✅ | |
| content-calendar | ✅ | |
| hc-funnel | ✅ | |
| b-people | ✅ | |
| b-marketing | ✅ | |
| b-resources | ✅ | |
| things-app | ❌ Cowork / ✅ Mac | PostCSS/Tailwind filesystem error in Cowork VM — builds fine on Mac. Retry Cowork next session, use terminal handoff for now |

---

---

## Known Issues

- **B Marketing deploy not wired to GitHub** — `b-marketing.vercel.app` was originally deployed via `npx vercel --yes --prod` and does not auto-deploy from GitHub pushes. The AppSwitcher component is in the code (App.jsx renders it) but the live site is running a stale build that doesn't show it. Fix: either connect the GitHub repo in the Vercel dashboard (Settings → Git → Connected Git Repository) or run `npx vercel --yes --prod` from the b-marketing folder to pick up current code. Same likely applies to `b-resources`.

---

---

## Backlog: Infrastructure

- **Install dev-deploy skill on all devices** — Updated `dev-deploy.skill` is in B-Suite root folder (updated March 6 with Git Auto-Config section). Must be double-clicked to install on each device (MacBook Pro, MacBook Air, Mac Mini). One-time per device. Track which devices have it installed:
  - MacBook Pro: ⬜ pending
  - MacBook Air: ⬜ pending
  - Mac Mini: ⬜ pending
- **GitHub PAT renewal** — Classic PAT (`cowork`, `repo` scope) saved to `.git-token` in B-Suite root. Expires ~June 2026. When it expires, generate a new one at github.com/settings/tokens (classic), `repo` scope, and update `.git-token`.
- **Extract shared Cloud Functions into dedicated repo** — Currently all Firebase Cloud Functions for `b-things` deploy from `brain-inbox/functions/`. This is confusing since the content-to-things sync has nothing to do with Brain Inbox. Future cleanup: create a `b-suite-functions/` repo (or similar) that owns all Firestore triggers across the ecosystem.
- **Remove Vercel cron from things-app** — `api/content-today.js` and `vercel.json` cron config can be removed once the Firestore trigger is confirmed stable (real-time is better). Keep for now as fallback.
