---
name: dev-deploy
description: |
  **Dev-Deploy Workflow**: Defines how Claude should work on web app codebases — writing code directly to project files, validating before handoff, minimizing terminal friction, and bundling deploy commands into single copy-paste lines.
  - MANDATORY TRIGGERS: Any session where Claude is writing or editing code in a web application project (React, Next.js, Vite, etc.) and the user will build/deploy. Also triggers when doing git operations, running dev servers, or deploying to Vercel/Netlify/similar. Use this skill whenever the user has a mounted project folder and asks Claude to make code changes, fix bugs, add features, or deploy updates — even if they don't explicitly mention "deploy" or "workflow".
---

# Dev-Deploy Workflow

This skill defines the protocol for how Claude works on web app codebases. The goal: Claude does the heavy lifting on code, the user does minimal terminal interaction, and deployments are smooth single-step operations.

## Core Philosophy

The user is a founder, not a full-time developer. They can run terminal commands but don't want to context-switch between reading code diffs and copy-pasting multiple commands. Claude should absorb as much friction as possible — writing directly to files, validating before handoff, and bundling operations so the user's terminal work is one line at a time.

## Writing Code

### Write directly to project files
Never show code in chat and ask the user to paste it. Use the Edit or Write tools to modify files in the mounted project folder directly. The user should see changes reflected immediately (via HMR if a dev server is running) without touching their editor.

### Make surgical edits
Prefer `Edit` (find-and-replace) over `Write` (full file rewrite) whenever possible. This reduces the chance of accidentally clobbering unrelated code and makes it clear what changed.

### Validate before handoff
Before telling the user to build or test, verify the code is structurally sound:
- Check brace/paren balance with a quick Node.js or Python script
- Confirm imports reference files that exist
- For JSX: verify no dangling tags or orphaned fragments
- For JSON: parse it to confirm validity

This catches the easy mistakes that would otherwise waste a build cycle.

## Terminal Commands

### One operation at a time
Never ask the user to run more than one separate terminal command in sequence. If multiple commands need to happen, chain them with `&&` into a single copy-paste line.

**Good:**
```bash
npm run build && git add -A && git commit -m "Add search feature" && git push
```

**Bad:**
```
First run: npm run build
Then run: git add -A
Then run: git commit -m "Add search feature"
Then run: git push
```

### Dev server awareness
When a Vite/Next/Webpack dev server is running:
- Note that HMR will pick up file changes automatically — the user can test in-browser immediately
- Before build+push chains, remind the user to `Ctrl+C` the dev server first (since it holds the terminal)
- If the dev server is on a specific port (e.g., localhost:5174), reference that port consistently

### Commit messages
Keep them concise and descriptive. Focus on what changed and why, not implementation details.

**Good:** `"Wire sidebar filters to archive view"`
**Bad:** `"Updated ArchiveView.jsx to destructure filterPlatforms and filterStatuses from useStore and added conditional filtering logic"`

## Git Auto-Config (Session Start)

At the start of every Cowork session that involves code changes or deploys, Claude must configure git credentials before any git operations. This eliminates the terminal handoff for `git push` — Claude can push directly.

**The sequence:**
1. Check if `.git-token` exists in the B-Suite root folder
2. If it exists, read the token and configure git:
   ```bash
   git config --global credential.helper store
   echo "https://brhecht:TOKEN@github.com" > ~/.git-credentials
   git config --global user.name "brhecht"
   git config --global user.email "brhnyc1970@gmail.com"
   ```
3. Verify with a dry-run push on any repo: `git push --dry-run`
4. If the token is expired or invalid, ask the user to generate a new classic PAT at github.com/settings/tokens with `repo` scope, and save it to `.git-token`

**If `.git-token` is missing:** Ask the user to paste their GitHub PAT (classic token, `repo` scope). Save it to `.git-token` in the B-Suite root for future sessions.

**This means the deploy flow is now fully autonomous in Cowork mode.** No terminal handoff needed for `git push`. The user's only checkpoint is confirming "ship it" before Claude pushes.

## Git Operations: /tmp Clone First (MANDATORY)

**Never perform git write operations (commit, push, pull, rebase) on the mounted drive.** The mounted B-Suite folder has persistent EPERM issues — lock files, pack file errors, HEAD.lock failures. These are a fundamental limitation of how Cowork mounts the filesystem, not something that can be fixed per-session.

**The rule is simple:**
- **Reads:** Use the mounted drive. Reading files, checking git status, browsing code — all fine on the mounted path.
- **Writes (code edits):** Use the mounted drive via Edit/Write tools. File edits work. HMR picks them up if a dev server is running.
- **Git operations (commit, push, pull):** ALWAYS use a /tmp clone. No exceptions. No "try mounted first, fall back to /tmp." Go straight to /tmp.

**The /tmp clone pattern:**

```bash
# Clone fresh (or reuse if already cloned this session)
REPO="app-name"
TMP_REPO="/tmp/bsync-work/$REPO"
if [ ! -d "$TMP_REPO" ]; then
  git clone https://github.com/brhecht/$REPO.git "$TMP_REPO"
fi

# Sync any file changes from mounted drive to /tmp clone
cd "$TMP_REPO" && git pull
rsync -av --exclude='.git' --exclude='node_modules' \
  /path/to/mounted/$REPO/ "$TMP_REPO/"

# Commit and push from /tmp
cd "$TMP_REPO" && git add -A && git commit -m "message" && git push
```

**Shortcut:** If bsync already cloned the repo to `/tmp/bsync-work/<repo>/` at session start, reuse that clone. Don't re-clone.

**Why this is mandatory, not a preference:** The mounted drive fails on git writes roughly 70% of the time. Every failure wastes 30-60 seconds of retrying, produces confusing error output, and sometimes leaves lock files that affect the next session. Going straight to /tmp is faster even when the mounted drive would have worked.

**Post-push sync:** After pushing from /tmp, the mounted drive's working tree is now behind. This is fine — the next `git pull` (from /tmp or from the user's Mac) will catch up. Don't try to pull on the mounted drive to sync it.

## Known Sandbox Limitations (Don't Fight These)

These are Cowork sandbox constraints that cannot be fixed. Don't waste time retrying — use the documented workarounds.

| Blocked | Workaround |
|---------|------------|
| **Firestore direct access** (gRPC blocked by proxy) | Can't query Firestore from sandbox. Use Vercel API endpoints if the domain is allowlisted, or read from local data files/exports. |
| **GitHub API** (api.github.com blocked by proxy) | Can't create repos, manage issues, or use gh CLI. Give user a one-liner to run on their Mac. |
| **Custom Vercel domains** (*.vercel.app blocked by proxy) | Can't fetch from live app APIs. Build data export scripts that write to repo files instead. |
| **Firebase CLI deploy** | Use git push + Vercel auto-deploy instead. If Firebase deploy is truly needed, give user a one-liner. |
| **Mounted drive git writes** | Use /tmp clone pattern (see above). |
| **Skill files** (read-only once installed) | Edit source in bhub /tmp clone, rebuild .skill bundle, present to user for install. |

## Deploy Flow

### Autonomous build loop (Cowork mode)
When running in Cowork with a mounted project folder, Claude should run builds directly instead of handing terminal commands to the user. This eliminates the biggest source of wasted time: the user copying errors from terminal, pasting them into chat, and waiting for fixes.

**The loop:**
1. Run `npm run build` (or the project's build command) via Bash
2. If it succeeds → move to deploy
3. If it fails → read the error output, fix the code, rebuild
4. Repeat until the build is clean — no user involvement needed for error-fix cycles

The user's role shifts from "build-error-paste-fix" loop participant to reviewer of the final result. This is the single highest-leverage workflow improvement for non-developer founders who build with Claude.

**When NOT to use this:** If the user explicitly wants to run builds themselves, or if the build involves credentials/env vars that Claude doesn't have access to.

**Handoff for deploy:** Once the build is clean, give the user a single copy-paste deploy command, or run `git add && git commit && git push` directly if the user has authorized it. Always confirm before pushing — the push is the human checkpoint, not the build.

### Always pull before push (MANDATORY)

**Every `git push` must be preceded by `git pull --rebase`.** This is non-negotiable. The B-Suite team has two active contributors (Brian and Nico) who may push to the same repos from different Cowork sessions or devices simultaneously. Without pulling first, a push can silently overwrite the other person's changes — including handoff updates, config changes, and code.

**The pattern:**
```bash
git add -A && git commit -m "descriptive message" && git pull --rebase origin main && git push
```

If the rebase has conflicts, resolve them (prefer the current changes unless the conflict is in a shared file like HANDOFF.md, in which case merge both). Never force-push to resolve a conflict.

**This applies to every push, every repo, every session.** It adds ~2 seconds and prevents hours of debugging overwritten changes.

### Standard deploy sequence
For projects deployed via git push (Vercel, Netlify, etc.):

```bash
npm run build && git add -A && git commit -m "descriptive message" && git pull --rebase origin main && git push
```

After the user confirms the push succeeded (or Claude runs it with permission), the deploy will be live in ~60 seconds.

### Stamp-on-push (handoff continuity)

**On every meaningful push** (feature shipped, bug fixed, approach changed — NOT debug iterations or trivial fixes), append a lightweight context stamp to the app's HANDOFF.md before committing. This is the primary handoff continuity mechanism. It captures what git commits alone can't: known issues, intent, and next steps.

**The stamp goes in `## Session Log` at the bottom of HANDOFF.md:**

```markdown
### [date] — [brief description]
- **What shipped:** [1-2 lines]
- **Known issues:** [anything broken or degraded, or "None"]
- **Next:** [what to do next, or "Continuing"]
```

**Rules:**
- 3-5 lines max. This is a breadcrumb, not a handoff rewrite.
- Include the stamp in the same commit as the code change. Not a separate commit.
- If `## Session Log` doesn't exist in HANDOFF.md, create it at the bottom.
- If there's no HANDOFF.md at all, don't create one just for a stamp.
- Don't stamp on debug iterations, dependency updates, or config tweaks.

**Why this matters:** If the user walks away and the next session runs `bsync.sh`, the stamps give that session both the *what* (from git log) and the *why/what's next* (from stamps). Without stamps, bsync can only reconstruct code changes — not intent.

See the handoff skill for the full stamp-on-push protocol.

### Post-deploy verification (MANDATORY)
This is not optional. After every deploy, Claude must verify the change is live. Do not skip this. Do not "offer" to do it. Just do it.

**The sequence:**
1. Wait 60 seconds after git push completes (Vercel build + deploy lag)
2. Use browser automation tools to navigate to the production URL
3. Take a screenshot
4. Verify the change is visually present and the page loads correctly
5. Report the result to the user with the screenshot

If the production URL shows an error or the change isn't visible:
- Check the Vercel deployment status (navigate to vercel.com dashboard or use `vercel` CLI if available)
- If the deploy is still building, wait and recheck
- If the deploy failed, read the Vercel build logs and fix the issue

The reason this matters: the user's workflow used to end with "I pushed, I think it's live?" and then they'd discover a broken deploy hours later. Closing this loop automatically saves real time and catches deploy-specific issues (env vars, build config differences) that local builds miss.

### Build failures
If the build fails:
1. Read the error output
2. Fix the issue in code (don't ask the user to fix it)
3. Re-validate
4. Rebuild — repeat until clean
5. Give the user a fresh single-line build+push command (or push directly if authorized)

### When VM tools break (NEVER offload to user)

This is the most important recovery principle in this skill. When a VM tool fails — git crashes, network blocks, auth errors, corrupted state — Claude's instinct will be to ask the user to run the command on their Mac instead. **This is always wrong as a first response.** The user chose Cowork so they wouldn't have to be a terminal operator. Every command offloaded to them is a broken promise.

The reason this matters beyond convenience: the user may not be a developer. They can run commands you give them, but they can't debug when those commands fail. So if you hand them `git push` and it errors out, now they're stuck in a debugging loop they never signed up for — and you've traded one problem (your VM failing) for a worse one (the user stuck in terminal hell).

**Recovery hierarchy — follow this order before ever involving the user:**

1. **Wait and retry** — transient errors (bus errors, timeouts) often self-resolve in 10-15 seconds
2. **Sidestep the broken state** — if a git repo is corrupted, clone fresh to `/tmp/`. If a directory has issues, work from a different path. Don't keep retrying the same failing operation in the same broken context
3. **Use a different tool for the same job** — if `git push` fails, try the GitHub API. If `firebase deploy` fails via CLI, try the REST API. If `curl` is blocked by the VM proxy, try a deploy hook URL from the user's browser
4. **Use a workaround** — Vercel deploy hooks, GitHub Actions triggers, API-based file uploads
5. **Absolute last resort** — give the user ONE bundled command with a clear, non-technical explanation of what it does and why they need to run it

**Self-check rule (apply EVERY time, not just during failures):** Before asking the user to do anything — run a command, check a dashboard, click a button, paste a URL — pause and ask: "Do I actually need them for this, or can I do it myself?" If the answer is "I could probably do it myself but it seems easier to ask them," that's not good enough. Do it yourself. The only valid reasons to involve the user are: (1) it requires credentials or permissions Claude doesn't have, (2) it requires physical interaction with their device that Claude cannot access, or (3) Claude has genuinely exhausted all alternatives. This check should be automatic and constant, not just triggered by errors.

**The 3-alternatives rule:** Before composing any terminal command for the user, additionally verify: "Have I tried at least 3 alternative approaches on my own?" If the answer is no, go back and try them. This rule exists because of a real failure pattern: the VM's git crashed, Claude immediately started handing the user git commands, the user spent 30 minutes in terminal debugging — and the fix (clone to /tmp/) took 60 seconds once Claude finally tried it.

**The corruption cascade to avoid:** The VM and the user's Mac often share a mounted folder. If the VM corrupts files in that shared folder (e.g., a crashed git process leaves a broken `.git/index`), those corruptions affect the user's machine too. When a VM tool crashes mid-operation: (1) stop immediately, (2) don't retry in the same directory, (3) work from a clean copy elsewhere. Repeated retries in corrupted state make everything worse.

## Architecture Preference: Vercel Over Firebase Cloud Functions

When adding server-side logic to a B-Suite app, strongly prefer Vercel serverless functions (`api/*.js`) over Firebase Cloud Functions. The reason: Vercel functions auto-deploy on git push — zero CLI tools, zero secrets management, zero user terminal involvement. Firebase Cloud Functions require the Firebase CLI, `npm install` in the functions directory, and Google Cloud secrets that may only exist on one developer's machine. For a non-developer founder, this difference is the gap between "Claude handles everything" and "6 cascading terminal commands on a machine that doesn't have Node installed."

**The cron alternative to real-time triggers:** If you need to react to Firestore changes (e.g., a document write triggers an action), ask whether a Vercel cron polling at a reasonable interval can do the same job. For most B-Suite use cases — content calendar syncs, daily digests, scheduled notifications — a cron running every 15 minutes or once daily is functionally equivalent to a real-time Firestore trigger and dramatically simpler to deploy and maintain.

**Only use Firebase Cloud Functions when:** (a) real-time response is genuinely required (sub-second latency matters), AND (b) the function is owned by the developer who has Firebase secrets configured on their machine. Even then, document the deploy dependency in the handoff so future sessions know what's required.

**Where this came from:** On March 18, 2026, a Firebase Cloud Function in brain-inbox (`syncContentToThings`) required installing nvm, Node.js, npm, and firebase-tools on a fresh iMac, then a Firebase login, then hitting a secrets wall that only Nico's machine could satisfy — all for a feature that worked identically as a daily Vercel cron. Six terminal commands handed to a non-developer user. The function was removed and consolidated into a single Vercel serverless function in things-app, which deployed with zero user involvement.

## Communication Style

### Be direct about what to do
Don't explain what you're about to do in detail before doing it. Just do it, then summarize what you did and what the user needs to do next.

### Terminal output interpretation
When the user shares screenshots or pastes of terminal output:
- Parse it quickly and tell them what it means
- If it's a success, say so briefly and move on
- If it's an error, fix it immediately

### Progress updates
After making code changes, give a brief summary of what changed and the single terminal command the user needs to run. No lengthy explanations of the code unless the user asks.

## Example Flows

### Cowork mode (autonomous build loop)
1. User asks for a feature → Claude writes code directly to project files
2. Claude runs `npm run build` → catches 2 errors → fixes both → rebuilds → clean
3. Claude says: "Build is clean. Here's what I changed: [brief summary]. Ready to push to [app-name]?"
4. User says "ship it" → Claude runs `git add -A && git commit -m 'Add feature X' && git pull --rebase origin main && git push`
5. Claude waits 60s → opens production URL in browser → takes screenshot → "Deploy confirmed, feature X is live. Here's what it looks like: [screenshot]"

### Terminal handoff mode (user runs commands)
1. User asks for a feature → Claude writes code directly to project files
2. Claude validates syntax → tells user: "Changes are in. HMR should pick them up — check localhost:5174"
3. User confirms it looks good → Claude says: "Ready to ship. Run: `npm run build && git add -A && git commit -m 'Add feature X' && git pull --rebase origin main && git push`"
4. User shares terminal output showing success → Claude says: "Deployed."
5. Claude waits 60s → opens production URL in browser → takes screenshot → confirms deploy is live
