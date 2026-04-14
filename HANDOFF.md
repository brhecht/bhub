# bhub — Handoff

**Project:** bhub  
**Purpose:** Static HTML homepage for B-Suite app switcher portal  
**Repository:** github.com/brhecht/bhub  
**Live Site:** https://b-hub-liard.vercel.app  
**Deployment:** Auto-deploys from GitHub main branch via Vercel (no build step)

---

## Project Overview

bhub is a lightweight, static HTML homepage that serves as the central portal for the B-Suite app ecosystem. It features an app switcher interface with links to all B-Suite applications and a clean, responsive design.

**Tech Stack:** HTML + CSS (no JavaScript framework, no build step)

---

## Key Features

### Homepage Layout
- **Hero Section:** "Your tools. All in one place." tagline
- **App Cards:** 4 clickable application cards with icon, name, and description
  - B Things (top-left, green)
  - B Projects (top-right, purple)
  - B Content (bottom-left, yellow)
  - B People (bottom-right, coral)

### App Switcher Navigation
- **Desktop:** Fixed nav bar at top with pill-style links for all 4 apps
- **Mobile:** Responsive dropdown menu version of switcher

---

## File Structure

```
bhub/
├── index.html           # Main homepage
├── styles.css           # Global styles for cards, nav, responsive layout
├── bsync.sh             # Bootstrap script for cross-device B-Suite sync
├── HANDOFF-MASTER.md    # Auto-generated cross-app index
└── HANDOFF.md           # This file
```

---

## Recent Changes

### 2026-04-14 — Rename B Eddy → B Projects, trim app switcher

**What shipped:**
- Renamed B Eddy to B Projects across homepage and nav
- Updated app card icon from E → P (icon style updated, purple gradient remains)
- Swapped card positions: B Things now top-left, B Projects now top-right
- Removed B Marketing and HC Funnel from app switcher bar and mobile dropdown
- App switcher now shows only 4 apps: B Things, B Projects, B Content, B People

**Known issues:** None

**Next:** None planned

---

## How to Update

### Adding/Changing App Cards
1. Edit `index.html` — update card HTML in the main grid section
2. Update `styles.css` — modify card colors, gradients, and layout as needed
3. Commit and push to `main` — Vercel auto-deploys within seconds

### Updating App Switcher
- Desktop: Edit nav pill links in `index.html`
- Mobile: Update dropdown menu in `index.html`
- Both versions share the same app list (no duplication necessary)

### Testing Locally
- No build step required — open `index.html` directly in browser or use a simple HTTP server:
  ```bash
  python -m http.server 8000
  ```

---

## Deployment

- **Hosting:** Vercel
- **Branch:** main (auto-deploys on push)
- **Build:** Static files only (no build step)
- **Rollback:** Revert commit and push to main

---

## Dependencies & Links

**Related handoff files:**
- HANDOFF-MASTER.md — Cross-app index (auto-generated)

**Related repos:**
- B Things (linked from bhub)
- B Projects (linked from bhub)
- B Content (linked from bhub)
- B People (linked from bhub)

---

## Contact & Handoff

For questions about bhub, refer to the most recent commit history in GitHub or the HANDOFF-MASTER.md for cross-team context.
