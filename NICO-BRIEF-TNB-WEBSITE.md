# Nico Brief: TNB Website (thenewbuilder.ai)
*April 15, 2026*

## What This Is
Brian approved the homepage design for thenewbuilder.ai. Your job: implement it as a production Next.js app in a new repo, wire email capture to Beehiiv, and deploy.

## Step 1: Create the Repo
1. Go to github.com/new
2. Create `brhecht/tnb-website` (public)
3. Clone it locally to `~/Developer/B-Suite/tnb-website`

## Step 2: Bootstrap from Existing Code
The `tnb-coming-soon` branch of `hc-website` has the Next.js boilerplate you already set up (package.json, next.config, api/subscribe, Tailwind). Use that as your starting point:

```bash
cd ~/Developer/B-Suite/tnb-website
git checkout -b temp
cd ~/Developer/B-Suite/hc-website
git checkout tnb-coming-soon
cp -r package.json package-lock.json next.config.ts postcss.config.mjs tsconfig.json src public ~/Developer/B-Suite/tnb-website/
cd ~/Developer/B-Suite/tnb-website
git checkout main
npm install
```

## Step 3: Implement the Homepage
Replace `src/app/page.tsx` with the approved design. The static HTML preview is at:
`~/Developer/B-Suite/hc-website/tnb-homepage-preview.html`

Open it in a browser to see the approved layout. Then implement it as a Next.js page using the same structure. Key details:

### Sections (top to bottom):
1. **Nav** — "THE NEW BUILDER" wordmark (18px, black, bold, spaced tracking) left. YouTube, LinkedIn, Contact links right (gray, hover to black). Hide links on mobile.
2. **Hero** — Two columns. Brian's photo LEFT, tagline + one-liner RIGHT. Photo faces right (toward the copy). Tagline: "Navigating / the AI era. / Together." (line breaks as shown). One-liner below in gray: "Bringing founders together to rethink how companies get built, with AI as the foundation, not just a tool."
3. **HR divider**
4. **"Why I'm building this."** — Stacked layout (headline on top, body below, NOT two-column). Max-width ~720px. Body copy:
   - "I've been a founder and investor for 30+ years. I never wrote a line of code. Then I started building with AI, and couldn't stop."
   - "Every serious conversation I was having about startups had shifted to the same question: what does it actually mean to build a company now that the rules have changed?"
   - "The people who figure it out will be the ones building right now and comparing notes, not reading about it from the sidelines. The New Builder is where that happens, through content, conversations, and community."
5. **HR divider**
6. **"Builders Figuring it Out. Together."** — 3x2 card grid. Each card: icon on top, bold label, gray description. Cards are NOT clickable links (except Podcast and YouTube which link to YouTube channel, and Newsletter which anchors to subscribe form).
   - **Podcast:** Weekly conversations with founders and builders navigating the AI era.
   - **YouTube:** 20K subscribers. Podcast companion and original content.
   - **Newsletter:** Weekly hot takes from Brian and thoughtful builders in the field.
   - **The War Room:** A premium mastermind for founders who want to go deeper with real-time peer learning.
   - **Meetups:** No pitches, no agenda, just AI builders socializing and sharing notes.
   - **Curated Events:** Invite-only roundtables and dinners for a smaller group of builders going deeper.
7. **HR divider**
8. **"Latest Episode"** — YouTube embed. Hardcode the current episode that's on the HC homepage (the pitching video). We'll swap this when TNB episodes are ready.
9. **HR divider**
10. **"Stay in the loop"** — Email capture. Headline, description ("A weekly newsletter for founders building in the AI era. Brian's take + hot takes from builders in the field."), form with Email + First name + Subscribe button. Wire to Beehiiv.
11. **HR divider**
12. **"About Brian"** — Short bio. "Brian Hecht is a 4x exited founder and former Managing Director of ERA, New York's top startup accelerator, where he spent a decade coaching 2,500+ pitches and investing in early-stage companies. He now spends most of his time building with AI, advising founders, and hosting live events in NYC. The New Builder is where all of that comes together."
13. **Footer** — "The New Builder" left, LinkedIn / YouTube / Email links right.

### Design:
- White background, black type, gray-400 accents
- System fonts (-apple-system stack)
- Thin gray HR dividers between sections
- Photo: rounded corners (border-radius: 16px), same headshot
- Cards: vertical layout (icon on top), 1px gray border, rounded-xl
- Black buttons, black wordmark
- Mobile: hero stacks (photo then copy), grid goes 2-col tablet / 1-col phone

### Image:
- Drop Brian's headshot into `public/images/headshot.jpg`

## Step 4: Wire Email Capture
Wire `/api/subscribe` to Beehiiv (same account as the HC newsletter). The form sends `{ email, name, source: "newbuilder-homepage" }`.

## Step 5: Connect Vercel
1. In Vercel dashboard, find the project that serves thenewbuilder.ai
2. Settings > Git > disconnect from hc-website
3. Connect to `brhecht/tnb-website` main branch
4. Verify thenewbuilder.ai domain is assigned
5. Deploy

## Step 6: Clean Up
1. Delete the `tnb-coming-soon` branch from `hc-website`:
   ```bash
   cd ~/Developer/B-Suite/hc-website
   git push origin --delete tnb-coming-soon
   ```
2. Write a HANDOFF.md in the new `tnb-website` repo (a draft is provided alongside this brief: `tnb-website-HANDOFF.md`). Commit it.

## Reference Files
All in `~/Developer/B-Suite/`:
- `hc-website/tnb-homepage-preview.html` — the approved static HTML preview (open in browser)
- `hc-website/tnb-homepage-draft.tsx` — a Next.js draft (may need updating to match latest HTML)
- `NICO-BRIEF-TNB-WEBSITE.md` — this file
- `tnb-website-HANDOFF.md` — draft HANDOFF.md for the new repo

## Contact
brian@humbleconviction.com is the contact email for now (nav + footer).
Footer copyright: "The New Builder" (cosmetic).

## Don't
- Don't rename the YouTube channel yet (separate task, separate checklist)
- Don't wire War Room / Meetups / Curated Events cards to anything yet
- Don't add animations or transitions
- Don't use em dashes in any copy
