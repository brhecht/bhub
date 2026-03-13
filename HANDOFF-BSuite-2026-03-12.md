# HANDOFF — B-Suite (Master)
*Last updated: March 12, 2026 ~9:30 PM ET*

## Project Overview
B-Suite is Brian's personal productivity ecosystem for Humble Conviction. It consists of interconnected web apps sharing Firebase backends, plus shared skills and infrastructure. Brian builds and maintains everything; Nico is the primary collaborator/end user across multiple apps.

## Apps in the Suite

### 1. B Things (Task Manager)
- **URL:** https://things-app-gamma.vercel.app
- **Repo:** github.com/brhecht/things-app
- **Local path:** `~/Developer/B-Suite/things-app`
- **Status:** Fully working. Nico upgraded to full read-write collaborator. Two-way messaging, cross-app task creation API (for Eddy), modal UX improvements.
- **Handoff:** `things-app/HANDOFF-BThings-2026-03-12.md`

### 2. Content Calendar
- **URL:** https://content-calendar-nine.vercel.app
- **Repo:** github.com/brhecht/content-calendar
- **Local path:** `~/Developer/B-Suite/content-calendar`
- **Status:** Fully working. Deep-link support (?card=id) added. Auto-expanding notes.
- **Handoff:** `content-calendar/HANDOFF-ContentCalendar-2026-03-12.md`

### 3. Brain Inbox (Nico's Triage Inbox)
- **URL:** https://brain-inbox-six.vercel.app
- **Repo:** github.com/brhecht/brain-inbox
- **Local path:** `~/Developer/B-Suite/brain-inbox`
- **Status:** Fully working. Per-recipient notification routing. --notes flag creates B Things tasks from Slack. AppSwitcher expanded.
- **Handoff:** `brain-inbox/HANDOFF-BNico-2026-03-12.md`

### 4. Eddy Tracker (Course Launch Manager)
- **URL:** https://eddy-tracker.vercel.app
- **Repo:** github.com/brhecht/eddy-tracker
- **Local path:** `~/Developer/B-Suite/eddy`
- **Status:** Fully working. Cross-app B Things task creation via modal + API proxy.
- **Handoff:** `eddy/HANDOFF-Eddy-2026-03-12.md`

### 5. B Resources (Knowledge & Asset Hub)
- **URL:** https://b-resources.vercel.app
- **Repo:** github.com/brhecht/b-resources
- **Local path:** `~/Developer/B-Suite/b-resources`
- **Status:** Library and Vault pages fully built by Nico (3 PRs merged). Drag-drop uploads, search, categories. Firebase config hardcoded.
- **Handoff:** `b-resources/HANDOFF-BResources-2026-03-12.md`

### 6. B Marketing (Marketing Hub)
- **URL:** https://b-marketing.vercel.app
- **Repo:** github.com/brhecht/b-marketing
- **Local path:** `~/Developer/B-Suite/b-marketing`
- **Status:** Landing page with HC Funnel link. HC Funnel now positioned as sub-tool under Marketing.
- **Handoff:** `b-marketing/HANDOFF-BMarketing-2026-03-12.md`

### 7. HC Funnel (Quiz/Lead Gen)
- **URL:** https://hc-funnel.vercel.app
- **Repo:** github.com/brhecht/hc-funnel
- **Local path:** `~/Developer/B-Suite/hc-funnel`
- **Status:** Fully working quiz funnel. Now sub-tool under Marketing (removed from AppSwitcher).
- **Handoff:** `hc-funnel/HANDOFF-HCFunnel-2026-03-12.md`

### 8. B People (Contacts/CRM)
- **Repo:** github.com/brhecht/b-people
- **Local path:** `~/Developer/B-Suite/b-people`
- **Status:** Working contacts app with Dex import. Standalone Firebase project.
- **Handoff:** `b-people/HANDOFF-BPeople-2026-03-12.md`

### 9. B Hub (Portal/Homepage)
- **URL:** https://b-hub-liard.vercel.app
- **Repo:** github.com/brhecht/bhub
- **Local path:** `~/Developer/B-Suite/bhub`
- **Status:** Static HTML portal. Stable, no recent changes. Also hosts the master B-Suite handoff.
- **Handoff:** `bhub/HANDOFF-BHub-2026-03-05.md` (app-specific, older)

### 10. Pitch Scorer
- **Repo:** github.com/brhecht/pitch-scorer
- **Local path:** `~/Developer/B-Suite/pitch-scorer`
- **Status:** Early stage / minimal (4 commits total).
- **Handoff:** `pitch-scorer/HANDOFF-PitchScorer-2026-03-12.md`

## Shared Infrastructure

### Firebase
- **Primary project:** `b-things` (Blaze plan) — used by Things, Content Calendar, Brain Inbox, B Resources, Eddy
- **Secondary project:** `eddy-tracker-82486` — used by B Marketing, HC Funnel
- **B People:** standalone Firebase project
- **Shared Firestore rules:** `firestore.rules` file at B-Suite root level. Things, Brain Inbox, and Content Calendar all point to `../firestore.rules` in their firebase.json

### Auth
- Firebase Auth with Google sign-in across all apps
- Allowed emails: brhnyc1970@gmail.com, nico@humbleconviction.com, nmejiawork@gmail.com
- B People has its own email allowlist

### Messaging System
- NoteThread component (iMessage-style chat) live in Content Calendar and B Things
- @mention autocomplete using users.js (Brian + Nico with handles, emails, Slack IDs)
- Notifications route through Brain Inbox's handoff-notify.js API
- Per-recipient routing: Nico → channel (BRAIN_CHANNEL_ID), Brian → DM

### Cross-App Notification Flow
```
@mention in NoteThread (Content Calendar or B Things)
  → POST to /api/notify (same-origin proxy in each app)
    → POST to brain-inbox/api/handoff-notify.js
      → Route by recipient:
        - Nico: post to BRAIN_CHANNEL_ID
        - Brian/others: DM to their Slack user ID
      → Write to recipient's Firestore inboxMessages collection
      → Cloud Function also sends DM to Nico (redundant, intentional)
```

### Cross-App Task Creation
```
Eddy "Create B Things Task" button
  → POST to eddy/api/create-task (proxy, keeps API key server-side)
    → POST to things-app/api/add-task
      → Creates task in Brian's Firestore with project, bucket, notes

Nico Slack --notes flag
  → brain-inbox/api/nico-slack.js
    → Creates task in Brian's B Things (project: from-nico, bucket: inbox)
    → Adds NoteThread message with @brian
    → DMs Brian with deep link
```

### AppSwitcher
- Shared nav bar component across all apps
- Current apps: Eddy, Things, Content, People, Nico, Marketing
- HC Funnel removed (now sub-tool under Marketing)
- Hub link: https://b-hub-liard.vercel.app

### User Registry
```
Brian: brhnyc1970@gmail.com, Slack U096WPV71KK
Nico:  nico@humbleconviction.com / nmejiawork@gmail.com, Slack U09GRAMET4H
Nico Firebase UID: N7dBZAH0HkhCCtlAPnfFIWmxn6t1
```

## Deploy Hooks (All Apps)
- **B Things:** https://api.vercel.com/v1/integrations/deploy/prj_O3xX3xAvKLnQAfuF75dhyAEIG43b/fnvcwncXfs
- **Brain Inbox:** https://api.vercel.com/v1/integrations/deploy/prj_v84pZBKa5zaaFGiBAw1uWX3Cu0XM/h9DR1M5txm
- **Others:** May auto-deploy from main, or use deploy hooks if blocked

## Recent Changes (March 8–12, 2026)

### Cross-Cutting
- HC Funnel removed from AppSwitcher across all apps (now sub-tool under Marketing)
- B Content and B Marketing added to Brain Inbox's AppSwitcher
- Firestore rules centralized to shared file at B-Suite root (things-app, brain-inbox)

### Per-App Highlights
- **things-app:** Nico upgraded to full collaborator (dataUid pattern), two-way messaging, TaskModal UX (done/star in header, Enter-to-save), cross-app task creation API for Eddy
- **b-resources:** Library + Vault pages built from scratch by Nico (3 merged PRs), drag-drop uploads, Google Auth
- **brain-inbox:** Per-recipient notification routing, --notes flag for B Things task creation from Slack
- **eddy:** Cross-app "Create B Things Task" modal with project selector and error feedback
- **content-calendar:** Deep-link support (?card=id), auto-expanding notes textarea

## Known Issues (Cross-App)
1. **Vercel auto-deploy possibly blocked** — Some apps' git pushes show "Blocked" since March 3. Deploy Hooks are the workaround.
2. **DM-to-bot broken in Slack** — Can't DM the Brain Inbox bot directly. @mentions in channels work.
3. **VM git corruption risk** — Cowork VM's git can crash with SIGBUS on mounted folders. Recovery: clone fresh to /tmp/, never retry in corrupted state.

## Dev Workflow
- **Repos live at:** `~/Developer/B-Suite/` (local, NOT iCloud — moved March 12)
- **Previously at:** `~/Desktop/B-Suite/` (iCloud — deprecated, may still have stale files)
- **Git token:** Generate PAT at github.com/settings/tokens, save to `~/Developer/B-Suite/.git-token` for Cowork auto-push (per dev-deploy skill)
- **Master handoff:** Lives in bhub repo root (git-tracked, syncs across devices)
- **Per-app handoffs:** Live in each app's repo root (git-tracked)

## Design Decisions & Constraints
- **Notifications only on handleSend** — Critical pattern across Content Calendar and B Things. Never fire notifications on card/task save.
- **Deploy via hooks** — Standard deploy pattern until Vercel auto-deploy blocking is resolved
- **dataUid pattern** — Collaborators write to owner's Firestore paths (introduced March 10 in things-app)
- **Per-recipient notification routing** — Extensible via USER_REGISTRY in handoff-notify.js
- **node_modules.nosync** — Symlink pattern to avoid iCloud sync issues (legacy, may not be needed now that repos moved to Developer)

## Open Questions / Decisions Pending
1. Investigate Vercel auto-deploy blocking root cause (all apps affected?)
2. Generate long-lived GitHub PAT and save to .git-token for Cowork autonomous push
3. Should @brian handle be fully supported across all apps? Infrastructure supports it.
4. Clean up old ~/Desktop/B-Suite folder (stale, corrupted git repos)
5. b-resources: email allowlist, Firestore rules hardening, move Firebase config to env vars
