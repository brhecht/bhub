# HANDOFF MASTER — B Suite
*Auto-generated: March 4, 2026 ~12:30 PM ET*
*Updated: March 16, 2026 ~3:30 PM ET*
*Source: Most recent handoff from each project*

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

### 5. Skill Version Check
Three custom Cowork skills are required for B-Suite sessions: **handoff**, **dev-deploy**, and **comms**. This step checks both installation AND version currency.

**Skill files are git-tracked in `bhub/skills/`.** This means `git pull` on bhub gets the latest `.skill` installers on any device. The version manifest (`bhub/skills/skills-manifest.json`) tracks which version each device has installed.

**Bootstrap sequence:**
1. Run `git pull` on the bhub repo (ensures latest skill files are local)
2. Read `bhub/skills/skills-manifest.json`
3. Identify current device from the Devices section
4. Compare device's installed hashes against the `skills` section hashes
5. For any mismatch or missing skill:
   - Present the `.skill` file as a clickable install link in chat: `[Install comms.skill](computer:///path/to/mnt/B-Suite/bhub/skills/comms.skill)`
   - Tell the user: "**[skill-name] was updated [date].** Click to install, then restart the session."
6. After user confirms install, update the device's hash in `skills-manifest.json` and commit to bhub

**If all skills are current** → proceed normally, no action needed. Just confirm: "All skills up to date."

**When a skill is updated (by anyone, on any device):**
1. Edit the SKILL.md source in `bhub/skills/src/[name]-SKILL.md`
2. Rebuild the `.skill` bundle: `zip -r [name].skill [name]/` (containing the SKILL.md)
3. Update `skills-manifest.json`: bump version, update hash (`md5sum` of SKILL.md), set changelog
4. Commit and push bhub
5. On next session start on any other device, the bootstrap will detect the mismatch and prompt install

**Devices with skills installed:**
- MacBook Pro: ✅ all three (March 14, 2026) — hashes recorded in manifest
- iMac: ✅ handoff + dev-deploy (March 16, 2026), comms pending install
- MacBook Air: ⬜ pending
- Mac Mini: ⬜ pending

---

## Firestore Rules — Deploy Safety

The b-things Firebase project uses a single shared `firestore.rules` file that lives in the **brain-inbox repo** (the sole rules deployer). All other repos have had their `firestore` sections removed from `firebase.json`.

**Rules (added March 14, 2026, updated March 16):**
- **Only brain-inbox can deploy Firestore rules.** Its `firebase.json` points to its local `firestore.rules`.
- **Never run a bare `firebase deploy`** from any repo. Always scope: `--only hosting`, `--only functions`, or `--only firestore`.
- **The canonical rules file is `brain-inbox/firestore.rules`.** Contains all collections: appConfig, tasks (+ nested messages subcollection), projects, nicoTasks, nicoProjects, inboxMessages, nicoNotes, viewers, library, contentCards (+ nested messages subcollection), contentPlatforms.
- **Viewers (Nico) have full read-write on tasks and projects** (upgraded March 16 from read-only). This matches nicoTasks/nicoProjects permissions.
- **Firestore rules don't cascade to subcollections.** Every subcollection needs its own explicit `match` rule. This was the root cause of the NoteThread bug (March 16): `users/{userId}/tasks/{taskId}/messages/{messageId}` had no rule.
- **iMac has no Node.js** — Firebase CLI deploy must be done via Firebase console UI (Firestore > Rules > paste > Publish). Install Node when convenient.
- **b-resources, things-app** — `firebase.json` has no `firestore` section. Cannot deploy rules.
- **Before deploying rules**, open the Firebase console and verify you're not removing collections.

**What happened:** On March 14 at 12:27 PM, `firebase deploy` from b-resources overwrote all Firestore rules with only vault + library, taking down B Things, Brain Inbox, and Content Calendar for ~1 hour.

---

## Eddy (Course Launch Tracker)
**Status:** MVP complete, in active use by Brian and Nico
**Last updated:** March 1, 2026
**Location:** eddy/
**Live URL:** https://eddy-tracker.vercel.app
**Key context:**
- Gantt-style timeline + tool decision matrix + budget overview for coordinating HC course launch
- Firebase Firestore real-time sync between Brian and Nico
- Contains W1 task definitions that drive the marketing project (messaging angles, quiz structure, ad creatives, etc.)
- Firebase project: `eddy-tracker-82486` (separate from B Suite's `b-things` project)

**Shared resources:** Firebase project `eddy-tracker-82486` is shared with hc-funnel (same Firestore instance, separate collections)

---

## HC Funnel (Marketing Funnel)
**Status:** Fully rebuilt and deployed — scenario-based quiz live, email content pending
**Last updated:** March 15, 2026
**Location:** hc-funnel/
**Live URL:** https://hc-funnel.vercel.app
**Key context:**
- Complete rewrite (March 15): 8 scenario-based questions (not self-assessment) across 4 dimensions (Clarity, Investor Fluency, Self-Awareness, Persuasion Instincts)
- Scoring engine: per-question best=2/next=1/weak=0, raw totals for tier assignment, display scores as X/5 with dot visualization
- 3 tiers: Lost in the Noise (raw 0-3) / The Pieces Are There (raw 4-9) / So Close It Hurts (raw 10+). Validated via Monte Carlo simulation (10K runs).
- Results page: calculating pause animation → tier badge → scorecard with explanations + cracked door lines → email gate CTA ("Send My Recommendations") + waitlist checkbox
- New design system: navy/orange palette, Inter font, mobile-first (80%+ Meta ad traffic)
- Strategy/content bible: `HC-PHASE1-DISCOVERY.md` in project root (all decisions, all copy, research references, Monte Carlo methodology)
- Firestore `leads` collection captures quiz answers, scores, tier, waitlist flag
- Kit (ConvertKit) integration with server-side proxy
- Next priorities: Brian's design/wording tweaks, email content (results email + 5-email drip), Meta Pixel, ad creatives

**Shared resources:** Firebase project `eddy-tracker-82486` (shared with eddy and b-marketing). Kit account under Humble Conviction.

---

## B Things (Personal Task Manager)
**Status:** Active, fully functional
**Last updated:** March 16, 2026
**Location:** things-app/
**Live URL:** https://things-app-gamma.vercel.app
**Key context:**
- Kanban-style task board with time-based columns, project grouping, drag-and-drop
- **Full read-write for both Brian and Nico** (viewer mode upgraded from read-only to read-write March 16)
- Part of B Suite app switcher ecosystem
- Firebase project: `b-things`
- `firebase.json` is now empty `{}` — things-app should never deploy Firebase resources
- **NoteThread messaging** — iMessage-style threaded chat on each task with @mention notifications via Slack DM. Notification toast feedback. Error handling separates message-save failures (restore draft) from metadata/notification failures (non-fatal, fire-and-forget).
- **Star feature** — optimistic local update in Zustand store, immediate persist from modal, starred items sort to top of project group via `sortWeight`. Kanban re-sort is intentional behavior.
- **Assign to Nico** — button in TaskModal, POSTs to `handoff-notify` API, deep link to card, `→N` badge on board
- Git push from Cowork uses `/tmp/things-build` clone (HEAD.lock workaround on mounted folder)

**Shared resources:** Firebase project `b-things` shared with Content Calendar, B Resources, and Brain Inbox. AppSwitcher component shared across B Suite apps. Brain Inbox `handoff-notify` API used for Assign to Nico and NoteThread notifications.

---

## Content Calendar
**Status:** Active, fully functional
**Last updated:** March 16, 2026
**Location:** content-calendar/
**Live URL:** https://content-calendar-nine.vercel.app/
**Key context:**
- Manages content across YouTube Videos, YouTube Shorts, LinkedIn, Beehiiv newsletters
- 11-stage pipeline from Ghost → Published with auto-archiving
- Vercel serverless proxies for Beehiiv and YouTube APIs
- **NoteThread chat system**: iMessage-style threaded messaging on each card. Messages stored in `contentCards/{cardId}/messages` subcollection. Bi-directional @mention notifications via Slack DM + Brain Inbox. Notification toast feedback added March 16. Calls `handoff-notify` directly without Content-Type header (CORS avoidance). Unread indicators on cards. User registry in `src/users.js`.
- **handoff-notify endpoint** (brain-inbox) routes notifications to any user by email — not just Nico. Resolves Firebase UID at runtime via Admin Auth.

**Shared resources:** Firebase project `b-things`. AppSwitcher component.

---

## Brain Inbox (B Nico)
**Status:** Active, functional with Slack integration
**Last updated:** March 14, 2026
**Location:** brain-inbox/
**Live URL:** https://brain-inbox-six.vercel.app
**GitHub:** https://github.com/brhecht/brain-inbox
**Key context:**
- Nico's triage inbox — captures Slack @mentions and DMs, converts to tasks
- Slack Bot API integration via Vercel serverless function
- Part of B Suite ecosystem
- **Sole deployer of Firestore rules** for the b-things Firebase project. `firebase.json` points to local `firestore.rules` which contains the canonical ruleset for all apps sharing the b-things project.
- **Also hosts all Firebase Cloud Functions for `b-things`** — `functions/index.js` contains both the Brain Inbox Slack trigger AND the Content → Things sync trigger. This is a tech debt issue: cross-app Cloud Functions shouldn't live inside a single app's repo.
- `firebase.json` updated March 14: rules reference changed from `../firestore.rules` to `firestore.rules` (local). Complete canonical ruleset now git-tracked here.

**Shared resources:** Firebase project `b-things`. AppSwitcher component.

---

## B Hub (Suite Homepage & App Switcher)
**Status:** Live — homepage portal linking to all B-Suite apps
**Last updated:** March 5, 2026
**Location:** bhub/
**Live URL:** https://b-hub-liard.vercel.app
**GitHub:** https://github.com/brhecht/bhub
**Key context:**
- Static HTML homepage with card grid linking to all B-Suite apps
- 8 app cards: Eddy, Things, Content, People, Nico, BPIs, Marketing, Resources
- B Marketing and B Resources cards link to their standalone React apps
- Auto-deploys from GitHub main branch via Vercel

**Shared resources:** Design system reference used by hc-funnel, b-marketing, b-resources.

---

## B Marketing (Marketing Hub)
**Status:** Just scaffolded — hub page live, no app-specific functionality yet
**Last updated:** March 5, 2026
**Location:** b-marketing/
**Live URL:** https://b-marketing.vercel.app
**GitHub:** https://github.com/brhecht/b-marketing
**Key context:**
- Standalone React app serving as the entry point for all HC marketing tools
- Currently links out to HC Funnel (quiz) with 3 placeholder slots (ads, email, analytics)
- React Router pre-wired for future routes (/quiz, /ads, /email, /analytics)
- Firebase configured to share `eddy-tracker-82486` project with hc-funnel and eddy

**Shared resources:** Firebase project `eddy-tracker-82486` (shared with eddy and hc-funnel).

---

## B Resources (Knowledge & Assets Hub)
**Status:** Just scaffolded — sub-menu and coming-soon pages only, no DB functionality
**Last updated:** March 14, 2026
**Location:** b-resources/
**Live URL:** https://b-resources.vercel.app
**GitHub:** https://github.com/brhecht/b-resources
**Key context:**
- Standalone React app for Library (frameworks/playbooks) and Vault (brand assets/templates)
- Both sections are "coming soon" — no Firestore usage yet
- Config-driven ComingSoon component renders both Library and Vault pages
- Uses `b-things` Firebase project for Storage rules only
- `firebase.json` updated March 14: `firestore` section removed. Only `storage` remains. This prevents b-resources from ever overwriting shared Firestore rules.

**Shared resources:** Firebase project `b-things` (Storage only, no Firestore deploy capability).

---

## B People
**Status:** Active, functional CRM/contacts tool
**Last updated:** March 14, 2026
**Location:** b-people/
**Live URL:** https://b-people.vercel.app
**Key context:**
- Contact/people management tool with notes per contact and activity feed
- Firebase project: `b-people-759e5` (own project, not shared with b-things)
- Firestore collections: `contacts`, `contacts/{id}/notes`, `feed_items`
- Updated March 14: Firebase config migrated from hardcoded credentials to `VITE_FIREBASE_*` env vars (matching all other repos). `.env` file created locally, `.env.example` committed for new device setup. All 6 `VITE_FIREBASE_*` vars added to Vercel production via API. ✅ DONE

---

## Pitch Scorer
**Status:** Archived / abandoned — only a README and eslint config remain locally
**Location:** pitch-scorer/
**Key context:** Was a Jules-generated React prototype (Landing → Assessment → Results). Decided to build from scratch instead (became hc-funnel). GitHub repo should be archived when gh CLI auth is resolved.

---

## HC Website (humbleconviction.com)
**Status:** Live — functional but layout width needs fixing
**Last updated:** March 11, 2026
**Location:** hc-website/
**Live URL:** https://humbleconviction.com
**GitHub:** https://github.com/brhecht/hc-website
**Key context:**
- Migrated from Carrd to Next.js 16.1.6 (App Router, TypeScript, Tailwind v4) on Vercel
- Single-page homepage: hero, email capture (Kit/ConvertKit proxy), YouTube embed, Call for Founders, bio
- Domain: GoDaddy A record → Vercel IP, SSL provisioned
- **Primary issue:** Layout width doesn't look right on Brian's multi-monitor setup (Chrome viewport 3494px, screen.width 1920px). Content structure and design are approved — only width remains.
- **Headshot image is 0 bytes** — user needs to provide actual photo file
- Kit env vars: KIT_API_KEY + KIT_FORM_ID (in .env.local and Vercel)
- Git push requires clone-to-/tmp workaround (mounted drive has HEAD.lock issues)
- Full handoff: `hc-website/HANDOFF-Website-2026-03-11.md`

**Shared resources:** Kit (ConvertKit) account under Humble Conviction. No Firebase dependency.

---

## Cross-Project Dependencies

- **eddy + hc-funnel** share Firebase project `eddy-tracker-82486` (same Firestore instance, separate collections: eddy uses `users/{uid}/*`, hc-funnel uses `leads`)
- **hc-funnel** marketing tasks are tracked in **eddy** (W1 tasks: messaging angles, quiz structure, ad creatives, target audiences)
- **hc-course** (not yet started) is gated by waitlist validation data from **hc-funnel**
- **bhub** `index.html` is the design reference for **hc-funnel**'s warm light theme
- **things-app, content-calendar, brain-inbox, b-resources** all share Firebase project `b-things` and the AppSwitcher component — but **only brain-inbox can deploy Firestore rules** (see Firestore Rules section above)
- **things-app** has viewer mode for Nico; **brain-inbox** is Nico's primary tool — both part of the Brian↔Nico workflow
- **Content Calendar → B Things real-time sync** — Firestore trigger (`syncContentToThings`) fires on any `contentCards` write. If `dueDate` matches today and card isn't published/archived, creates a task in B Things under HC Content / Today. Deduplicates via `sourceCardId`. Function lives in `brain-inbox/functions/index.js` (see tech debt note above). Also has a Vercel cron backup at `things-app/api/content-today.js` (daily at 7am ET) but the Firestore trigger handles real-time.
- **bhub** links to **b-marketing** (standalone app) and **b-resources** (standalone app) as sub-hubs
- **b-marketing** links out to **hc-funnel** for the quiz; will eventually embed or route to more marketing tools
- **b-resources** uses **b-things** Firebase project for Storage only (Firestore deploy removed March 14)
- **gh CLI auth** is resolved — repos can now be archived

---

## All B-Suite Live URLs
| App | Live URL | GitHub |
|-----|----------|--------|
| B Hub | https://b-hub-liard.vercel.app | brhecht/bhub |
| B Eddy | https://eddy-tracker.vercel.app | brhecht/eddy |
| B Things | https://things-app-gamma.vercel.app | brhecht/things-app |
| B Content | https://content-calendar-nine.vercel.app | brhecht/content-calendar |
| B People | https://b-people.vercel.app | brhecht/b-people |
| B Nico | https://brain-inbox-six.vercel.app | brhecht/brain-inbox |
| BPIs | https://hc-kpi-dashboard.pages.dev | — |
| B Marketing | https://b-marketing.vercel.app | brhecht/b-marketing |
| B Resources | https://b-resources.vercel.app | brhecht/b-resources |
| HC Funnel | https://hc-funnel.vercel.app | brhecht/hc-funnel |
| HC Website | https://humbleconviction.com | brhecht/hc-website |
| Pitch Scorer | https://pitch-scorer.vercel.app | brhecht/pitch-scorer (archive) |

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

## Devices

Brian uses four machines. B-Suite folder location: `~/Developer/B-Suite/` on all devices (migrated from Desktop on March 14, 2026).

- **MacBook Pro** — primary dev machine. B-Suite path: `~/Developer/B-Suite/`. Skills: ✅ all three installed.
- **iMac (BRH iMac 2019)** — B-Suite path: `~/Developer/B-Suite/`. Fresh clone from GitHub March 16, 2026. Skills: handoff ✅, dev-deploy ✅, comms ✅. Note: username is BRHPro. **No Node.js installed** — use Firebase console for rules deploy.
- **MacBook Air** — path: `~/Developer/B-Suite/` (confirm on first session)
- **Mac Mini** — path: `~/Developer/B-Suite/` (confirm on first session)

---

## Local Machine Paths & Cowork Build Status

- **Git push from Cowork:** Now works autonomously. GitHub PAT (classic, `repo` scope) saved to `.git-token` in B-Suite root. At session start, Claude reads this file and configures git credentials in the VM. No terminal handoff needed for deploys. Token expires ~June 2026 — regenerate at github.com/settings/tokens when it does.
- **Git push command pattern (terminal fallback):** `cd ~/Developer/B-Suite/<app-folder> && git push` (adjust path per device)
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
| hc-website | ✅ | Next.js 16.1.6, builds clean in Cowork |
| things-app | ❌ Cowork / ✅ Mac | PostCSS/Tailwind filesystem error in Cowork VM — builds fine on Mac. Retry Cowork next session, use terminal handoff for now |

---

## Backlog: Infrastructure

- **Extract shared Cloud Functions into dedicated repo** — Currently all Firebase Cloud Functions for `b-things` deploy from `brain-inbox/functions/`. This is confusing since the content-to-things sync has nothing to do with Brain Inbox. Future cleanup: create a `b-suite-functions/` repo (or similar) that owns all Firestore triggers across the ecosystem.
- **Remove Vercel cron from things-app** — `api/content-today.js` and `vercel.json` cron config can be removed once the Firestore trigger is confirmed stable (real-time is better). Keep for now as fallback.
- **GitHub PAT renewal** — Classic PAT (`cowork`, `repo` scope) saved to `.git-token` in B-Suite root. Expires ~June 2026. When it expires, generate a new one at github.com/settings/tokens (classic), `repo` scope, and update `.git-token`.
- **Implement `dmOnly` flag in handoff-notify.js** — The comms skill DM channel currently also writes to Brain Inbox and posts to the Slack channel when DMing Nico. Needs a code change to `brain-inbox/api/handoff-notify.js` to skip Firestore write and DM directly when `dmOnly: true`. Brian DM path already works correctly.
- **Intel replatform** — B Content's Intel module needs replatforming (known, scope TBD).

---

## Architecture Audit (March 14, 2026)

Full audit document: `~/Developer/B-Suite/B-Suite Architecture Audit.md`

Key findings and fixes applied:
1. ✅ b-resources defused (can't deploy Firestore rules)
2. ✅ Canonical `firestore.rules` created in brain-inbox (git-tracked, complete)
3. ✅ things-app stripped of Firestore deploy capability
4. ✅ brain-inbox confirmed as sole rules deployer
5. ✅ b-people migrated from hardcoded Firebase config to env vars

Auth patterns: All apps use Google Sign-In. State management split between Zustand (brain-inbox, content-calendar, b-people) and component-level useState (things-app, b-resources, eddy).

See audit doc for full Firestore collections-by-app reference table.
