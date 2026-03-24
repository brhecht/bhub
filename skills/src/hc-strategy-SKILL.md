---
name: hc-strategy
description: "Humble Conviction strategic brain — loads full HC business context, operating plan, and expert research for any strategy discussion. Use this skill whenever the user mentions HC strategy, Humble Conviction business planning, cohort design, revenue modeling, quarterly review, coaching pipeline, content cadence, distribution strategy, live session planning, podcast strategy, async course planning, or any question about what HC should be building, selling, or prioritizing next. Also triggers on 'HC check-in', 'strategy check-in', 'quarterly review', 'where are we with HC', or any reference to the HC operating plan or revenue targets. Trigger aggressively — if the conversation touches HC as a business (not just HC content or HC funnel code), this skill should load."
---

# HC Strategy Skill

This skill gives Claude full context on Humble Conviction's strategic direction, operating plan, and the research that informed it. The goal is continuity — any session that touches HC business strategy should have the same depth of context as the March 23-24, 2026 strategy sessions where these decisions were made and refined.

## On Load

Read these two files immediately, in parallel:

1. `B-Suite/hc-strategy/STRATEGY-CONTEXT.md` — the strategic brain. Contains Brian's profile, psychological execution profile, all key decisions (positioning, product architecture, revenue model, distribution hierarchy, podcast strategy, AI positioning), probability-weighted scenarios, research findings summary, and the quarterly review protocol.

2. `B-Suite/hc-strategy/operating-plan.md` — the 8-quarter operating plan with revenue projections by stream (coaching, async courses, intensives/cohorts, workshops), growth channel activity per quarter, probability-weighted scenarios, stream-by-stream confidence levels, and milestone targets.

Both files are in the mounted B-Suite folder. If B-Suite isn't mounted, ask the user to mount it.

After reading, briefly confirm you've loaded context and ask what they want to work on — don't dump a summary unless asked.

## Deep Reference (Read Only When Needed)

`B-Suite/hc-strategy/expert-analysis-v5.md` — comprehensive integrated expert analysis covering positioning, market definition, product architecture, distribution hierarchy, podcast strategy, AI positioning, revenue projections, probability-weighted scenarios, and red team pressure testing. Read this only if the user wants to revisit research findings, challenge assumptions, or needs specific data points (market sizing, comparable case studies, conversion benchmarks, SLO model analysis, etc.).

`B-Suite/hc-strategy/expert-analysis-v3.md` and `archive/` — earlier expert analysis versions (v1-v4). Historical reference only. v5 supersedes all prior conclusions.

## How to Engage on HC Strategy

Brian is a seasoned founder and investor. He doesn't need basics explained. Match his directness and default to actionable output over theory.

Key things to internalize from STRATEGY-CONTEXT.md:

- **Brian's psychology is the #1 execution variable.** He lights up on live performance, systems building, AI/startup thinking, and networking with a structured vehicle (podcast, events). He stalls on direct self-promotion, cold outreach, and public offers where his network could see him fail. Strategy recommendations that ignore this will fail.

- **Three-layer positioning: wedge, depth, accelerant.** Public brand leads with founder communication (the wedge). Actual delivery is full-stack founder guidance (the depth). AI is the brand accelerant — gets him noticed, booked, and remembered. AI is NOT the product.

- **Expert services business using creator tools.** Brian is NOT primarily in the creator economy. Relationships and reputation drive revenue; content and courses amplify reach over time.

- **Four revenue streams, sequenced.** Coaching (the launchpad, not the permanent backbone) → Async courses (SLO model — ads drive sales that pay for ads while building the list; starts with one course, grows to a catalog) → Intensive/cohort (2-3 day format first, NOT 8 weeks) → Workshops (opportunistic).

- **Podcast is a networking strategy with content as byproduct.** Audio-first, weekly, 30-min remote. Brian controls the outreach. Three layers: existing network → other podcasters (reciprocal invitations) → guest appearances on their shows. AI angle makes Brian more bookable.

- **Distribution hierarchy:** LinkedIn (#1) → Email/newsletter → Meta ads + quiz funnel (SLO) → Podcast → Monthly live session → Direct outreach → YouTube shorts. YouTube long-form deprioritized. Newsletter sponsorships removed from revenue model.

- **$250K+ annualized by month 24 is the target.** Probability-weighted expected value: ~$298K over 24 months. 55-60% probability of hitting $250K annualized. Floor: $120-150K. Ceiling: $500K+.

- **Biggest upside lever:** SLO model for async courses working at scale.

- **Biggest downside risk:** Brian's avoidance patterns limiting growth on channels that require uncomfortable behavior.

## Quarterly Review Mode

If the user asks for a quarterly review or check-in, follow the protocol in STRATEGY-CONTEXT.md (Section: "Quarterly Review Protocol"). Compare actuals to the operating plan across all 9 dimensions:

1. Revenue by stream vs. plan
2. Email list size vs. projection
3. LinkedIn followers vs. projection
4. Async course metrics (sales/month, CAC, SLO breakeven)
5. Live session metrics (registrations, attendance, conversion)
6. Coaching pipeline (concurrent clients, churn, source)
7. Podcast metrics (episodes, cross-promotion, reciprocal invitations, business conversations)
8. Content consistency (LinkedIn, newsletter, podcast cadence)
9. Psychological check (where is Brian stalling? what's energizing?)

After the review, update `operating-plan.md` with actuals and adjust future quarter projections. Also update `STRATEGY-CONTEXT.md` if any strategic decisions have changed.

## Updating These Documents

Both STRATEGY-CONTEXT.md and operating-plan.md should be treated as living documents. After any substantive strategy session:

- Update STRATEGY-CONTEXT.md with new decisions, revised assumptions, or new research findings
- Update operating-plan.md with actuals and re-forecasted projections
- Note the date and nature of the update at the top of each file

When updating, amend in place — don't create new versions. Git history preserves the timeline.

## What NOT to Do

- Don't be a yes-man. Brian explicitly asked for pushback, challenged assumptions, and evidence-based disagreement. Multiple rounds of expert research exist because he doesn't want an echo chamber.
- Don't optimize for Brian's comfort zone. This has led to suboptimal strategy in the past (ChatGPT dismissed cohorts, v3 dismissed async courses, v4 underestimated time commitment).
- Don't treat the operating plan as gospel. It's a hypothesis with ~55-60% probability of hitting the primary target. Adjust based on real data.
- Don't conflate HC strategy with HC funnel code. This skill is for business strategy. The funnel codebase has its own handoff in `hc-funnel/HANDOFF.md`.
- Don't assume "async courses" means just Eddy. It's a product *category* — multiple courses, bundles, potential academy trajectory. Eddy is course #1.
