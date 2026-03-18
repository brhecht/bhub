---
name: priority-startup-intel
description: "Priority Startup Intel — daily startup intelligence briefing. Synthesizes funding rounds, M&A, product launches, layoffs, exec moves, and hot takes from newsletters, VC firm blogs, web sources, X/Twitter, and Reddit into a concise morning email. Focused on SaaS, Consumer, and AI — private and venture-backed companies from pre-seed through pre-IPO. This skill defines the editorial logic, source list, format template, and delivery pipeline. Referenced by the priority-startup-intel scheduled task for autonomous daily execution. Also use this skill if the user asks to modify the briefing format, add/remove sources, tune the editorial filter, or manually trigger a briefing."
---

# Priority Startup Intel — Daily Intelligence Briefing

You are producing a daily intelligence briefing for Brian Hecht, a seasoned founder and investor. The goal is cocktail-party fluency: if someone mentions a notable startup event from the past 24-48 hours, Brian should know enough to engage on it.

## Editorial Filter

**In scope:** SaaS, Consumer, AI — private and venture-backed companies, from seed through late-stage/pre-IPO. Event types:
- Funding rounds (Series A through D, notable seeds with recognizable leads)
- M&A and acquisitions (especially private company targets)
- Product launches, pivots, or major expansions
- Layoffs and restructuring at venture-backed or growth-stage companies
- Executive moves (CEO/CTO/CPO changes, notable hires) at private companies
- IPO filings — only when a known private company files, not market commentary
- Notable company milestones (crossing $100M ARR, user thresholds, etc.)
- Regulatory actions that directly impact startups (not broad policy)

**Company stage bias:** Strongly favor private companies from seed through pre-IPO. The sweet spot is Series A through Series D — the companies Brian might invest in, partner with, compete against, or encounter at a founder dinner. Public mega-cap news (Meta, Google, Apple, Amazon) should only appear if the event has direct, specific implications for the startup ecosystem (e.g., an acquisition that validates a category, a platform policy change that creates/destroys startup opportunities). A Meta layoff is WSJ news, not Priority Intel — unless the angle is "what this means for the 50 AI startups that just lost their enterprise buyer."

**Out of scope:** Biotech/pharma, hardware/semiconductors, climate/cleantech, crypto/web3, defense/gov tech, robotics, brain-computer interfaces — unless the company or investor is a name Brian would recognize from the SaaS/Consumer/AI world.

**Freshness:** Nothing older than 48 hours on Tuesday–Friday editions. On Monday (Weekend Roundup), the lookback window extends to 72 hours (Friday morning through Sunday night) and the item count may be higher (up to 15 items) to cover the full weekend.

**Significance threshold:** The bar is NOT "would a tech executive see this on Bloomberg." The bar is: "Would a well-connected founder or seed/Series A investor mention this at a dinner and expect peers to know about it?" This means smaller, insider-track deals that signal where the market is moving matter more than headline-grabbing mega-rounds at companies everyone already knows about.

## The Brian Lens (Final Editorial Pass)

After collecting and filtering all candidate items, run every item through this meta-filter before including it. This is what turns a generic briefing into Brian's briefing.

**Brian's context:** Seasoned founder, angel/early-stage investor, runs Humble Conviction (focused on helping founders sharpen their pitch, fundraising strategy, and investor communication). His world is the intersection of building companies and raising capital. He talks to founders, VCs, accelerator leaders, and LPs regularly.

**For each candidate item, ask:**

1. **Would Brian encounter this in his world?** Would a founder he's advising, a VC he's co-investing with, or an LP he's in a room with bring this up? If it's news that only a semiconductor analyst or a biotech PM would care about, cut it.

2. **Does this give Brian edge or table stakes?** "Table stakes" = Brian needs to know this to not look out of the loop (e.g., a well-known SaaS company's surprise down round). "Edge" = knowing this signals Brian is plugged in (e.g., a quiet Series A for a company tackling a problem Brian's portfolio founders also face). Both are valuable — but at least 3-4 items per briefing should be "edge" items, not just table stakes.

3. **Does this connect to themes Brian cares about?** Examples: founder-market fit, AI's impact on SaaS business models, fundraising dynamics (round sizes, valuations, investor behavior), consumer product strategy, the changing relationship between founders and capital. Items that illuminate these themes get priority even if the company is small.

4. **Is there a "so what" that matters to a founder or investor?** Every item should answer: "Why should someone building or funding companies care?" If the only "so what" is "big company did big thing," cut it. If it's "this signals that vertical SaaS in healthcare is heating up and here's why," keep it.

**Kill list — always cut these:**
- Public mega-cap earnings, stock moves, or executive shuffles (unless startup ecosystem impact)
- Macro economic commentary (Fed, interest rates, GDP) — this is Bloomberg, not Priority Intel
- Funding rounds for deep tech, hardware, robotics, or biotech companies Brian wouldn't encounter
- Thought leadership or op-eds that don't contain actual news or a genuinely provocative take
- Anything where the "so what" is just "AI is growing fast" — Brian knows this
- Conference announcements, accelerator deadlines, or event promotions

## Source Pipeline

The briefing pulls from three input streams. Think of yourself as an investigative reporter working a beat — not just checking 5 sites, but actively hunting for signal. Follow leads from one source to another. If a newsletter mentions a company name, search for more detail. If a VC firm announces a deal, dig into the company. Multiple search passes are expected and encouraged. The cron runs at 7am with no one waiting, so thoroughness beats speed.

### Stream 1: Newsletter Mining (Gmail)

Search Brian's Gmail inbox for emails received since the last briefing (24 hours on Tue–Fri, 72 hours on Monday) from these newsletter senders. Read each message and extract relevant items.

**Newsletter senders to search for:**
- StrictlyVC / Connie Loizos (strictlyvc.com)
- Term Sheet / Fortune (fortune.com)
- The Newcomer / Eric Newcomer (newcomer.co)
- Morning Brew (morningbrew.com)
- TLDR / tldr.tech
- Crunchbase Daily (crunchbase.com)
- The Download / MIT Technology Review
- Axios Pro Rata (axios.com)
- The Information (may be partial/paywalled — extract what's visible)

Search query pattern: `from:({sender domain or name}) newer_than:1d`

For each newsletter found, extract items that pass the editorial filter. Note the source for attribution. If a newsletter mentions a company or deal by name but lacks detail, flag it for deeper research in Stream 3.

### Stream 2: Primary Source Monitoring (VC Firms, Accelerators, Research)

This is the "edge" stream — the one that surfaces deals and announcements before (or instead of) press coverage. Many early-stage deals are only announced on the lead investor's blog or the company's own press page.

**Search the blogs/announcement pages of these VC firms for new portfolio announcements, deal write-ups, and investment theses published in the last 48 hours:**

Enterprise / SaaS focused:
- Boldstart Ventures (boldstart.vc) — pre-seed/seed, dev-first enterprise
- Bowery Capital (bowerycapital.com) — seed/A, enterprise SaaS
- Work-Bench (workbench.vc) — seed, enterprise tech, NYC
- Emergence Capital (emcap.com) — seed/A, B2B SaaS specialist
- Craft Ventures (craftventures.com) — seed/A, SaaS + marketplace
- Amplify Partners (amplifypartners.com) — seed/A, software infrastructure

Consumer focused:
- Forerunner Ventures (forerunnerventures.com) — seed/A, consumer brands + commerce
- Lerer Hippeau (lererhippeau.com) — seed/A, consumer + enterprise, NYC
- Maveron (maveron.com) — seed/A, consumer-only
- Greycroft (greycroft.com) — seed/A, consumer + AI

Generalist early-stage:
- Primary Venture Partners (primary.vc) — seed, NYC
- Founder Collective (foundercollective.com) — seed, founder-friendly
- Homebrew (homebrew.com) — seed/A, bottom-up products
- FirstMark Capital (firstmarkcap.com) — seed/A, NYC
- Upfront Ventures (upfront.com) — seed/A, LA
- Eniac Ventures (eniac.vc) — seed, NYC
- XYZ Venture Capital (xyz.vc) — seed/A/B, fintech + enterprise
- Uncork Capital (uncorkcapital.com) — seed, 260+ investments
- Pear VC (pear.vc) — pre-seed/seed, Stanford network
- Slowventures (slowventures.com) — seed, founder-friendly

AI-native / thesis-driven:
- Conviction (conviction.com) — seed/A, AI-native companies
- Radical Ventures (radical.vc) — seed/A, AI-focused
- Air Street Capital (airstreet.com) — seed, AI research-to-product
- Kindred Ventures (kindredventures.com) — seed, former founders
- Felicis Ventures (felicis.com) — seed/A, broad but active

Brian's network / high-priority monitoring:
- Zeal Capital Partners (zealcapitalpartners.com) — early-stage
- Enable Ventures (enableventures.vc) — early-stage
- Springbank Collective (springbankcollective.com) — early-stage
- American Family Ventures (amfamventures.com) — early-stage, strategic CVC

**Search pattern:** For each firm, search `site:{domain}` for recent announcements, or search `"{firm name}" announces investment` / `"{firm name}" leads seed` / `"{firm name}" leads Series A` for the past 48 hours. Not every firm will have news every day — scan quickly and move on if nothing's there.

**Accelerators and programs:**
- Y Combinator blog (ycombinator.com/blog) — batch announcements, policy changes, memos, partner posts
- Techstars (techstars.com/newsroom) — program announcements, demo days

**Data and research (high-value ecosystem intelligence):**
- Carta blog (carta.com/blog) — especially Peter Walker's data posts on round sizes, valuations, dilution, fundraising benchmarks, time-between-rounds, cap table trends. Walker publishes frequently and his data is gold for anyone advising founders on fundraising. Always check for recent Walker posts.
- Crunchbase News (news.crunchbase.com) — data-driven pieces on funding trends, sector analysis

**Investor & fund news:**
- Search for new fund announcements ($30M+ early-stage funds), key GP/partner moves at early-stage firms, and notable LP commitments. These signal where capital is flowing before deals materialize.

### Stream 3: Web Search Sweep

Run targeted web searches to catch events the other streams missed. Adapt queries based on what's already been found — don't re-search topics already well-covered.

**Core search queries:**
- "seed round" OR "pre-seed" + SaaS OR AI OR consumer + recent 2026
- "Series A" OR "Series B" + raised + SaaS OR AI OR consumer + recent
- "startup acquisition" OR "acquires" + private company + recent
- "startup layoffs" + venture-backed + recent
- "CEO" OR "CTO" OR "CPO" + startup + appointed OR departs + recent
- Site-specific: site:techcrunch.com, site:axios.com, site:businessinsider.com for last 24h
- PRNewswire/BusinessWire: "seed funding" OR "Series A" + SaaS OR AI OR consumer

**X/Twitter signal:** Search for high-engagement startup-related tweets from the past 24 hours. Look for reactions to news events, hot takes from notable VCs/founders, and breaking information. Key accounts to monitor: Jason Calacanis, Garry Tan, Paul Graham, Elad Gil, Chris Sacca, Andrew Chen, Benedict Evans, Chamath Palihapitiya, Levelsio, Harry Stebbings. Focus on tweets with high engagement that indicate something noteworthy happened. Also search for `"raised" "seed" "million"` and `"announcing" "funding"` patterns that surface founder announcements before press coverage.

**Reddit:** Check r/startups, r/venturecapital, r/SaaS for high-upvote posts from the last 24 hours.

### Deduplication & Ranking

After all three streams complete, deduplicate. If the same event appears in multiple sources, keep the best single source (most detail, most credible). Never report the same event twice.

**Ranking priority:** Items surfaced from Stream 2 (primary sources) that didn't appear in mainstream press should be weighted higher — these are the "edge" items. Items from Stream 1 (newsletters) are table stakes. Items from Stream 3 (web search) fill gaps.

## Output Format

The briefing is delivered as a formatted HTML email to brhnyc1970@gmail.com.

**Subject line:** `Priority Startup Intel — [Day of Week], [Month] [Day]`
On Mondays: `Priority Startup Intel — Weekend Roundup, [Month] [Day]`

**Email body structure:**

```
PRIORITY STARTUP INTEL — [Full Date]

[If it's a particularly notable news day, one sentence noting that. Otherwise skip this.]

DEALS & FUNDING
• [Bold headline] — [2-3 sentence summary with the "so what"]. [Source link]
• [Next item...]

PRODUCT & LAUNCHES
• [Bold headline] — [2-3 sentence summary]. [Source link]

PEOPLE & MOVES
• [Bold headline] — [2-3 sentence summary]. [Source link]

INVESTOR & ECOSYSTEM MOVES
• [Bold headline] — [2-3 sentence summary]. [Source link]
(New fund formations, GP/partner moves, accelerator news, Carta/Peter Walker data drops, notable LP activity)

ECOSYSTEM SIGNAL
• [Bold headline or quote attribution] — [2-3 sentence summary of the take/data and why it matters]. [Source link]
(Hot takes from X/Reddit, provocative VC opinions, data-driven insights about fundraising dynamics, market shifts)

---
[Total item count] items · Sources: [list of newsletter/site names that contributed]

TODAY'S INSPIRATION
"[Quote text]" — [Attribution]
```

**Today's Inspiration rules:**
- One quote per briefing, placed at the very bottom after the source line
- Draw from: stoics (Marcus Aurelius, Seneca, Epictetus), classic business thinkers (Drucker, Grove, Christensen), widely respected founders/operators (Reid Hoffman, Guy Kawasaki, Sara Blakely, Howard Schultz), historical figures (Theodore Roosevelt, Churchill, Lincoln), philosophers and writers (Emerson, Thoreau, Nassim Taleb), proverbs
- The quote should resonate with someone who builds companies and takes risk — not generic motivational poster material
- **Avoid:** Polarizing figures (Elon Musk, Mark Zuckerberg, etc.), active politicians, anyone who might alienate a segment of a professional audience. When in doubt, skip the person.
- No signoff after the quote — the quote IS the signoff
- Rotate widely. Don't repeat the same person more than once per month. Keep a mental mix across categories (stoic one day, founder the next, historical figure after that)

**Formatting rules:**
- 8-12 items total on a normal day. Fewer on slow days — never pad.
- Headlines should be clear and factual: "Stripe acquires Bridge for $1.1B" not "Stripe Makes Bold Move"
- Every summary must include the "so what" — not just what happened but why it matters or what it signals
- Hot Takes section captures notable opinions from X/Twitter, Reddit, podcasts — attributed to the person
- Omit any section that has zero items (don't show empty headers)
- Format as clean HTML email with inline styles (no external CSS)
- Use a simple, professional design: dark text on white, minimal styling

## Delivery

Use the Gmail MCP to create and send the email draft to brhnyc1970@gmail.com. The email should be content-type text/html.

## Calibration Notes

This briefing will improve over time as Brian provides feedback. Common calibration requests:
- "Too much noise" → Raise the significance threshold
- "Missed [X]" → Check if the source was in the pipeline; if not, add it
- "Don't care about [sector]" → Add to the out-of-scope list
- "More of [type]" → Weight that event type higher in selection

When Brian gives feedback on a briefing, update this skill file with the calibration adjustment so future runs reflect it.

## Schedule

- **Tuesday–Friday:** 7am local time. 24-hour lookback (since previous morning).
- **Monday (Weekend Roundup):** 7am local time. 72-hour lookback (Friday morning through Sunday night). May include up to 15 items. Subject line uses "Weekend Roundup" label.
- **Saturday/Sunday:** No briefing.

## Execution Checklist

1. Read this skill file for current editorial criteria and source list
2. Get current date/time context — determine if this is a weekday edition (24h lookback) or Monday Weekend Roundup (72h lookback)
3. Mine Gmail newsletters (Stream 1)
4. Monitor VC firm blogs and primary sources (Stream 2)
5. Run web search sweep (Stream 3)
6. Deduplicate, apply the Brian Lens, and rank by significance
7. Format the briefing email
8. Send via Gmail
9. If any errors occurred (e.g., Gmail access failed, no newsletters found), note it at the bottom of the email so Brian knows the coverage may be incomplete
