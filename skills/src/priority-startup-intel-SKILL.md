---
name: priority-startup-intel
description: "Priority Startup Intel — daily startup intelligence briefing. Synthesizes funding rounds, M&A, product launches, layoffs, exec moves, and hot takes from newsletters, VC firm blogs, web sources, X/Twitter, and Reddit into a concise morning email. Focused on SaaS, Consumer, and AI — private and venture-backed companies from pre-seed through pre-IPO. This skill defines the editorial logic, source list, format template, and delivery pipeline. Referenced by the priority-startup-intel scheduled task for autonomous daily execution. Also use this skill if the user asks to modify the briefing format, add/remove sources, tune the editorial filter, or manually trigger a briefing."
---

# Priority Startup Intel — Daily Intelligence Briefing

You are producing a daily intelligence briefing for Brian Hecht, a seasoned founder and investor. The goal is cocktail-party fluency: if someone mentions a notable startup event from the past 24-48 hours, Brian should know enough to engage on it.

## Editorial Filter

**In scope:** SaaS, Consumer, AI — private and venture-backed companies, with strong bias toward pre-seed through Series C. Event types:
- Funding rounds (pre-seed through Series C is the sweet spot; pre-seed, seed, and Series A/B are highest-value signal; Series D+ is table stakes)
- M&A and acquisitions (especially private company targets)
- Product launches, pivots, or major expansions
- Layoffs and restructuring at venture-backed or growth-stage companies
- Executive moves (CEO/CTO/CPO changes, notable hires) at private companies
- IPO filings — only when a known private company files, not market commentary
- Notable company milestones (crossing $100M ARR, user thresholds, etc.)
- Regulatory actions that directly impact startups (not broad policy)

**Company stage bias (HARD):** The sweet spot is **pre-seed through Series B/C** — the early- and growth-stage companies Brian might invest in, partner with, compete against, or encounter at a founder dinner. Series D and later are TABLE STAKES — include only with a non-obvious angle (unusual investor combination, structural deal terms, contrarian thesis, market-defining round size). Default cut: a Series D from a Tier 1 lead with no twist. A briefing that's mostly Series D rounds has missed the brief — the early-stage signal is what gives Brian edge.

**Mega-cap cap (HARD):** Items about **Anthropic, OpenAI, xAI, Google/DeepMind, Microsoft (incl. LinkedIn, GitHub), Meta, Amazon (incl. AWS), Apple, Tesla, SpaceX, Nvidia, Oracle, Salesforce, ServiceNow** — or any subsidiary thereof — are CAPPED at **1 per briefing total** and may appear ONLY in the Ecosystem Signal section. Never in Deals & Funding. Never in the lede. The framing must be the *implication for startups*, not the mega-cap event itself. If the most natural framing is "Anthropic raised X" or "OpenAI did Y," cut it. If the framing is "OpenAI moving to leased compute reshapes the addressable market for compute orchestration startups" — that's the bar. **Anthropic/OpenAI valuation news is automatically OUT** regardless of framing — Brian already knows AI valuations are climbing; that's not signal.

**Out of scope:** Biotech/pharma, hardware/semiconductors, climate/cleantech, crypto/web3, defense/gov tech, robotics, brain-computer interfaces — unless the company or investor is a name Brian would recognize from the SaaS/Consumer/AI world.

**CVC and out-of-scope-thesis items:** When a fund or company touches out-of-scope sectors (robotics, hardware, AVs, biotech, climate, defense), the item is includable ONLY if reframed around the in-scope angle (CVC behavior, capital flow patterns, in-scope portion of thesis). Lead the summary with the in-scope angle. Never let "physical AI / autonomous vehicles / robotics" be the headline thesis.

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

### Stream 2 is mandatory, not optional

Before drafting the email, you MUST have run targeted searches against **at least 8 of the listed VC firm domains** (e.g., `site:boldstart.vc`, `site:emcap.com`, `site:primary.vc`, etc.), checked Carta blog for new Peter Walker posts, and checked YC's blog. If you didn't, the briefing isn't ready — go back. This is the difference between Priority Intel and a TechCrunch summary.

**Stream 2 quota:** At least **60% of items (or minimum 4 items, whichever is higher)** must come from Stream 2 sources OR be a Series C-or-earlier private raise. If you can't meet this bar, the briefing runs SHORT (5–6 items) — never pad with mega-cap stories or generic Series D press to hit a count.

### Deduplication & Ranking

After all three streams complete, deduplicate. If the same event appears in multiple sources, keep the best single source (most detail, most credible). Never report the same event twice.

**Ranking priority:** Items surfaced from Stream 2 (primary sources) that didn't appear in mainstream press should be weighted higher — these are the "edge" items. Items from Stream 1 (newsletters) are table stakes. Items from Stream 3 (web search) fill gaps.

**Item ordering within each section (HARD):** Order by **edge, not by dollar amount**. Top of each section = the items least likely to appear in mainstream press. Bottom = the items everyone already saw. A $22M seed with a recognizable angel belongs above a $160M Series D from a Tier 1 lead. A small CVC fund close belongs above another mega-fund. **Never default to size-descending** — that's the lazy ordering that makes the briefing read like generalist tech press.

## Output Format

The briefing is delivered as a formatted HTML email to brhnyc1970@gmail.com.

**Subject line:** `Priority Startup Intel — [Day of Week], [Month] [Day]`
On Mondays: `Priority Startup Intel — Weekend Roundup, [Month] [Day]`

**Email body structure:**

```
PRIORITY STARTUP INTEL — [Full Date]

[OPTIONAL lede — see Lede Rule below. Skip entirely if no qualifying thesis.]

DEALS & FUNDING
• [Bold headline] — [2-3 sentences MAX, including "so what"]. [Source link]
• [Next item...]

PRODUCT & LAUNCHES
• [Bold headline] — [2-3 sentences MAX]. [Source link]

PEOPLE & MOVES
• [Bold headline] — [2-3 sentences MAX]. [Source link]

INVESTOR & ECOSYSTEM MOVES
• [Bold headline] — [2-3 sentences MAX]. [Source link]
(New fund formations, GP/partner moves, accelerator news, Carta/Peter Walker data drops, notable LP activity)

ECOSYSTEM SIGNAL
• [Bold headline or quote attribution] — [2-3 sentences MAX]. [Source link]
(Hot takes from X/Reddit, provocative VC opinions, data-driven insights about fundraising dynamics, market shifts. The single allowed mega-cap item, if any, lives here.)

---
[Total item count] items · Sources: [list of newsletter/site names that contributed]

TODAY'S INSPIRATION
"[Quote text]" — [Attribution]
```

**Lede Rule (HARD):** Use a one-sentence lede ONLY when 2+ private-company items in today's briefing share a thesis worth naming (e.g., "Three vertical-AI Series A's in legal, finance, and govtech today — the professional-services unbundling is becoming a category, not a thesis."). NEVER use the lede to summarize mega-cap news, day-of-the-week generalities ("heavy deal flow day"), or "AI is heating up" framing. NEVER name a mega-cap company in the lede. If no thesis emerges from the items, **skip the lede entirely** — most days won't have one.

**Today's Inspiration rules:**
- One quote per briefing, placed at the very bottom after the source line
- Draw from: stoics (Marcus Aurelius, Seneca, Epictetus), classic business thinkers (Drucker, Grove, Christensen), widely respected founders/operators (Reid Hoffman, Guy Kawasaki, Sara Blakely, Howard Schultz), historical figures (Theodore Roosevelt, Churchill, Lincoln), philosophers and writers (Emerson, Thoreau, Nassim Taleb), proverbs
- The quote should resonate with someone who builds companies and takes risk — not generic motivational poster material
- **Avoid:** Polarizing figures (Elon Musk, Mark Zuckerberg, etc.), active politicians, anyone who might alienate a segment of a professional audience. When in doubt, skip the person.
- No signoff after the quote — the quote IS the signoff
- Rotate widely. Don't repeat the same person more than once per month. Keep a mental mix across categories (stoic one day, founder the next, historical figure after that)

**Formatting rules:**
- **Item length cap (HARD):** Each item summary is **2–3 sentences total**, including the "so what" — not a paragraph followed by another paragraph. The headline carries the *what*; the source link carries the depth; your job is the *angle*. If you can't compress the value into 3 sentences, the item probably isn't strong enough.
- **Trade length for item count:** Better to ship 12 sharp items than 8 fat ones. The user is sophisticated and will click through to the source for any item they want to go deeper on.
- 10–14 items total on a normal day. Fewer on slow days — never pad.
- Headlines should be clear and factual: "Stripe acquires Bridge for $1.1B" not "Stripe Makes Bold Move"
- Every summary must include the "so what" — not just what happened but why it matters or what it signals
- Hot Takes section captures notable opinions from X/Twitter, Reddit, podcasts — attributed to the person
- Omit any section that has zero items (don't show empty headers)
- Format as clean HTML email with inline styles (no external CSS)
- Use a simple, professional design: dark text on white, minimal styling

## Delivery

Use the Gmail MCP to create a draft email to brhnyc1970@gmail.com. The email should be content-type text/html. A Google Apps Script running in Brian's Gmail auto-sends any draft matching the "Priority Startup Intel" subject pattern, so a successful draft creation = delivered email.

**Gmail MCP tool name:** The draft-creation tool is currently exposed as `create_draft` (previously `gmail_create_draft`). If the expected name doesn't resolve, use `ToolSearch` with a keyword query like `gmail draft` to find the currently registered tool — do not fail silently on a tool-name mismatch.

## Delivery Failure Protocol

If draft creation fails (tool not found, auth error, server error) after one retry with the correct tool name, do not silently save an HTML file and exit. Execute this failure sequence in order:

1. **Save fallback HTML** to `/Users/BRHPro/Developer/Priority-Startup-Intel-YYYY-MM-DD.html` so the content is not lost.
2. **Notify Brian via Brain Inbox ping** using the `handoff-notify` API. The scheduled task runs headless so Chrome tools are not available — use a direct Bash `curl` or `node fetch` from the VM. The Cowork scheduled-task VM has outbound network access:
   ```bash
   curl -s -X POST https://brain-inbox-six.vercel.app/api/handoff-notify \
     -H "Content-Type: text/plain" \
     -d '{"project":"Priority Startup Intel","summary":"⚠️ Morning briefing FAILED to send — draft creation error. Fallback HTML saved at /Users/BRHPro/Developer/Priority-Startup-Intel-YYYY-MM-DD.html. Error: <error message>","recipient":"brhnyc1970@gmail.com","recipientSlackId":"U096WPV71KK"}'
   ```
3. **If the Brain Inbox ping also fails**, write a `FAILURE.md` next to the HTML file with the error, timestamp, and what was attempted — so the next session (or the daily-reach-out health check) can surface it.
4. **Always** include a terse, actionable error summary in the session's final assistant message — state what failed, where the HTML landed, whether the Brain Inbox ping went through, and what Brian needs to do (e.g., "reconnect Gmail MCP" or "manually send the draft"). No euphemisms.

The goal: Brian should learn about a delivery failure within minutes of 7am, not by noticing an absent email hours later.

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
4. **Stream 2 is mandatory** — query at least 8 listed VC firm domains via `site:` searches, check Carta blog (Walker), check YC blog. Do not skip this step.
5. Run web search sweep (Stream 3)
6. Deduplicate, apply the Brian Lens, and rank by significance
7. **Pre-flight checklist before drafting** — verify ALL of these:
   - [ ] Mega-cap items: ≤1 total, in Ecosystem Signal only, with startup-implication framing (no Anthropic/OpenAI valuation news)
   - [ ] Lede: only present if 2+ private items share a thesis; no mega-cap names; no generic "heavy deal flow" framing
   - [ ] Stage mix: ≥60% of items are pre-seed/seed/Series A/B/C OR Stream 2-sourced
   - [ ] Item ordering: edge first, table-stakes last (NOT size-descending)
   - [ ] Item length: every summary ≤3 sentences total
   - If any check fails, fix before drafting
8. Format the briefing email
9. Create Gmail draft (Apps Script auto-sends it) — see Delivery section for tool name guidance
10. If any errors occurred (e.g., Gmail access failed, no newsletters found), note it at the bottom of the email so Brian knows the coverage may be incomplete
11. If draft creation fails, execute the Delivery Failure Protocol — save fallback HTML, ping Brain Inbox, and flag the failure clearly in the final output
