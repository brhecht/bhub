# HANDOFF — B Suite Infrastructure
*Last updated: March 3, 2026*

This is a living infrastructure reference for the entire B Suite ecosystem. It covers Firebase, Vercel, GitHub, Google Workspace, and per-app configuration. Confidence levels are marked throughout.

---

## Confidence Key

- **CONFIRMED** — Verified from source files, config, or direct observation this session
- **INFERRED** — Reasonable conclusion from available evidence, pending explicit confirmation
- **UNKNOWN** — Information gap that needs to be filled

---

## 1. Firebase

### Project: `b-things` (shared) — CONFIRMED
- **Console:** https://console.firebase.google.com/project/b-things
- **API Key:** `AIzaSyDUdUq_JxA-MeU8tZIex0PVFExtWIz50kE`
- **Auth Domain:** `b-things.firebaseapp.com`
- **Storage Bucket:** `b-things.firebasestorage.app`
- **Messaging Sender ID:** `995860081028`
- **App ID:** `1:995860081028:web:25ebdd0a1b56b402d715d1`
- **Plan:** INFERRED — Blaze (pay as you go), based on Firebase Console screenshot showing "Blaze"

**Apps sharing this project:**
| App | Firestore Collections | Storage | Auth |
|---|---|---|---|
| Things App | `users/{uid}/tasks`, `users/{uid}/projects`, `users/{uid}/viewers` | — | Google sign-in |
| Content Calendar | `contentCards`, `contentPlatforms` | `content-calendar/` | Google sign-in |
| Brain Inbox | `users/{uid}/nicoTasks`, `users/{uid}/nicoProjects`, `users/{uid}/inboxMessages` | — | Google sign-in |

**Firestore Security Rules** — CONFIRMED (as of March 3, 2026)
- **Rules URL:** https://console.firebase.google.com/project/b-things/firestore/rules
- `appConfig/{docId}` — any authenticated user can read/write
- `users/{userId}/tasks/{taskId}` — owner read/write, approved viewers can read
- `users/{userId}/projects/{projectId}` — same as tasks
- `users/{userId}/nicoTasks/{taskId}` — owner + registered co-owners read/write
- `users/{userId}/nicoProjects/{projectId}` — same as nicoTasks
- `users/{userId}/inboxMessages/{messageId}` — owner + registered co-owners read/write
- `users/{userId}/viewers/{viewerId}` — owner can manage, viewer can register themselves
- `contentCards/{cardId}` — any authenticated user can read/write (**ADDED March 3, 2026**)
- `contentPlatforms/{platformId}` — any authenticated user can read/write (**ADDED March 3, 2026**)
- `/{document=**}` — catch-all: `allow read, write: if false` (blocks everything else)

**Firebase Storage Rules** — CONFIRMED
- **Rules URL:** https://console.firebase.google.com/project/b-things/storage/rules
- `content-calendar/{allPaths=**}` — read: public, write: any authenticated user

### Project: `eddy-tracker-82486` (standalone) — CONFIRMED
- **Console:** https://console.firebase.google.com/project/eddy-tracker-82486
- **API Key:** `AIzaSyBuEi_h7n1k6Uqdv5vn2BaLeAbq_Dpxx78`
- **Auth Domain:** `eddy-tracker-82486.firebaseapp.com`
- **Messaging Sender ID:** `286838641056`
- Separate Firebase project, not shared with the others

### Firebase Auth — Allowed Users

| App | Allowed Emails | Enforcement |
|---|---|---|
| Things App | UNKNOWN — need to check store.js | App-level allowlist |
| Content Calendar | `brhnyc1970@gmail.com`, `nico@humbleconviction.com`, `nmejiawork@gmail.com` — CONFIRMED | App-level allowlist in `store.js` |
| Brain Inbox | INFERRED — Nico-specific, likely `nico@humbleconviction.com` or `nmejiawork@gmail.com` | App-level allowlist |
| Eddy | INFERRED — restricted to 2 emails (Brian + one other) | App-level allowlist |
| B-People | UNKNOWN | Unknown |

---

## 2. Vercel

### Organization — CONFIRMED
- **Org/Team ID:** `team_eCILkckzDl4cCruU9XrjlEht`
- **Account name:** INFERRED — `brian-hechts-projects` (from OIDC token in .env.local)
- **Plan:** INFERRED — Hobby (from OIDC token claim `"plan":"hobby"`)

### Deployed Projects — CONFIRMED

| App | Vercel Project Name | Project ID | Live URL | Auto-deploy |
|---|---|---|---|---|
| Things App | `things-app` | `prj_O3xX3xAvKLnQAfuF75dhyAEIG43b` | https://things-app-gamma.vercel.app | Yes, from `main` |
| Content Calendar | `content-calendar` | `prj_mWBudXS2UzMQGtsm5F0lHsCGQnQC` | https://content-calendar-nine.vercel.app | Yes, from `main` |
| Eddy | `eddy-tracker` | `prj_NyACmFRUZcPNdPGHJ2Ziit6Dd6xh` | https://eddy-tracker.vercel.app | Yes, from `main` |
| BHub | `b-hub` | `prj_Lq8ApADX33KuBnBaSxakqh2vkJvf` | UNKNOWN — need to confirm live URL | Yes, from `main` |
| B-People | `b-people` | `prj_18yaTFVdq0TuNh82oIizh9d5mYWA` | UNKNOWN — need to confirm live URL | INFERRED — yes |
| Brain Inbox | UNKNOWN — no .vercel dir found | — | https://brain-inbox-six.vercel.app | INFERRED — yes |

### Vercel Serverless Functions — CONFIRMED
- **Content Calendar:** `/api/beehiiv.js` (Beehiiv API proxy), `/api/youtube.js` (YouTube Data API proxy)
- **Things App:** `/api/slack.js` (Slack webhook), `/api/add-task.js` (task creation API)
- **Brain Inbox:** `/api/nico-slack.js` (Slack bot webhook for Nico)

---

## 3. GitHub

### Account — CONFIRMED
- **Username:** `brhecht`
- **All repos:** https://github.com/brhecht

### Repositories — CONFIRMED

| App | Repo URL | Branch |
|---|---|---|
| Things App | https://github.com/brhecht/things-app.git | `main` |
| Content Calendar | https://github.com/brhecht/content-calendar.git | `main` |
| Eddy | https://github.com/brhecht/eddy-tracker.git | `main` |
| BHub | https://github.com/brhecht/bhub.git | `main` |
| Brain Inbox | https://github.com/brhecht/brain-inbox.git | `main` |
| B-People | No git remote found — CONFIRMED (no .git repo) | — |

---

## 4. Third-Party API Keys

### Content Calendar — CONFIRMED (stored in `.env`, server-side only)
- **Beehiiv API Key:** Present (env var `BEEHIIV_API_KEY`)
- **Beehiiv Publication ID:** `a2c6fbd9-69ae-4662-b36b-72a5e260e009`
- **YouTube Data API v3 Key:** Present (env var `YOUTUBE_API_KEY`)

### Things App — CONFIRMED
- **Slack Bot Token:** Present (referenced in `/api/slack.js`)

### Brain Inbox — CONFIRMED
- **Slack Bot ("Nico Brain Inbox"):** Webhook at `/api/nico-slack.js`

---

## 5. Google Workspace

- **Domain:** `humbleconviction.com` — INFERRED as Google Workspace (Nico signs in with `nico@humbleconviction.com` via Google OAuth, which requires Workspace or Cloud Identity)
- **Known accounts on this domain:** `nico@humbleconviction.com` — CONFIRMED
- **Other accounts on this domain:** UNKNOWN
- **Workspace admin:** UNKNOWN
- **Google Drive integration:** Available via Cowork MCP connector for `brhnyc1970@gmail.com` — CONFIRMED

---

## 6. Tech Stack Summary (All Apps)

| Layer | Standard | Notes |
|---|---|---|
| Frontend | React 18/19 + Vite + Tailwind CSS | All apps except BHub (static HTML) |
| State | Zustand | All React apps |
| Backend/DB | Firebase Firestore | Two projects: `b-things` (shared) and `eddy-tracker-82486` |
| Auth | Firebase Google sign-in | App-level email allowlists |
| Storage | Firebase Storage | Used by Content Calendar and Eddy |
| Hosting | Vercel | All apps, auto-deploy from GitHub `main` |
| Serverless | Vercel Functions | Slack bots, API proxies |
| Version Control | GitHub (`brhecht`) | All apps except B-People |

---

## 7. Ongoing Infrastructure Issues & Recent Fixes

### FIXED — March 3, 2026
- **Content Calendar Firestore rules:** `contentCards` and `contentPlatforms` collections had NO security rules, causing permission-denied errors for both reads and writes. Added `allow read, write: if request.auth != null` for both collections.
- **Content Calendar allowed users:** Added `nmejiawork@gmail.com` (Nico's Gmail) to the app-level `ALLOWED_EMAILS` list in `store.js`.
- **node_modules symlink:** The `content-calendar` project uses a `node_modules.nosync` pattern (iCloud sync avoidance). The symlink from `node_modules → node_modules.nosync` was broken; fixed during this session.

### OPEN — Nico's Edit Access
- **Status:** Nico reported he could view but not edit cards in Content Calendar. The Firestore rules fix (above) is the most likely resolution. Waiting for Nico to confirm after signing out and back in.
- **If still broken:** Next step is to have Nico check browser console for errors while attempting edits.

### OPEN — B-People Has No Git Repo
- **Status:** `b-people` has a Vercel project but no `.git` directory. UNKNOWN how it's being deployed or versioned.

---

## 8. Explicit Unknowns (To Be Filled)

1. **Things App allowed emails** — Who is in the allowlist? Need to check `things-app/src/store.js` or equivalent.
2. **Brain Inbox allowed emails** — Same question.
3. **Eddy allowed emails** — Same question.
4. **B-People deployment method** — No git repo. How does it deploy to Vercel?
5. **BHub live URL** — What's the production URL?
6. **B-People live URL** — What's the production URL?
7. **Google Workspace details** — Is Brian also on the `humbleconviction.com` Workspace? Who is the admin?
8. **Custom domains** — Are any apps mapped to custom domains (e.g., `app.humbleconviction.com`)?
9. **Vercel environment variables** — Are all env vars synced between local `.env` and Vercel project settings? Content Calendar has a `.env.local` created by Vercel CLI.
10. **Firebase billing alerts** — Are there budget alerts set up on the Blaze plan?
11. **Backup strategy** — Is Firestore data being backed up anywhere?
12. **Slack app configurations** — Full details of Slack bot setup (workspace, permissions, channels) for both Things and Brain Inbox bots.

---

## 9. Deploy Workflow (Standard)

For all Vercel-deployed apps:

```bash
cd ~/Desktop/{project-folder}
git add -A && git commit -m "description" && git push origin main
```

Vercel auto-deploys from `main`. Verify at the production URL after ~1-2 minutes.

**Note:** A post-push deploy verification skill has been discussed but not yet created.
