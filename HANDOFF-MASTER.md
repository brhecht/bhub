# HANDOFF MASTER — B Suite
*Auto-generated: March 4, 2026 ~12:30 PM ET*
*Updated: April 3, 2026 — TNB pivot: tnb-strategy repo + skill created, hc-strategy archived*
*Source: Most recent handoff from each project*

---

## Session Bootstrap Protocol

**Claude must execute these steps automatically on every "handoff here" — no user prompting required.**

### 0. Mount Path
The user mounts `~/Developer/B-Suite/`. Inside the Cowork VM this appears at `/mnt/Developer/B-Suite/`. All repo paths follow the pattern `/mnt/Developer/B-Suite/<repo-name>/`. If the mount point is `~/Developer/` (the parent), B-Suite will be one level deeper — adjust accordingly. Always verify with `ls` before assuming paths.

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
Custom Cowork skills tracked for B-Suite sessions: **handoff**, **dev-deploy**, **comms**, and **expert**. This step checks both installation AND version currency.

**Skill files are git-tracked in `bhub/skills/`.** This means `git pull` on bhub gets the latest `.skill` installers on any device. The version manifest (`bhub/skills/skills-manifest.json`) tracks which version each device has installed.

**Bootstrap sequence:**
1. Run `git pull` on the bhub repo (ensures latest skill files are local). **Before pulling**, clean up any stale lock files and uncommitted Cowork artifacts that would block the pull:
   ```bash
   cd <bhub-path> && rm -f .git/index.lock .git/ORIG_HEAD.lock && git checkout -- . && git clean -fd skills/ && git pull
   ```
   This is necessary because Cowork edits files on the mounted drive but pushes via `/tmp` clones, leaving the mounted working tree dirty. The cleanup is safe — all changes are already on GitHub.
2. Read `bhub/skills/skills-manifest.json`
3. Identify current device from the Devices section
4. Compare device's installed hashes against the `skills` section hashes
5. For any mismatch or missing skill:
   - Present the `.skill` file as a clickable install link in chat: `[Install comms.skill](computer:///path/to/mnt/B-Suite/bhub/skills/comms.skill)`
   - Tell the user: "**[skill-name] was updated [date].** Click to install, then restart the session."
6. After user confirms install, update the device's hash in `skills-manifest.json` and commit to bhub

**If all skills are current** → proceed normally, no action needed. Just confirm: "All skills up to date."

**When a skill is updated (by anyone, on any device):**

Claude must handle all of the following automatically — the user should never have to ask for or think about these steps. If a skill's SKILL.md is modified during a session (via skill-creator, direct edit, or any other method), Claude must immediately execute this full pipeline before moving on:

1. Copy the updated SKILL.md to `bhub/skills/src/[name]-SKILL.md`
2. Rebuild the `.skill` bundle: create a directory named `[name]/` containing the SKILL.md, then `zip -r [name].skill [name]/`
3. Copy the `.skill` file to `bhub/skills/`
4. Compute the new hash: `md5sum` of the SKILL.md
5. Update `skills-manifest.json`: bump version, update hash, set changelog describing what changed, update the current device's hash entry
6. Commit and push bhub (use `/tmp/` clone workaround if mounted filesystem has lock issues)
7. Confirm to user: "Skill synced to bhub — other devices will be prompted to update on next session."

This is non-negotiable automation. The user should experience "we updated the skill" and "it's synced everywhere" as one seamless action, not two separate tasks.

**Tracked skills:** handoff, dev-deploy, comms, expert, hc-strategy, pm (see `skills-manifest.json` for current versions and per-device hashes)

**Devices with skills installed:**
- MacBook Pro: ✅ all six installed — handoff + dev-deploy stale (need v3.0.0 / v1.2.0), pm not yet installed. Last synced March 23.
- iMac: ✅ handoff, dev-deploy, comms, expert, hc-strategy — handoff + dev-deploy stale, pm not yet installed. Last synced March 28.
- MacBook Air: ✅ comms, expert, hc-strategy installed this session — handoff + dev-deploy stale (installed but old hashes), pm provided as install link. Last synced March 29-30.
- Mac Mini: ⬜ never set up for skills

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

## The New Builder (TNB) — Strategy & Business Context
**Status:** Active — scaffolded April 3, 2026. Strategy docs being written this weekend.
**Last updated:** April 3, 2026
**Location:** tnb-strategy/ — private git repo at github.com/brhecht/tnb-strategy (restricted access, Brian only)
**Skill:** `tnb-strategy.skill` in bhub/skills/ — install on each device to enable "TNB strategy check-in" and "quarterly review" triggers
**Key context:**
- The New Builder is a rebrand/pivot from Humble Conviction. AI as DNA, not accelerant. Full-stack founder engagement at the intersection of startups and AI.
- Target audience: "The New Builder" — capital-light, lab-mindset, DIY-technical, solopreneur-friendly founders building in the AI era
- The goal: become the person founders think of first when they realize AI has changed everything about how they need to build
- Four exposure outlets: LinkedIn (discovery), Podcast (relationships), YouTube (companion + clips), Newsletter (owned asset)
- Four revenue streams: War Room ($500/seat, 5 people × 4 weeks — core business engine), Personal Coaching ($5K/10-pack, War Room converts), Video Courses ($99-199, evergreen), Live Events (New Builder Happy Hour, Brian on stage)
- War Room serves four functions: coaching funnel, alumni network, monthly AMA, live market research
- Key principle: "Hearing Brian is the #1 sales tool" — podcast, YouTube, live events, War Room all put his live delivery in front of people
- Active legacy: HC quiz funnel + Meta ads running, coaching clients ongoing, Eddy course storyboarded. These continue during transition, not disrupted.
- TNB-the-company encompasses all revenue. TNB-the-brand is specifically AI-native founder development. Circles converge over time.

**Key files:**
- `STRATEGY-CONTEXT.md` — the strategic brain (read first) — skeleton, being written April 2026
- `operating-plan.md` — operating plan with revenue projections — skeleton, being written April 2026
- `HANDOFF.md` — session continuity

---

## HC Strategy (ARCHIVED — Superseded by TNB Strategy)
**Status:** Archived — superseded by tnb-strategy as of April 3, 2026. Retained for reference (expert research, probability models).
**Last updated:** March 24, 2026 (final)
**Location:** hc-strategy/ — private git repo at github.com/brhecht/hc-strategy
**Key context:**
- Five rounds of expert research (v1-v5) with probability-weighted scenarios — analytical frameworks still valid for reference
- HC positioning, product architecture, and operating plan are superseded by TNB
- Do not update these docs further. Git history preserved.

**Reference files (read-only):**
- `expert-analysis-v5.md` — comprehensive expert research with probability weighting, market comparables, SLO analysis
- `STRATEGY-CONTEXT.md` — the old HC strategic brain (March 24, 2026)
- `operating-plan.md` — the old 8-quarter HC plan

---

## Eddy (Course Launch Tracker)
**Status:** MVP complete, in active use by Brian and Nico
**Last updated:** March 23, 2026
**Location:** eddy/
**Live URL:** https://eddy-tracker.vercel.app
**Key context:**
- Gantt-style timeline + tool decision matrix + budget overview for coordinating HC course launch
- Firebase Firestore real-time sync between Brian and Nico
- Contains W1 task definitions that drive the marketing project (messaging angles, quiz structure, ad creatives, etc.)
- Firebase project: `eddy-tracker-82486` (separate from B Suite's `b-things` project)
- No app changes March 23 — pipeline progress tracked in hc-funnel

**Shared resources:** Firebase project `eddy-tracker-82486` is shared with hc-funnel (same Firestore instance, separate collections)

---

## HC Funnel (Marketing Funnel)
**Status:** Launch-ready — all ad creative final, primary text locked, waiting on Nico to swap copy in Meta Ads Manager
**Last updated:** March 26, 2026
**Location:** hc-funnel/
**Live URL:** https://hc-funnel.vercel.app (also https://quiz.humbleconviction.com)
**Key context:**
- Complete rewrite (March 15): 8 scenario-based questions (not self-assessment) across 4 dimensions (Clarity, Investor Fluency, Self-Awareness, Persuasion Instincts)
- Scoring engine: per-question best=2/next=1/weak=0, raw totals for tier assignment, display scores as X/5 with dot visualization
- 3 tiers: Lost in the Noise (raw 0-3) / The Pieces Are There (raw 4-9) / So Close It Hurts (raw 10+). Validated via Monte Carlo simulation (10K runs).
- Results page: calculating pause animation → tier badge → scorecard → email gate CTA → personalized AI action plan email
- **Action plan email pipeline (March 23):** `api/action-plan.js` — Claude Sonnet generates personalized email → 3-layer self-eval audit → branded HTML → Resend delivery
- **Ad creative (March 24-26):** 3 concepts × 2 formats built in Canva. Primary text completely rewritten March 25-26 in line-by-line editorial session with Brian. All copy locked. Canonical brief: `ads/AD-CREATIVE-BRIEF-V3-FINAL.md`
- **Meta launch plan:** $150/day across 3 creatives, 7-day learning phase lockdown, day 14 pulse check. Documented in `ads/META-LAUNCH-PLAN.md`
- Meta Pixel wired (4 events). GA4 env var still not set. LAUNCH_STATUS env var still not set.
- Firestore `leads` collection captures quiz answers, scores, tier, waitlist flag
- Kit (ConvertKit) integration with server-side proxy; Resend for action plan delivery
- **Next step:** Nico swaps primary text in Meta Ads Manager → Brian adds credit card → launch

**Shared resources:** Firebase project `eddy-tracker-82486` (shared with eddy and b-marketing). Kit account under Humble Conviction. Anthropic API + Resend API keys in Vercel env vars.

---

## B Things (Personal Task Manager)
**Status:** Active, fully functional
**Last updated:** March 18, 2026
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
- **Smart title fallback (March 18)** — content→things sync now uses a `cardTitle()` function with fallback chain: card title → archiveData title + type label → type label alone → "(untitled content)"
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

## B Hub (Suite Homepage, App Switcher & Infrastructure)
**Status:** Live — homepage portal + central infrastructure repo (skills, bsync, master handoff)
**Last updated:** March 30, 2026
**Location:** bhub/
**Live URL:** https://b-hub-liard.vercel.app
**GitHub:** https://github.com/brhecht/bhub
**Key context:**
- Static HTML homepage with card grid linking to all B-Suite apps
- 8 app cards: Eddy, Things, Content, People, Nico, BPIs, Marketing, Resources
- Auto-deploys from GitHub main branch via Vercel
- **Infrastructure home:** All Cowork skills (source in `skills/src/`, bundles in `skills/*.skill`), `skills-manifest.json` for cross-device version tracking, `bsync.sh` v2 bootstrap script, and this HANDOFF-MASTER.md
- **bsync.sh v2 (March 29-30):** Single-command bootstrap — pulls all 11 repos, cross-checks handoff freshness against git history, verifies skill hashes, outputs structured JSON. EPERM fallback to /tmp clones. Three modes: full, --pull-only (LaunchAgent), --status (offline).
- **PM skill v1.0.0 (March 30):** Product manager skill for Brian↔Nico workflow. Five phases: Discovery → Brief (PM-BRIEF-<app>.md with acceptance criteria, decision map) → Plan → Build (soft gates, check-ins, 24hr auto-escalate) → Delivery. Includes B-Suite UX Standards reference doc (14 categories). Email memo sent to Nico.
- **Handoff skill v3.0.0 (March 29):** Replaced manual bootstrap with bsync. Added stamp-on-push protocol. Three-layer resilience: bsync (belt), stamps (belt+), handoff-away (suspenders).
- **Dev-deploy skill v1.2.0 (March 29):** Added stamp-on-push to deploy chain.
- **Skills tracked:** handoff (v3.1.0), dev-deploy (v1.2.0), comms (v1.0.0), expert (v1.0.0), hc-strategy (v1.0.0, archived), tnb-strategy (v1.0.0, new), pm (v1.0.0)
- **Pending skill installs:** MacBook Air needs handoff v3.0.0 + dev-deploy v1.2.0. MacBook Pro and iMac have stale hashes for both. Mac Mini never set up.

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
**Status:** Active — major UX overhaul March 29. Modal is now the single editing surface (inline-edit title, group, tags, notes, messages). Side panel preview for rendered content. 9 bugs fixed, 12 improvements shipped.
**Last updated:** March 29, 2026
**Location:** b-resources/
**Live URL:** https://b-resources.vercel.app
**GitHub:** https://github.com/brhecht/b-resources
**Key context:**
- Standalone React app for Library (documents/frameworks/playbooks), Vault (brand assets/templates), and Groups (kanban-style boards)
- **March 29 overhaul:** Card click → modal with everything editable inline (title, group, tags, notes, messages). No separate edit mode. Modeled after B Things. Side panel preview via 👁 button for rendered document content.
- Kanban cards now show: displayTitle (dominant), filename (secondary), colored tag pills with inline editing, pin 📌 toggle (always visible), AI summary hover tooltip, relative timestamps, download ⬇ link, preview 👁 button
- `api/fetch-content.js` — Vercel serverless proxy for CORS bypass on Firebase Storage URLs
- `EditableTitle` component for click-to-edit titles in modals. `InlineNotes` for persistent notes. `CollapsibleMessages` for iMessage-style threading.
- `displayTitle()` helper in multiple files — strips extensions, replaces hyphens/underscores, title-cases
- GroupKanban has its own `renderItemCard()` that bypasses ResourceCard — card changes must be made there directly
- Full CRUD on Library and Vault with CollapsibleComments (Firestore sub-collections), @mention notifications via Slack/Brain Inbox
- Slack bot pipeline set up (app `A0APJCW2DLZ`) but **not receiving events** — needs Brian to reinstall at https://api.slack.com/apps/A0APJCW2DLZ/install-on-team
- ⚠️ **DO NOT deploy Firestore rules from this repo.** The `firestore.rules` file contains stale/incorrect rules. `firebase.json` only has `storage`. Canonical rules deployer is brain-inbox.
- Vercel serverless functions: `api/slack-events.js`, `api/slack-inbox-reminder.js`, `api/fetch-content.js`
- **Known issues:** Slack bot not receiving events (needs reinstall). Architecture issues identified (separate discussion). Brian QAing March 29 deploy.
- **Next steps:** QA live site, address any issues from March 29 deploy, re-test Slack bot after reinstall, test CollapsibleMessages on prod, run seed script, mobile responsive testing

**Shared resources:** Firebase project `b-things` (Storage only — no Firestore deploy capability).

---

## B People
**Status:** Active — v1 functional with Today's 3 nudge engine, shifting from contact directory to relationship nudge tool
**Last updated:** March 23, 2026
**Location:** b-people/
**Live URL:** https://b-people.vercel.app
**Key context:**
- Personal relationship management tool — shifting from "contact directory with cadence timers" to relationship nudge engine
- **Today's 3 (March 23):** Daily rotation algorithm surfaces 3 contacts worth reaching out to. Date-seeded PRNG, group-weighted, time-since-last-touch biased. Replaced dashboard tab. Vercel cron at 9 AM ET creates B Things task via add-task API.
- Google Contacts photo sync via People API (contacts.readonly scope)
- Click-to-edit name/title/company in contact detail. Inline group management in contacts table.
- Firebase project: `b-people-759e5` (own project, not shared with b-things). Zustand + Firestore lite SDK.
- `getBestEmail()` smart email picker filters non-email values from emails array (bug fix March 23)
- v2 roadmap: Gmail auto-ingest, calendar signals, LinkedIn monitoring

---

## Pitch Scorer
**Status:** Archived / abandoned — only a README and eslint config remain locally
**Location:** pitch-scorer/
**Key context:** Was a Jules-generated React prototype (Landing → Assessment → Results). Decided to build from scratch instead (became hc-funnel). GitHub repo should be archived when gh CLI auth is resolved.

---

## HC Website (humbleconviction.com)
**Status:** Live — functional but layout width needs fixing. Next.js bumped to 16.2.1 (security, March 31).
**Last updated:** March 31, 2026
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

- **MacBook Pro** — primary dev machine. B-Suite path: `~/Developer/B-Suite/`. Lock-file cron: ✅ installed April 3, 2026.
- **iMac (BRH iMac 2019)** — B-Suite path: `~/Developer/B-Suite/`. Fresh clone from GitHub March 16, 2026. Note: username is BRHPro. **No Node.js installed** — use Firebase console for rules deploy. Lock-file cron: ⬜ not installed.
- **MacBook Air** — path: `~/Developer/B-Suite/` (confirm on first session). Lock-file cron: ⬜ not installed.
- **Mac Mini** — path: `~/Developer/B-Suite/` (confirm on first session). Lock-file cron: ⬜ not installed.

### Lock-File Cron (Per-Device Setup)

Cowork sessions leave stale `.git/index.lock` files when they time out mid-operation. These block all git operations on subsequent sessions. A cron job cleans them automatically.

**Bootstrap check:** At session start, if the master handoff shows this device's cron as ⬜, prompt the user to install it:

```bash
(crontab -l 2>/dev/null; echo '*/30 * * * * find ~/Developer/B-Suite -name "index.lock" -mmin +5 -delete 2>/dev/null') | crontab -
```

After user confirms, update the device's status in this section to ✅ and push the master.

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
| hc-website | ✅ | Next.js 16.2.1 (bumped March 31 security audit), builds clean in Cowork |
| things-app | ❌ Cowork / ✅ Mac | PostCSS/Tailwind filesystem error in Cowork VM — builds fine on Mac. Retry Cowork next session, use terminal handoff for now |

---

## Backlog: Infrastructure

- **Extract shared Cloud Functions into dedicated repo** — Currently all Firebase Cloud Functions for `b-things` deploy from `brain-inbox/functions/`. This is confusing since the content-to-things sync has nothing to do with Brain Inbox. Future cleanup: create a `b-suite-functions/` repo (or similar) that owns all Firestore triggers across the ecosystem.
- **Remove Vercel cron from things-app** — `api/content-today.js` and `vercel.json` cron config can be removed once the Firestore trigger is confirmed stable (real-time is better). Keep for now as fallback.
- **GitHub PAT renewal** — Classic PAT (`cowork`, `repo` scope) saved to `.git-token` in B-Suite root. Expires ~June 2026. When it expires, generate a new one at github.com/settings/tokens (classic), `repo` scope, and update `.git-token`.
- **Implement `dmOnly` flag in handoff-notify.js** — The comms skill DM channel currently also writes to Brain Inbox and posts to the Slack channel when DMing Nico. Needs a code change to `brain-inbox/api/handoff-notify.js` to skip Firestore write and DM directly when `dmOnly: true`. Brian DM path already works correctly.
- **Intel replatform** — B Content's Intel module needs replatforming (known, scope TBD).
- **bsync LaunchAgent setup** — `com.bsuite.bsync.plist` exists but hasn't been installed on any Mac yet. Runs bsync --pull-only in background to keep repos fresh.
- **priority-startup-intel + create-content skills** — not yet tracked in skills-manifest.json. Consider adding for cross-device consistency.

---

## Security Audit (March 31, 2026)

Full npm supply chain audit across all 9 B-Suite repos with package.json.

**Supply chain attack check (axios 1.14.1 / plain-crypto-js):** All repos clean. No axios dependency anywhere (gaxios in Firebase SDK is unrelated). No plain-crypto-js found in any lockfile or node_modules.

**Fixes applied:**
1. ✅ **hc-website** — Next.js 16.1.6 → 16.2.1. Fixed 5 moderate vulns: HTTP request smuggling, CSRF bypass (null origin), unbounded disk cache growth, postponed resume DoS, dev HMR websocket CSRF. Build verified clean.
2. ✅ **things-app** — npm audit fix patched node-forge (signature forgery, cert chain bypass, DoS). 11 → 8 low remaining (deep transitive, require breaking changes).
3. ✅ **brain-inbox** — npm audit fix patched node-forge + fast-xml-parser (entity expansion bypass). 11 → 8 low remaining.
4. ✅ **content-calendar** — npm audit fix patched node-forge + fast-xml-parser. 10 → 8 low remaining.
5. ✅ **b-people** — Firebase SDK bumped 10.8.0 → 12.11.0 to patch undici vulns in @firebase/functions and @firebase/storage. 21 → 8 low remaining.
6. ✅ **b-marketing, b-resources, eddy, hc-funnel** — 0 vulnerabilities, no action needed.

**Remaining (8 low across 4 repos):** All are deep transitive deps (protobufjs prototype pollution) inside Firebase/Google Cloud SDK. Require major version bumps of upstream packages to resolve. Low real-world risk — these are serialization libs not exposed to user input in B-Suite's usage pattern. Monitor for upstream fixes.

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
