# bhub — Handoff

*Last updated: April 18, 2026 ~1:45 PM ET*

**Project:** bhub
**Repository:** github.com/brhecht/bhub
**Live Site:** https://b-hub-liard.vercel.app
**Deployment:** Auto-deploys from GitHub main branch via Vercel (no build step)

---

## Project Overview

bhub has two distinct roles, both of which must be preserved:

1. **B-Suite homepage portal.** Static HTML app switcher at https://b-hub-liard.vercel.app linking to the 4 active B-Suite apps (B Things, B Projects, B Content, B People). No build step; pure HTML/CSS.

2. **B-Suite fleet control repo.** Source of truth for cross-fleet infrastructure:
   - `bsync.sh` — cross-device pull automation (LaunchAgent on each Mac + session bootstrap in Cowork)
   - `install-bsync.sh` — one-time installer for the bsync LaunchAgent
   - `bhealth.sh` — fleet audit tool (runs on each Mac, writes JSON report to `.health/`, commits to GitHub)
   - `HANDOFF-MASTER.md` — cross-app index (auto-generated, never hand-edited)
   - `skills/` — canonical `.skill` installer files + `skills-manifest.json` (hash manifest for drift detection)
   - `.health/` — per-device bhealth reports, committed so any Cowork session can read fleet state

Any B-Suite Claude session starts by pulling bhub (via `bsync` inside `handoff here`) — so bhub is the single entry point into the whole B-Suite ecosystem.

---

## Tech Stack

- **Homepage:** HTML + CSS, no JS framework, no build step
- **Hosting:** Vercel (auto-deploys from main)
- **Fleet scripts:** Bash 3.2+ (macOS default) + Python 3 (for JSON manipulation)
- **LaunchAgent:** macOS launchd, hourly interval, `RunAtLoad=true`

---

## Folder Structure

```
bhub/
├── index.html                    # Homepage
├── styles.css                    # Homepage styles
├── vercel.json                   # Vercel config (static)
├── bsync.sh                      # Fleet sync — v2.2 (parallel clones)
├── install-bsync.sh              # One-time LaunchAgent installer
├── bhealth.sh                    # Fleet audit — v1.0
├── HANDOFF-MASTER.md             # Auto-generated cross-app index + routing rules
├── HANDOFF.md                    # This file
├── .gitignore                    # Includes .DS_Store + .bhealth-device
├── .health/                      # Per-device bhealth reports
│   ├── mac-mini-{date}.json
│   ├── macbook-pro-{date}.json
│   ├── macbook-air-{date}.json
│   └── imac-{date}.json          # (pending first audit)
├── skills/
│   ├── skills-manifest.json      # Hash manifest — source of truth for skill versions
│   ├── handoff.skill             # v3.3.0
│   ├── dev-deploy.skill          # v1.5.0
│   ├── comms.skill               # v1.2.0
│   ├── expert.skill              # v1.0.0
│   ├── hc-strategy.skill         # v1.0.0 (archived)
│   ├── tnb-strategy.skill        # v1.0.0
│   ├── pm.skill                  # v1.0.0
│   ├── create-content.skill      # v1.0.0
│   └── priority-startup-intel.skill  # v1.0.0
└── apps-script/                  # Gmail auto-send integration source
```

---

## Current Status

**Homepage:** Stable. No changes planned.

**Fleet control:**
- `bsync` v2.2 shipped today — parallelized repo clones, cut handoff-here time ~40%.
- `bhealth` v1.0 shipped today — three-tier audit with safe auto-heal, launch-and-prompt for skill installs, flag-only for uncommitted work / expired tokens / missing toolchain.
- All 3 accessible Macs (Mini, Pro, Air) audited April 18 → zero flags. iMac pending next office visit.
- Weekly scheduled task (`weekly-fleet-audit-check`) runs Mondays 8:04 ET, posts staleness summary to B Things.

---

## Recent Changes

### 2026-04-18 — Fleet audit infrastructure + Mini/Pro/Air cleanup

Large session. Built the full fleet audit capability and cleaned 5+ weeks of accumulated drift on 3 of 4 Macs.

**What shipped in bhub:**
- `bhealth.sh` — fleet audit script (three-tier auto-heal / launch-and-prompt / flag)
- `bsync.sh` v2.2 — parallelized repo clones (14 repos in parallel, cut Cowork handoff-here time from ~23s to ~14s)
- `.gitignore` now excludes `.DS_Store` and `.bhealth-device` fleet-wide
- `HANDOFF-MASTER.md` — added two new sections:
  - "Notification Routing Rules" (Brain Inbox = Nico's domain, Brian reminders → B Things)
  - "bhealth — Fleet Audit Playbook" (workflow for any Claude session to triage audit results)
  - Updated "Devices" section to reflect actual roles (Mini/iMac are primaries, Pro is travel companion, Air is light travel)
- `skills/skills-manifest.json` — cleaned duplicate "MacMini" entry (whitespace bug artifact), added bhealth version tracking per device

**What happened on the fleet:**
- **Mac Mini:** all 14 repos had ghost drift (stale working trees from pre-migration). Stashed + reset to origin. Cloned 3 missing repos (hc-strategy, tnb-strategy, tnb-website). All 9 skills verified installed via Claude desktop UI. Fleet-ready: zero flags on re-audit.
- **MacBook Pro:** 10 repos had ghost drift (Pro hadn't been a true dev machine since March — Brian works via Cowork, not local editors). Stashed + reset. Cloned 2 missing (hc-website, tnb-website). Fleet-ready: zero flags on re-audit.
- **MacBook Air:** 2 tiny junk files (.DS_Store + orphan api/fetch-content.js), cleaned. Cloned 4 missing repos. Toolchain install skipped (Air is light-travel only, not a backup dev machine — Pro fills that role). Fleet-ready (4 toolchain flags remain, intentionally).
- **iMac:** deferred. Will audit next time Brian is at the office. Playbook is documented in master handoff so any Claude can guide it.

**Infrastructure added:**
- `weekly-fleet-audit-check` scheduled task (cron `0 8 * * 1`, Monday 8am ET). Checks `.health/` timestamps and creates an action-oriented B Things task if any Mac's audit is stale (>7 days). Falls back to Gmail draft if B Things API unreachable.

**Corrected a mental-model error:** The old master handoff called MacBook Pro the "primary dev machine." Brian's actual workflow (confirmed mid-session): Mini is primary at home, iMac is primary at office (both big-screen), Pro is the always-carry travel companion, Air is infrequent light travel. This is now correctly documented.

---

### 2026-04-14 — Rename B Eddy → B Projects, trim app switcher

**What shipped:**
- Renamed B Eddy to B Projects across homepage and nav
- Updated app card icon from E → P (icon style updated, purple gradient remains)
- Swapped card positions: B Things now top-left, B Projects now top-right
- Removed B Marketing and HC Funnel from app switcher bar and mobile dropdown
- App switcher now shows only 4 apps: B Things, B Projects, B Content, B People

---

## Known Bugs / Issues

- **Cowork + mounted Mac filesystem = `.git/index.lock` trap.** If Cowork runs git commands directly against `/sessions/.../mnt/Developer/B-Suite/{repo}/`, the Linux sandbox creates lock files it can't clean. This blocks subsequent git ops on the Mac until Brian runs `find ~/Developer/B-Suite -name "index.lock" -path "*/.git/*" -delete`. Known workaround, documented in the bhealth playbook. Avoid running git on the mount from Cowork; use `/tmp/bsync-*/` clones instead.
- **bsync `--pull-only` mode silently discards per-repo failures.** Output goes to `/dev/null` (LaunchAgent mode), so if a repo fails to pull, nobody notices until the next bhealth. Acceptable for now — bhealth catches it within a week.

---

## Planned Features / Backlog

- **iMac audit** — pending next office visit. Same playbook as Mini/Pro/Air.
- **GitHub PAT renewal** — `.git-token` (classic PAT, `repo` scope) expires ~June 2026. Generate new one at github.com/settings/tokens (classic, repo scope), overwrite `.git-token` in B-Suite root on any one Mac; bsync will propagate via iCloud-free file (each Mac has its own copy — need to update each).
- **Cowork build status: things-app** — PostCSS/Tailwind filesystem error in Cowork VM (builds fine on Mac). Not retested since March. Low priority.
- **Parallelize `check_handoffs` in bsync.sh** — currently still sequential. Diminishing returns but would save another ~5 seconds on handoff-here. Only tackle if it becomes the new bottleneck.

---

## Design Decisions & Constraints

- **bhub is the fleet control repo, not just a homepage.** This grew organically. Splitting out the fleet infrastructure into its own repo would be cleaner but isn't worth the migration cost right now. Keep both scopes in one repo.
- **bhealth's skill-install check is disabled on local Mac.** Claude desktop on macOS stores skills in a location that filesystem-find can't reliably discover. Skill install status is verified two other ways: (1) bsync in Cowork reads `/sessions/*/mnt/.claude/skills/` which is reliable there, (2) Brian can see installed skills in Claude desktop → Customize → Skills panel. bhealth only verifies the `.skill` installer files exist in `bhub/skills/` (source of truth).
- **bhealth's three tiers exist because blindly auto-healing dirty repos could lose real work.** Tier 1 (auto-heal) only acts on safe operations: pulling clean repos, reinstalling infrastructure, fixing docs. Tier 2 (launch-and-prompt) requires a click. Tier 3 (flag only) leaves judgment to the user. This is by design.
- **Device name is a free-form string, not a hostname.** On first run, bhealth asks which of Brian's 4 Macs this is. Stored to `.bhealth-device` (gitignored, per-Mac). Why: `hostname -s` returns things like "MacBookPro" which is ambiguous across machines (all Macs can end up with similar hostnames). Human-readable labels ("Mac Mini", "MacBook Pro") are clearer and match how Brian talks about them.

---

## Environment & Config

- **Vercel project:** b-hub-liard (brian-hechts-projects namespace)
- **Deploy:** `git push origin main` → Vercel auto-deploys
- **GitHub PAT:** stored at `~/Developer/B-Suite/.git-token` on each Mac (classic PAT, `repo` scope, expires ~June 2026)
- **LaunchAgent:** `~/Library/LaunchAgents/com.bsuite.bsync.plist` (generated fresh on each Mac by `install-bsync.sh`)
- **Local B-Suite path (all 4 Macs):** `~/Developer/B-Suite/` — Desktop/B-Suite is deprecated everywhere

---

## Open Questions / Decisions Pending

- **When to parallelize check_handoffs + check_skills in bsync** — currently only pull_repos is parallel. If handoff-here feels slow again, revisit.
- **Does Air ever need the dev toolchain?** Decided today: no, because Pro is always with Brian when he travels. If that usage pattern changes, revisit.

---

## Session Log

### 2026-04-18 — Fleet audit infrastructure + full fleet cleanup
- **What shipped:** bhealth.sh v1.0, bsync.sh v2.2 (parallel), routing rules + bhealth playbook in master, weekly Monday scheduled task for B Things reminder. Mini/Pro/Air all audited clean.
- **Known issues:** Cowork+Mac mount lock-file trap (documented). iMac audit pending.
- **Next:** iMac audit on next office visit. Re-review Monday morning when the scheduled task fires.

### 2026-04-14 — B Eddy → B Projects rename, app switcher trim
- **What shipped:** Card renames, position swap, app switcher reduced to 4 apps.
- **Known issues:** None.
- **Next:** None planned.
