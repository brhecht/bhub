# HANDOFF MASTER — B Suite
*Auto-generated: March 4, 2026 ~12:30 PM ET*
*Updated: April 11, 2026*
*Source: Most recent handoff from each project*

> **April 11, 2026 — Eddy killed + TNB strategy check-in.** Eddy unit economics evaluated: profitability highly unrealistic at any price point. Recommendation: finish Week 2 checkpoint April 14, shut down paid ads, keep quiz as free organic tool, do not record the course. Full analysis: `hc-funnel/research/eddy-unit-economics-april-2026.md`. TNB Phase 1 in progress: podcast ep 1 dropping April 14 (Scott Werner/Sublayer), MVHH 2.0 done (~30 founders), LinkedIn rhythm strong. War Room format shifted to one-shot group tests starting ~April 21. Strategy docs updated with Week 1 actuals and revised 5-week timeline. See `tnb-strategy/STRATEGY-CONTEXT.md`.
>
> **March 20, 2026 — HC Funnel pre-launch.** Action plan email pipeline fully wired: quiz → email capture → Firestore + Kit + Claude-generated personalized action plan via Resend. Meta Pixel installed. Ad launch target: week of March 23. Kit nurture drip postponed (no course yet). All B-Suite repos now at `~/Developer/B-Suite/` on MacBook Pro (moved from Desktop March 12). Full Nico spec committed: `hc-funnel/NICO-SPEC-ACTION-PLAN-LAUNCH.md`.
>
> **March 9, 2026 — iCloud Sync Recovery + Two-Way Messaging:** MacBook Pro recovered from iCloud sync deadlock. Two-way messaging now live in B Things: @brian and @nico both route notifications correctly. Nico can create tasks for Brian from Slack using `--notes` flag.

---

## Session End Rule

**No session ends without all modified B-Suite files committed and pushed to GitHub.** The mounted drive is not persistent between sessions — if it's not in git, it's gone. This applies even if the user doesn't explicitly say "handoff away." If a session is ending (user says goodbye, switches devices, or context is running low), push all uncommitted work before responding. This is non-negotiable.

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
**Status:** Ads live, recommendation to kill paid marketing after April 14 checkpoint. Eddy course unit economics evaluated — profitability highly unrealistic. Keep quiz as free organic tool.
**Last updated:** April 11, 2026
**Location:** hc-funnel/
**Live URL:** https://quiz.humbleconviction.com (also https://hc-funnel.vercel.app)
**Key context:**
- 8-question Founder Assessment → 4-dimension scoring → tier result + scorecard → email gate → AI-generated personalized action plan via Claude API + Resend
- Full pipeline: quiz → email capture → Firestore `leads` + Kit (`quiz-lead` tag) + Claude action plan email (personalized per user's specific quiz answers, not just scores)
- Meta Pixel installed (ID: `1407883507304464`) — PageView, ViewContent, CompleteRegistration, Lead events
- Kit nurture drip (Emails 2-5) postponed — no course to sell yet. Leads added to newsletter manually.
- **Eddy unit economics: structurally broken.** Full analysis in `research/eddy-unit-economics-april-2026.md`. Week 2 checkpoint April 14, then ads off.
- See `hc-funnel/HANDOFF.md` for full detail

**Shared resources:** Firebase project `eddy-tracker-82486` (shared with eddy). Kit account under Humble Conviction. Resend (results@humbleconviction.com). Anthropic API.

---

## B Things (Personal Task Manager)
**Status:** Active, fully functional, two-way messaging live
**Last updated:** March 9, 2026
**Location:** things-app/
**Live URL:** https://things-app-gamma.vercel.app
**Key context:**
- Kanban-style task board with time-based columns, project grouping, drag-and-drop
- **Two-way messaging** between Brian and Nico via NoteThread (iMessage-style chat on each task)
- @brian → Slack DM to Brian. @nico → Brain Inbox Slack channel + Firestore
- **Slack → task creation:** Nico sends `title --notes message` in Slack → creates task in "From Nico" project with NoteThread message
- Viewer mode for Nico (can view tasks + send/receive messages)
- Notification proxy at `/api/notify` (replaced `/api/notify-nico`)
- Firebase project: `b-things`

**Shared resources:** Firebase project `b-things` shared with Content Calendar, B People, and Brain Inbox. AppSwitcher component shared across B Suite apps.

---

## Content Calendar
**Status:** Active, fully functional
**Last updated:** March 7, 2026
**Location:** content-calendar/
**Live URL:** https://content-calendar-nine.vercel.app/
**Key context:**
- Manages content across YouTube Videos, YouTube Shorts, LinkedIn, Beehiiv newsletters
- 11-stage pipeline from Ghost → Published with auto-archiving
- Vercel serverless proxies for Beehiiv and YouTube APIs
- **NoteThread chat system** (added March 7): iMessage-style threaded messaging on each card, replacing the old plain-text notes field. Messages stored in `contentCards/{cardId}/messages` subcollection. Bi-directional @mention notifications via Slack DM + Brain Inbox. Unread indicators on cards. User registry in `src/users.js`. Legacy notes auto-migrate as first message.
- **handoff-notify endpoint** (brain-inbox) updated to route notifications to any user by email — not just Nico. Resolves Firebase UID at runtime via Admin Auth.

**Shared resources:** Firebase project `b-things`. AppSwitcher component.

---

## Brain Inbox (B Nico)
**Status:** Active, functional — also serves as B Suite notification router
**Last updated:** March 9, 2026
**Location:** brain-inbox/
**Live URL:** https://brain-inbox-six.vercel.app
**GitHub:** https://github.com/brhecht/brain-inbox
**Key context:**
- Nico's triage inbox — captures Slack @mentions and DMs, converts to tasks
- **Notification router for all B Suite two-way messaging** — `handoff-notify.js` routes per-recipient (Nico → Brain Inbox Slack channel, Brian → Slack DM)
- **Slack → B Things task creation** — `nico-slack.js` with `--notes` flag creates tasks in Brian's B Things (project "from-nico") with NoteThread first message
- Slack Bot API integration via Vercel serverless function
- **Also hosts all Firebase Cloud Functions for `b-things`** — `functions/index.js` contains both the Brain Inbox Slack trigger AND the Content → Things sync trigger. Tech debt: should be extracted to dedicated repo.

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
- **Deploy issue:** Not wired to GitHub auto-deploy. Was deployed via `npx vercel --yes --prod`. AppSwitcher is in code but live site runs stale build without it. Needs Vercel GitHub connection or manual deploy.

**Shared resources:** Firebase project `eddy-tracker-82486` (shared with eddy and hc-funnel).

---

## B Resources (Knowledge & Assets Hub)
**Status:** Just scaffolded — sub-menu and coming-soon pages only, no DB functionality
**Last updated:** March 5, 2026
**Location:** b-resources/
**Live URL:** https://b-resources.vercel.app
**GitHub:** https://github.com/brhecht/b-resources
**Key context:**
- Standalone React app for Library (frameworks/playbooks) and Vault (brand assets/templates)
- Both sections are "coming soon" — no Firestore usage yet
- Config-driven ComingSoon component renders both Library and Vault pages
- Will use `b-things` Firebase project when DB is needed

**Shared resources:** Firebase project `b-things` (planned, not yet active).

---

## B People
**Status:** No handoff found — context unknown
**Location:** b-people/
**Live URL:** https://b-people.vercel.app
**Key context:** Has source code, Firebase config, and Firestore rules. Appears to be a contact/people management tool. No handoff doc available.

---

## Pitch Scorer
**Status:** Archived / abandoned — only a README and eslint config remain locally
**Location:** pitch-scorer/
**Key context:** Was a Jules-generated React prototype (Landing → Assessment → Results). Decided to build from scratch instead (became hc-funnel). GitHub repo should be archived when gh CLI auth is resolved.

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
| HC Funnel | https://quiz.humbleconviction.com | brhecht/hc-funnel |
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

Brian uses three machines. B-Suite folder location may vary by device — confirm path on first use if not listed.

- **MacBook Pro** — primary dev machine. B-Suite path: `~/Developer/B-Suite/` *(freshly cloned March 20, 2026 — replaced B-Suite-Clean which no longer exists)*
- **MacBook Air** — B-Suite path: `~/Desktop/B-Suite/` (healthy, unaffected by iCloud issue)
- **Mac Mini** — B-Suite path: `~/Desktop/B-Suite/` (healthy, unaffected by iCloud issue)

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

## Known Issues

- **B Marketing deploy not wired to GitHub** — `b-marketing.vercel.app` was originally deployed via `npx vercel --yes --prod` and does not auto-deploy from GitHub pushes. The AppSwitcher component is in the code (App.jsx renders it) but the live site is running a stale build that doesn't show it. Fix: either connect the GitHub repo in the Vercel dashboard (Settings → Git → Connected Git Repository) or run `npx vercel --yes --prod` from the b-marketing folder to pick up current code. Same likely applies to `b-resources`.

---

## Backlog: Infrastructure

- **Install dev-deploy skill on all devices** — Updated `dev-deploy.skill` is in B-Suite root folder (updated March 6 with Git Auto-Config section). Must be double-clicked to install on each device (MacBook Pro, MacBook Air, Mac Mini). One-time per device. Track which devices have it installed:
  - MacBook Pro: ⬜ pending
  - MacBook Air: ⬜ pending
  - Mac Mini: ⬜ pending
- **GitHub PAT renewal** — Classic PAT (`cowork`, `repo` scope) saved to `.git-token` in B-Suite root. Expires ~June 2026. When it expires, generate a new one at github.com/settings/tokens (classic), `repo` scope, and update `.git-token`.
- **Extract shared Cloud Functions into dedicated repo** — Currently all Firebase Cloud Functions for `b-things` deploy from `brain-inbox/functions/`. This is confusing since the content-to-things sync has nothing to do with Brain Inbox. Future cleanup: create a `b-suite-functions/` repo (or similar) that owns all Firestore triggers across the ecosystem.
- **Remove Vercel cron from things-app** — `api/content-today.js` and `vercel.json` cron config can be removed once the Firestore trigger is confirmed stable (real-time is better). Keep for now as fallback.
