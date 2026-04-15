# HANDOFF — TNB Website (thenewbuilder.ai)
*Last updated: April 15, 2026*

## Project Overview
The New Builder homepage at thenewbuilder.ai. Public-facing website for the TNB brand. Currently being built; homepage design approved by Brian on April 15, ready for Nico to implement.

## Tech Stack
Next.js (App Router), Tailwind CSS, Vercel hosting. Email capture wired to Beehiiv via `/api/subscribe`. Inherits the Next.js setup from the `tnb-coming-soon` branch of `hc-website` (where the placeholder originally lived).

## Repo History
This repo was created April 15, 2026 to separate the TNB website from `hc-website`. Previously, the thenewbuilder.ai placeholder lived on the `tnb-coming-soon` branch of `brhecht/hc-website`. That branch is now deprecated.

## Folder Structure
- `src/app/page.tsx` — main homepage
- `src/app/globals.css` — global styles
- `src/app/api/subscribe/` — email capture endpoint (wire to Beehiiv)
- `public/images/headshot.jpg` — Brian's headshot (hero photo)
- `tnb-homepage-preview.html` — static HTML preview of approved design (reference only, not deployed)

## Current Status
Homepage design approved by Brian. Ready for Nico to implement as production Next.js page. Static HTML preview exists as design reference. Repo needs to be created on GitHub and connected to Vercel.

## Homepage Sections (Approved April 15)
1. **Nav** — "THE NEW BUILDER" wordmark (18px, black, bold) left, YouTube/LinkedIn/Contact links right
2. **Hero** — Brian's photo left (gaze toward copy), bold tagline right: "Navigating the AI era. Together." + one-liner below
3. **Why I'm building this** — stacked layout. Written version copy (condensed from POSITIONING-LANGUAGE.md). No "closer" line; that line became the next section header.
4. **Builders Figuring it Out. Together.** — 3x2 card grid:
   - Top row (content): Podcast, YouTube, Newsletter
   - Bottom row (experiences): The War Room, Meetups, Curated Events
   - War Room, Meetups, Curated Events are non-clickable cards for now
5. **Latest Episode** — YouTube embed (hardcode current episode from HC channel)
6. **Stay in the loop** — email capture form (Email + First name + Subscribe button), wired to Beehiiv
7. **About Brian** — short bio
8. **Footer** — "The New Builder" left, LinkedIn/YouTube/Email links right

## Copy Sources
All positioning copy comes from `tnb-strategy/POSITIONING-LANGUAGE.md` (locked April 12, 2026). Style rules: no em dashes, period before "Together" is load-bearing, "community" never leads, "platform" and "movement" banned.

## Card Copy (Approved)
- **Podcast:** Weekly conversations with founders and builders navigating the AI era.
- **YouTube:** 20K subscribers. Podcast companion and original content.
- **Newsletter:** Weekly hot takes from Brian and thoughtful builders in the field.
- **The War Room:** A premium mastermind for founders who want to go deeper with real-time peer learning.
- **Meetups:** No pitches, no agenda, just AI builders socializing and sharing notes.
- **Curated Events:** Invite-only roundtables and dinners for a smaller group of builders going deeper.

## Design Decisions & Constraints
- Clean white background, black type, gray accents. Matches the TNB coming-soon aesthetic, not the HC warm cream look.
- Hero: photo LEFT, copy RIGHT. Brian's headshot faces right (toward the copy, not the margin).
- System fonts (-apple-system stack). No custom web fonts.
- Photo: rounded corners (border-radius: 16px), same headshot as HC site.
- Mobile responsive: hero stacks (photo on top), grid goes 2-col on tablet, 1-col on phone.
- Email: brian@humbleconviction.com is fine for now (contact link and footer).
- Footer: "The New Builder" (cosmetic, not legal entity name).
- No LinkedIn in the card grid (it's top-of-funnel for Brian, not a TNB feature).
- No coaching/consulting in the card grid (private for now).
- No "coming soon" language anywhere. War Room and Curated Events are being sold ahead of the product. If asked, Brian says "we're just getting those started."

## Implementation Notes for Nico
- Start from the `tnb-coming-soon` branch code of `hc-website` as the Next.js boilerplate (package.json, next.config, api/subscribe)
- Replace `page.tsx` with the new homepage design
- Wire `/api/subscribe` to Beehiiv (not Kit, not Firestore)
- Drop Brian's headshot into `public/images/headshot.jpg`
- Hardcode YouTube embed with current episode from HC channel (the pitching video that's on the current HC site)
- Reconnect Vercel: thenewbuilder.ai domain should point to this new repo's main branch (Vercel dashboard > Settings > Git > Connected Repository)
- Delete `tnb-coming-soon` branch from `hc-website` after this repo is live

## Environment & Config
- Vercel project: currently connected to `hc-website` tnb-coming-soon branch. Needs reconnection to `tnb-website` main.
- Domain: thenewbuilder.ai
- Beehiiv: for email capture. Same account as HC newsletter.

## Known Bugs / Issues
None (not yet deployed).

## Planned Features / Backlog
- Wire real links on Podcast and YouTube cards to actual URLs
- War Room, Meetups, Curated Events cards: add links/CTAs when those products have landing pages
- Swap YouTube embed to latest episode (manual update for now, consider auto-pull later)
- Consider adding a "Latest from the newsletter" section
- Consider adding social proof / testimonials when available

## Open Questions / Decisions Pending
- None blocking launch.

## Session Log
### April 15, 2026 — Homepage design approved
- **What shipped:** Full homepage design iterated with Brian over ~10 rounds. Six-card product grid (Podcast, YouTube, Newsletter, War Room, Meetups, Curated Events). Hero layout, copy, section order all approved. Static HTML preview created. Repo architecture decided: separate from hc-website, own repo at brhecht/tnb-website.
- **Known issues:** Repo not yet created on GitHub. Vercel not yet reconnected.
- **Next:** Nico creates GitHub repo, implements as Next.js, wires Beehiiv, reconnects Vercel, deploys.
