# HANDOFF HISTORY — B Suite
*Chronological log of meaningful B-Suite changes. Newest first. Current state lives in [HANDOFF-MASTER.md](./HANDOFF-MASTER.md) and per-app `HANDOFF.md` files.*

---

## May 5, 2026 — Fleet-wide bsync silent-failure fix (root cause for ghost drift)

Found and fixed the underlying reason files have been mysteriously vanishing on Macs for weeks. `bsync.sh` line 39 had a hardcoded fallback to `$HOME/Developer/clients/hc/B-Suite` (the pre-March-12 path). `install-bsync.sh` did not write `EnvironmentVariables` into the launchd plist, so when the agent fired bsync.sh on the Mac with no ambient `BSUITE_DIR`, it hit that broken fallback and silently failed every hour — never pulling, never auto-restoring drift. Pro's `.bsync-log` had ZERO Mac-side entries since at least April 30; the "hourly auto-pull" was a no-op for weeks. Today's `handoff here` found 290 deletions in tnb-website (entire glossary), 26 in brain-inbox, 1 in hc-website, and 7 missing tnb-strategy subdirectory files (April 29 reorg never landed). All restored. Two-part fix shipped in commit `a31e24a`: (1) bsync.sh fallback now points to `$HOME/Developer/B-Suite`, (2) install-bsync.sh plist writes explicit BSUITE_DIR env var. Pro reinstalled, verified — first successful Mac-side bsync run in weeks logged at 14:11:37, fresh bhealth committed (0 flags). **iMac and Air still need the same treatment** — on next session there, run: `cd ~/Developer/B-Suite/bhub && git pull && bash install-bsync.sh`. Mini already pulled but should also re-run install-bsync.sh to pick up the EnvironmentVariables addition. Possible bhealth enhancement: detect "zero Mac-side bsync entries in last 7 days" as a Tier-3 flag.

---

## May 3, 2026 (PM) — TNB Website: Substack iframe replaced with native subscribe form

The Stay-in-the-loop section's `<iframe src="https://thenewbuilder.substack.com/embed">` was rendering as empty space on the live site (ad-blockers strip substack.com iframes; the default embed is also visually anemic — 480x320 white box on a white page). Replaced with a branded native form (`src/app/_components/SubscribeForm.tsx`) that proxies through `/api/subscribe` to Substack's open `/api/v1/free` endpoint. **No API key, no Beehiiv, no backend wiring** — Substack accepts unauthed POSTs from any origin (same trick Lenny's, Stratechery, Pirate Wires use). `/api/subscribe` rewrote from the legacy Beehiiv proxy. Three-state form (idle/submitting/success/error). Verified end-to-end on both local and live: empty email → 400, valid format → 200 `{success:true}`. Brian to spot-check the visual + that confirmation emails actually land. Beehiiv env vars in Vercel are now dead weight (safe to delete, no rush).

---

## May 3, 2026 — TNB Website: Latest Episode YouTube embed now skips Shorts

`/api/latest-video` was returning the first video from the channel RSS without filtering, which could be a Short. Fix: iterate IDs and HEAD-check `youtube.com/shorts/{id}` with `redirect: follow`; if the URL still resolves to `/shorts/`, skip it. First long-form video wins. No homepage code changes; cache stays at 1h.

---

## May 2, 2026 (evening) — TNB Glossary: mobile fixes + SEO structured data shipped. Final session for the day

Two parallel passes on top of the new familiarity tiers. (1) **Mobile fix**: homepage and per-term page nav at <768px were hiding *all* nav links (no hamburger fallback) so mobile users had no path to /glossary. Added `nav-link-primary` (Glossary, stays visible) + `nav-link-secondary` (YT/LinkedIn/Contact, hidden on mobile, still in footer). Glossary controls restructured at <600px to stack into 3 clean rows (search / sort+pill grouped via `display: contents` trick / Suggest); per-term article controls also stack. (2) **SEO** — pure metadata, no body copy changes. JSON-LD structured data on every page: `DefinedTerm` per term page (with `inDefinedTermSet`, `alternateName` from aliases, `isRelatedTo`), `BreadcrumbList`, `DefinedTermSet` on the index listing all 287 terms with URLs. Twitter card metadata, canonical URLs, OG `article:published/modified_time` from `dateAdded`, keywords from aliases. Highest-leverage SEO addition: tells Google "this page IS a definition" — eligible for definition rich results and knowledge panel ingestion.

---

## May 2, 2026 (PM-late, second pass) — TNB Glossary: familiarity recalibration. 287 terms re-tagged with thirds-anchored Beginner/Builder/Engineer rubric

Original cron's familiarity bar was builder-anchored ("Common = most builders know it") — produced 87 Common terms, half engineer-flavored (cursor, function-calling, model-weights, ai-engineer). The "Hide expert-only" toggle was filtering wrong layer. Built `scripts/glossary-retag.mjs` + workflow for two-step propose/apply recalibration. First pass with "mainstream press" rubric gave only 15 Common — too thin. Second pass with "what would a curious non-tech reader encounter in AI-moment discourse?" rubric gave 126 Common — overshot. Manual cleanup demoted 20 obvious miscalls (token, temperature, weights, transformer, rlhf, etc.) for **final 106 / 140 / 41** distribution. **Toggle behavior changed**: "Hide expert-only" now hides Builder + Engineer tiers (not just Specialist) → toggle on shows 106 Beginner-tier terms. **Search universalized**: filter only governs browse; search hits all 287 regardless. Cron prompt updated with same v2 rubric so future weekly terms tag automatically. ~$2 in Anthropic credits.

---

## May 2, 2026 (PM-late) — TNB Glossary: search-on-detail-page + Suggest a term feature shipped

Added two reader-feedback / discoverability upgrades on top of the 287-term steady state. (1) `SearchAutocomplete` component — 240px input with magnifier icon at the top of every per-term page, with live dropdown of matches (term + alias) and full keyboard nav. (2) `SuggestPanel` component — "+ Suggest a term" pill button at the right edge of the controls row on both the index and per-term pages; click reveals an inline form (Term required, Why? optional). Submissions hit a new `/api/suggest-term` route that forwards to brain-inbox `/api/send-email`. **Recipient:** initial spec was `admin@thenewbuilder.ai` but that didn't deliver (no mailbox/forwarding on the .ai domain yet) — flipped to `brhnyc1970@gmail.com` (To) + `nico@humbleconviction.com` (CC). Single-line flip-back if admin@ ever gets configured. Approval flow: email lands → Brian/Nico decide → in any future Claude session say *"add X to glossary"* → Claude appends to `scripts/manual-terms.txt`, pushes, next weekly cron picks it up. No admin dashboard. Verified end-to-end.

---

## May 2, 2026 (PM) — TNB Glossary topic-depth × 7 complete. Final corpus: 287 terms

Brian added $25 Anthropic credits and all 7 topic-depth passes ran successfully (Roles & Org +22, Business Models +22, Infrastructure +23, Patterns & Practices +22, AI Models & Capabilities +22, Agents & Automation +21, Builder Tools +20). Total topic-depth additions: +152. Self-audit removed `agent-loop` duplicate (`agentic-loop` already had "agent loop" as alias). Distribution now balanced — all 7 topics in the 25-54 range, no anemic buckets. Voice consistent. Glossary is in a strong steady state; weekly cron will maintain it from here. ~$5-7 in Anthropic credits spent. Anthropic API key rotation still recommended.

---

## May 2, 2026 (AM) — TNB Glossary corpus expanded 42 → 136 + multi-mode cron infrastructure

Added 4 new workflow modes to glossary cron: `manual` (file-based deterministic queue at `scripts/manual-terms.txt`), `gap-audit` (adversarial completeness check), `topic-depth` (per-topic forcing function), `source-scan` (deterministic source-aggregator polling — GitHub Trending, HN, Product Hunt, AI publication coverage). Refactored `weekly` mode to use multi-vector discovery prompt. Source-scan added 42 terms (Cursor, Windsurf, Zed, Claude Code, MCP servers, Ollama, etc.); gap-audit added 52 (Claude Skills, Claude Artifacts, NotebookLM, Custom GPTs, Project Astra/Mariner, Llama 4, Devin, Aider, etc.); manual fill added OpenClaw; self-audit removed `moe` duplicate. Per-term page UX iterated: prominent "← Back to glossary" at top of article, clickable topic chip in meta strip filters the index.

---

## May 1, 2026 — TNB Dynamic Glossary shipped end-to-end

New feature on thenewbuilder.ai/glossary. 42 bootstrap terms generated by an Anthropic-backed weekly cron with web-search grounding. SSG index page (browse-first card grid, search/sort/topic-filter, mobile responsive) + per-term article pages with glossary-term auto-linking + sitemap. Cron lives in `.github/workflows/glossary-cron.yml` (Mondays 13:00 UTC + manual workflow_dispatch). New homepage discoverability: nav link, CTA band between 6-card grid and YouTube embed, footer link. Locked spec captured in `tnb-website/BUILD-SPEC.md` (5 tracks, all decisions logged). Failure notifications wired to brain-inbox `/api/handoff-notify` (recipient: nico). Pending: Brian's content-completeness audit of the bootstrap corpus; Anthropic API key rotation (was exposed during chat setup). The `cowork` PAT scope was updated to include `workflow` so future GitHub Actions edits push from Cowork without intervention.

---

## April 30, 2026 — TNB favicon shipped

Replaced default Next.js favicon on thenewbuilder.ai with `src/app/icon.svg` — 5x5 orange grid mark, two-shade checkerboard (#EE7C2A / #B0431F), 30x30 viewBox. Old `favicon.ico` removed. Live and verified. Note: SVG is a recreation from a screenshot Brian shared — backlogged to swap with canonical source asset when available. Also updated tnb-website master entry: GitHub repo transfer complete (now `brhecht/tnb-website`, auto-deploys from main).

---

## April 29, 2026 — TNB content vault reorganized + skills updated

`tnb-strategy/` repo restructured into subdirectories (`strategy/`, `brand/`, `drafts/`, `ops/`) with new `README.md` index at root. New `brand/tnb-deck.md` is a markdown export of the April 13 Drive strategy deck — gives any session LLM-readable access to the canonical TNB articulation without needing Drive auth. `create-content` skill (v1.1.0) now brand-aware: when working on TNB content, auto-loads `brand/POSITIONING-LANGUAGE.md` + `brand/tnb-deck.md` alongside cross-brand voice DNA. Also fixed stale guidance — YouTube transcripts ARE available via Content Calendar API (`transcript` field on `yt-video`/`yt-short` cards). `tnb-strategy` skill (v1.1.0) updated with new paths. **Skill drift will be flagged on devices** until reinstalled. See "TNB Strategy" section below for full new structure.

---

## April 24, 2026 — UX Standards doc moved into bhub

Canonical B-Suite UX reference (modals, toasts, inline edit, DnD, nav, responsive, design system, keyboard shortcuts, data patterns, messaging) is now at `bhub/UX-STANDARDS.md` with an HTML viewer at `bhub/ux-standards-view.html`. Previously lived loose at `Developer/ux-standards-review.html` (deleted). PM briefs reference this doc as the source of truth for cross-app UX — deviations require Brian's approval. See "Cross-Project Dependencies" and "UX Standards" sections below.

---

## April 22, 2026 — B Hub rebranded + TNB announcement newsletter drafted

B Hub homepage copy updated: all "Humble Conviction" references replaced with "The New Builder" (topbar, hero subtext, BPIs card, footer). Hero subtext now reads "powering The New Builder. From content planning to project management." Deployed and verified live at b-hub-liard.vercel.app. TNB announcement newsletter (HC → TNB pivot) fully drafted in `tnb-strategy/NEWSLETTER-ANNOUNCEMENT-DRAFT.md` — ~610 words, pending Brian's final review before publish to Beehiiv/Substack.

---

## April 21, 2026 — Builder Bot briefed and approved

New standalone repo `brhecht/builder-bot` created. PM brief approved for daily Slack recap bot for The New Builder community workspace. Posts weekday 9:30am ET to #daily-recap-bot. Reads #introduce-yourself, #share-and-discuss, #what-im-building, #general. Claude-curated editorial summaries, cumulative lookback per channel via Vercel KV, carry-forward intro logic. Nico notified via Brain Inbox + env vars DMed. See `builder-bot/PM-BRIEF-builder-bot.md`.

---

## April 21, 2026 (pm) — Recap scope rule added

New "Status Recap Rules" section below: Claude status recaps stay in the tech/Cowork lane only. Business to-dos (War Room, podcast, content) live in B Things, not in handoff recaps. Also deleted orphaned `PM-BRIEF-hc-website.md` from Developer root (pre-TNB-pivot spec, superseded).

---

## April 21, 2026 — Mid-week status sync

Newsletter platform decision: **switching from Beehiiv to Substack next week.** TNB website Beehiiv env vars are NOT being added — subscribe form stays inert until the Substack swap. Live traffic to thenewbuilder.ai is effectively zero right now; Nico is catching any strays via a Google Form. **Podcast:** Ep 1 (Scott Werner) shipped Apr 14; Ep 2 (Davida Ginter) recorded, drops Apr 22. **War Room one-shot group tests:** picking participants deferred to week of Apr 27 (was Apr 21). **bhealth:** iMac audit still pending — encountering "workspace setup" issues that need to be unblocked before bhealth can run there. Mini, Pro, Air all clean.

---

## April 18, 2026 — Fleet audit infrastructure + cross-device cleanup

Built `bhealth.sh` (in bhub) — per-Mac fleet audit with three-tier healing (auto-heal / launch-and-prompt / flag). Parallelized `bsync.sh` to v2.2 (14 repos cloned concurrently, ~40% faster handoff-here). Audited Mac Mini, MacBook Pro, MacBook Air — all fleet-ready after cleaning ~5 weeks of ghost drift (local working-tree state left behind from pre-migration). Added two new master handoff sections: **Notification Routing Rules** (Brain Inbox is Nico's domain — Brian's reminders → B Things) and **bhealth — Fleet Audit Playbook** (workflow for any Claude session to triage future audits). Corrected device roles: Mini/iMac are primaries (home/office), MacBook Pro is the always-carry travel companion, Air is light travel only. Scheduled `weekly-fleet-audit-check` (Mondays 8am ET) that posts staleness summary to B Things. iMac audit pending next office visit.

---

## April 14, 2026 — B Content UX overhaul + direct email + B Hub cleanup

Rich text editing on all Content Calendar body fields, Enter-to-save+close keyboard shortcut (with ⌘+Enter), mobile responsive CardModal, Ghost + Hold views with shared StatusListView, dateless card warning. ⌘+Enter and button Enter prevention ported to B Things. B Hub: renamed B Eddy → B Projects, swapped card positions, trimmed app switcher to 4 apps. Brain-inbox: new `api/send-email.js` endpoint for direct Gmail sends via SMTP (Nodemailer). Comms skill updated to send emails directly instead of creating drafts. Dev-deploy skill updated with Claude in Chrome mandate and mobile-responsive coding rules.

---

## April 15, 2026 — TNB website design approved + repo architecture cleaned up

TNB homepage fully designed with Brian: hero (photo left, tagline right), story section, "Builders Figuring it Out. Together." 3x2 product grid (Podcast, YouTube, Newsletter, War Room, Meetups, Curated Events), YouTube embed, newsletter subscribe, bio. TNB website separated into its own repo (`brhecht/tnb-website`, to be created) from the `tnb-coming-soon` branch of `hc-website`. hc-website documented with HANDOFF.md for first time. Both repos added to bsync and master handoff. Nico brief packaged for implementation. bsync.sh updated to v2.1 with both new repos.

---

## April 12-13, 2026 — TNB positioning locked

All TNB positioning language locked in standalone `tnb-strategy/POSITIONING-LANGUAGE.md` (tagline, one-liners, cocktail party, written version, style rules, brand architecture). Source strategy docs archived in tnb-strategy/source-docs/. See `tnb-strategy/POSITIONING-LANGUAGE.md`.

---

## April 11, 2026 — Eddy killed + TNB strategy check-in

Eddy unit economics evaluated: profitability highly unrealistic at any price point. Recommendation: finish Week 2 checkpoint April 14, shut down paid ads, keep quiz as free organic tool, do not record the course. Full analysis: `hc-funnel/research/eddy-unit-economics-april-2026.md`. TNB Phase 1 in progress: podcast ep 1 dropping April 14 (Scott Werner/Sublayer), MVHH 2.0 done (~30 founders), LinkedIn rhythm strong. War Room format shifted to one-shot group tests starting ~April 21. Strategy docs updated with Week 1 actuals and revised 5-week timeline. See `tnb-strategy/STRATEGY-CONTEXT.md`.

---

## March 20, 2026 — HC Funnel pre-launch

Action plan email pipeline fully wired: quiz → email capture → Firestore + Kit + Claude-generated personalized action plan via Resend. Meta Pixel installed. Ad launch target: week of March 23. Kit nurture drip postponed (no course yet). All B-Suite repos now at `~/Developer/B-Suite/` on MacBook Pro (moved from Desktop March 12). Full Nico spec committed: `hc-funnel/NICO-SPEC-ACTION-PLAN-LAUNCH.md`.

---

## **March 9, 2026 — iCloud Sync Recovery + Two-Way Messaging:** MacBook Pro recove

**March 9, 2026 — iCloud Sync Recovery + Two-Way Messaging:** MacBook Pro recovered from iCloud sync deadlock. Two-way messaging now live in B Things: @brian and @nico both route notifications correctly. Nico can create tasks for Brian from Slack using `--notes` flag.
