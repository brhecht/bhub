# HANDOFF MASTER — B Suite
*Auto-generated: March 4, 2026 ~12:30 PM ET*
*Updated: April 24, 2026*
*Source: Most recent handoff from each project*

> **April 24, 2026 — UX Standards doc moved into bhub.** Canonical B-Suite UX reference (modals, toasts, inline edit, DnD, nav, responsive, design system, keyboard shortcuts, data patterns, messaging) is now at `bhub/UX-STANDARDS.md` with an HTML viewer at `bhub/ux-standards-view.html`. Previously lived loose at `Developer/ux-standards-review.html` (deleted). PM briefs reference this doc as the source of truth for cross-app UX — deviations require Brian's approval. See "Cross-Project Dependencies" and "UX Standards" sections below.
>
> **April 22, 2026 — B Hub rebranded + TNB announcement newsletter drafted.** B Hub homepage copy updated: all "Humble Conviction" references replaced with "The New Builder" (topbar, hero subtext, BPIs card, footer). Hero subtext now reads "powering The New Builder. From content planning to project management." Deployed and verified live at b-hub-liard.vercel.app. TNB announcement newsletter (HC → TNB pivot) fully drafted in `tnb-strategy/NEWSLETTER-ANNOUNCEMENT-DRAFT.md` — ~610 words, pending Brian's final review before publish to Beehiiv/Substack.
>
> **April 21, 2026 — Builder Bot briefed and approved.** New standalone repo `brhecht/builder-bot` created. PM brief approved for daily Slack recap bot for The New Builder community workspace. Posts weekday 9:30am ET to #daily-recap-bot. Reads #introduce-yourself, #share-and-discuss, #what-im-building, #general. Claude-curated editorial summaries, cumulative lookback per channel via Vercel KV, carry-forward intro logic. Nico notified via Brain Inbox + env vars DMed. See `builder-bot/PM-BRIEF-builder-bot.md`.
>
> **April 21, 2026 (pm) — Recap scope rule added.** New "Status Recap Rules" section below: Claude status recaps stay in the tech/Cowork lane only. Business to-dos (War Room, podcast, content) live in B Things, not in handoff recaps. Also deleted orphaned `PM-BRIEF-hc-website.md` from Developer root (pre-TNB-pivot spec, superseded).
>
> **April 21, 2026 — Mid-week status sync.** Newsletter platform decision: **switching from Beehiiv to Substack next week.** TNB website Beehiiv env vars are NOT being added — subscribe form stays inert until the Substack swap. Live traffic to thenewbuilder.ai is effectively zero right now; Nico is catching any strays via a Google Form. **Podcast:** Ep 1 (Scott Werner) shipped Apr 14; Ep 2 (Davida Ginter) recorded, drops Apr 22. **War Room one-shot group tests:** picking participants deferred to week of Apr 27 (was Apr 21). **bhealth:** iMac audit still pending — encountering "workspace setup" issues that need to be unblocked before bhealth can run there. Mini, Pro, Air all clean.
>
> **April 18, 2026 — Fleet audit infrastructure + cross-device cleanup.** Built `bhealth.sh` (in bhub) — per-Mac fleet audit with three-tier healing (auto-heal / launch-and-prompt / flag). Parallelized `bsync.sh` to v2.2 (14 repos cloned concurrently, ~40% faster handoff-here). Audited Mac Mini, MacBook Pro, MacBook Air — all fleet-ready after cleaning ~5 weeks of ghost drift (local working-tree state left behind from pre-migration). Added two new master handoff sections: **Notification Routing Rules** (Brain Inbox is Nico's domain — Brian's reminders → B Things) and **bhealth — Fleet Audit Playbook** (workflow for any Claude session to triage future audits). Corrected device roles: Mini/iMac are primaries (home/office), MacBook Pro is the always-carry travel companion, Air is light travel only. Scheduled `weekly-fleet-audit-check` (Mondays 8am ET) that posts staleness summary to B Things. iMac audit pending next office visit.
>
> **April 14, 2026 — B Content UX overhaul + direct email + B Hub cleanup.** Rich text editing on all Content Calendar body fields, Enter-to-save+close keyboard shortcut (with ⌘+Enter), mobile responsive CardModal, Ghost + Hold views with shared StatusListView, dateless card warning. ⌘+Enter and button Enter prevention ported to B Things. B Hub: renamed B Eddy → B Projects, swapped card positions, trimmed app switcher to 4 apps. Brain-inbox: new `api/send-email.js` endpoint for direct Gmail sends via SMTP (Nodemailer). Comms skill updated to send emails directly instead of creating drafts. Dev-deploy skill updated with Claude in Chrome mandate and mobile-responsive coding rules.
>
> **April 15, 2026 — TNB website design approved + repo architecture cleaned up.** TNB homepage fully designed with Brian: hero (photo left, tagline right), story section, "Builders Figuring it Out. Together." 3x2 product grid (Podcast, YouTube, Newsletter, War Room, Meetups, Curated Events), YouTube embed, newsletter subscribe, bio. TNB website separated into its own repo (`brhecht/tnb-website`, to be created) from the `tnb-coming-soon` branch of `hc-website`. hc-website documented with HANDOFF.md for first time. Both repos added to bsync and master handoff. Nico brief packaged for implementation. bsync.sh updated to v2.1 with both new repos.
>
> **April 12-13, 2026 — TNB positioning locked.** All TNB positioning language locked in standalone `tnb-strategy/POSITIONING-LANGUAGE.md` (tagline, one-liners, cocktail party, written version, style rules, brand architecture). Source strategy docs archived in tnb-strategy/source-docs/. See `tnb-strategy/POSITIONING-LANGUAGE.md`.
>
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
**Last updated:** April 14, 2026
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
**Status:** Active, fully functional — major UX overhaul April 14
**Last updated:** April 14, 2026
**Location:** content-calendar/
**Live URL:** https://content-calendar-nine.vercel.app/
**Key context:**
- Manages content across YouTube Videos, YouTube Shorts, LinkedIn, Beehiiv newsletters
- 11-stage pipeline from Ghost → Published with auto-archiving
- Vercel serverless proxies for Beehiiv and YouTube APIs
- **Rich text editing** on all platform body fields (B/I/link toolbar, contentEditable). Copy buttons strip HTML for clean paste.
- **Enter-to-save+close** keyboard shortcut with text field guard. ⌘+Enter secondary shortcut. Button Enter prevention on dropdowns.
- **Ghost + Hold views** — sidebar views for parking cards. Shared StatusListView component with search, platform filter, two-step hover-delete.
- **Mobile responsive CardModal** — full-screen on mobile, proper padding/scroll.
- **Dateless card warning** — yellow banner for non-ghost/non-hold cards missing a date.
- NoteThread chat system, Beehiiv + YouTube auto-match, Agenda calendar view.

**Shared resources:** Firebase project `b-things`. AppSwitcher component.

---

## Brain Inbox (B Nico)
**Status:** Active, functional — B Suite notification router + email sender
**Last updated:** April 14, 2026
**Location:** brain-inbox/
**Live URL:** https://brain-inbox-six.vercel.app
**GitHub:** https://github.com/brhecht/brain-inbox
**Key context:**
- Nico's triage inbox — captures Slack @mentions and DMs, converts to tasks
- **Notification router for all B Suite two-way messaging** — `handoff-notify.js` routes per-recipient (Nico → Brain Inbox Slack channel, Brian → Slack DM)
- **Direct email send** — `send-email.js` sends email via Gmail SMTP (Nodemailer + App Password). Used by comms skill. Any recipient address works. Env var: `GMAIL_APP_PASSWORD`.
- **Slack → B Things task creation** — `nico-slack.js` with `--notes` flag creates tasks in Brian's B Things (project "from-nico") with NoteThread first message
- Slack Bot API integration via Vercel serverless function
- **Also hosts all Firebase Cloud Functions for `b-things`** — `functions/index.js` contains both the Brain Inbox Slack trigger AND the Content → Things sync trigger. Tech debt: should be extracted to dedicated repo.

**Shared resources:** Firebase project `b-things`. AppSwitcher component.

---

## B Hub (Suite Homepage & App Switcher)
**Status:** Live — homepage portal linking to active B-Suite apps
**Last updated:** April 14, 2026
**Location:** bhub/
**Live URL:** https://b-hub-liard.vercel.app
**GitHub:** https://github.com/brhecht/bhub
**Key context:**
- Static HTML homepage with card grid: B Things (top-left), B Projects (top-right, formerly B Eddy), B Content (bottom-left), B People (bottom-right)
- App switcher nav bar + mobile dropdown: same 4 apps only (B Marketing and HC Funnel removed April 14)
- Auto-deploys from GitHub main branch via Vercel
- Also contains bsync.sh (bootstrap script) and HANDOFF-MASTER.md

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

## HC Website (humbleconviction.com)
**Status:** Live but not actively developed. Will become Brian's personal homepage over time.
**Last updated:** April 15, 2026
**Location:** hc-website/
**Live URL:** humbleconviction.com
**GitHub:** brhecht/hc-website
**Key context:**
- Next.js app. HC homepage with "What's Your Founder Story?" hero, YouTube embed, bio, email capture.
- **Branches:** `main` (live HC site), `nico/website-redesign` (HC redesign prototype, not deployed to prod), `tnb-coming-soon` (DEPRECATED, TNB moved to own repo).
- `tnb-coming-soon` branch should be deleted once `tnb-website` repo is live on Vercel.
- No active development planned. Transitions to Brian's personal page when ready.

---

## TNB Website (thenewbuilder.ai)
**Status:** LIVE but low-traffic. Deployed April 15, 2026.
**Last updated:** April 21, 2026
**Location:** tnb-website/
**Live URL:** thenewbuilder.ai
**GitHub:** nmejiawork/tnb-website (transfer to brhecht pending)
**Vercel project:** brian-hechts-projects/thenewbuilder
**Key context:**
- The New Builder public homepage. Next.js 16.2.1, Tailwind 4, Vercel hosting.
- Homepage sections: Nav with TNB wordmark, hero (Brian photo left + tagline right), "Why I'm building this" story, "Builders Figuring it Out. Together." 3x2 product grid (Podcast, YouTube, Newsletter, War Room, Meetups, Curated Events), latest YouTube episode embed, newsletter subscribe form, About Brian bio.
- All copy sourced from `tnb-strategy/POSITIONING-LANGUAGE.md`.
- Previously lived as `tnb-coming-soon` branch of `hc-website`. Separated into own repo April 15. That branch is now deleted.
- Deployed via Vercel CLI (no GitHub auto-deploy yet — pending repo transfer + Nico added as collaborator).
- **Newsletter platform pivot (Apr 21):** switching from Beehiiv → Substack the week of Apr 27. Beehiiv env vars intentionally NOT added. Subscribe form is inert until Substack swap ships. Nico is catching strays via a Google Form in the interim. Effectively zero traffic to the site right now, so the inert form is acceptable for this window.
- See `tnb-website/HANDOFF.md` for full implementation details.

---

## Builder Bot (TNB Slack Recap)
**Status:** PM brief approved — ready for Nico to build
**Last updated:** April 21, 2026
**Location:** builder-bot/
**Live URL:** Not yet deployed
**GitHub:** brhecht/builder-bot
**Key context:**
- Daily weekday Slack recap bot for The New Builder community workspace
- Posts at 9:30am ET to #daily-recap-bot (channel ID: C0AUS1Q7917) as "Builder Bot"
- Reads: #introduce-yourself (new members), #share-and-discuss, #what-im-building, #general
- Cumulative lookback per channel via Vercel KV — not a fixed 24h window
- Carry-forward intro logic: intros only post alongside conversation content
- Claude makes holistic editorial calls on relevance — no reply-count formula
- Fetches linked URLs for substantive summaries, graceful fallback chain
- Skip logic: fewer than 2 meaningful conversation items + no pending intros = no post
- Fully standalone — no shared Firestore, no brain-inbox dependency
- See `PM-BRIEF-builder-bot.md` in repo for full spec, prompt, and milestones

**Shared resources:** Anthropic API (same key as hc-funnel). Vercel KV (new, standalone).

---

## Pitch Scorer
**Status:** Archived / abandoned — only a README and eslint config remain locally
**Location:** pitch-scorer/
**Key context:** Was a Jules-generated React prototype (Landing → Assessment → Results). Decided to build from scratch instead (became hc-funnel). GitHub repo should be archived when gh CLI auth is resolved.

---

## TNB Strategy (The New Builder)
**Status:** Active. Announcement newsletter drafted April 22, pending publish. Podcast live (2 eps). War Room one-shots underway.
**Last updated:** April 22, 2026
**Location:** tnb-strategy/ (private repo, Brian only)
**GitHub:** brhecht/tnb-strategy (private)
**Key context:**
- Strategic brain for The New Builder. Contains positioning, product architecture, revenue model, operating plan, launch plan, and business context.
- **POSITIONING-LANGUAGE.md** is the canonical source for all TNB copy. Locked April 12, 2026. Reference this from any content/design work.
- STRATEGY-CONTEXT.md is the full strategic brain (positioning refs, target audience, business model, 4 exposure outlets, 4 revenue streams, transition plan).
- Source docs (March 2026 strategy memo + deck) archived in source-docs/ with usage protocol README.
- TNB Insider Intro Deck (April 13) in Google Drive: the current 12-slide strategy deck with the 4+4 model grid.

**Not shared with Nico.** Brian-only context. Nico receives relevant decisions via email/DM, not repo access.

---

## HC Strategy (Archived)
**Status:** Archived. Superseded by tnb-strategy.
**Location:** hc-strategy/
**Key context:** Legacy strategic brain for Humble Conviction. Expert research docs are still valuable reference material. Operational details are outdated.

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

## UX Standards

`bhub/UX-STANDARDS.md` is the canonical cross-app UX reference. Any PM brief that specs a modal, toast, inline editor, drag-and-drop, keyboard shortcut, auth flow, or messaging component must cite it. If a new pattern emerges that doesn't fit the existing standards, update this doc first (via PR-style commit to bhub), then build against the updated standard.

The HTML viewer (`ux-standards-view.html`) is useful for visual review but is generated from the MD — always edit the MD and regenerate the HTML if layout changes are needed.

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

## Status Recap Rules (for Claude)

When Brian says "handoff here" or asks "where do things stand," recaps must stay in the **tech/Cowork lane**:

- **Include:** code state, deploy status, env vars pending, infra issues, git/repo oddities, skill drift, bhealth flags, anything actionable inside Claude Cowork or the tech stack.
- **Exclude:** business to-dos (War Room scheduling, podcast episode cadence, content calendar pacing, strategic deadlines). Those belong in **B Things**, not in Claude status summaries. Brian tracks business work himself — the recap is a tech bridge, not a business dashboard.
- **Gray area:** if a business event has a tech dependency (e.g., "Substack migration next week" implies a code swap on tnb-website), mention the tech dependency, not the business event.

When in doubt, ask: "is this something Claude/Nico needs to DO in code, or is this something Brian needs to DO as a founder?" Only the former belongs in a recap.

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

## All B-Suite Live URLs
| App | Live URL | GitHub |
|-----|----------|--------|
| B Hub | https://b-hub-liard.vercel.app | brhecht/bhub |
| B Projects (fka B Eddy) | https://eddy-tracker.vercel.app | brhecht/eddy |
| B Things | https://things-app-gamma.vercel.app | brhecht/things-app |
| B Content | https://content-calendar-nine.vercel.app | brhecht/content-calendar |
| B People | https://b-people.vercel.app | brhecht/b-people |
| B Nico | https://brain-inbox-six.vercel.app | brhecht/brain-inbox |
| BPIs | https://hc-kpi-dashboard.pages.dev | — |
| B Marketing | https://b-marketing.vercel.app | brhecht/b-marketing |
| B Resources | https://b-resources.vercel.app | brhecht/b-resources |
| HC Funnel | https://quiz.humbleconviction.com | brhecht/hc-funnel |
| HC Website | humbleconviction.com | brhecht/hc-website |
| TNB Website | thenewbuilder.ai | nmejiawork/tnb-website (transfer to brhecht pending) |
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

Brian uses four machines. All on `~/Developer/B-Suite/` as of April 18, 2026. Desktop/B-Suite is deprecated everywhere (iCloud sync risk).

**Device roles (Brian's actual workflow, NYC-based):**

- **Mac Mini** — primary dev at home. Big screen. Where real work happens. B-Suite path: `~/Developer/B-Suite/`
- **iMac** — primary dev at office. Big screen. Where real work happens. B-Suite path: `~/Developer/B-Suite`
- **MacBook Pro** — travel companion. Always with Brian; sits beside the primary in both locations. Full dev toolchain. B-Suite path: `~/Developer/B-Suite/`
- **MacBook Air** — light travel only (airplane, coffee shop, reading). Infrequent use. Minimal toolchain by design — Pro is the real travel dev machine. B-Suite path: `~/Developer/B-Suite/`

**The master was corrected on April 18, 2026** — prior versions listed Pro as "primary dev machine," which was wrong. Mini + iMac are the primaries; Pro is the always-carry bridge between them.

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
