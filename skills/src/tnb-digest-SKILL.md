---
name: tnb-digest
description: "TNB Slack Weekly Community Digest — a manually-triggered, two-phase editorial pipeline for The New Builder community Slack. PHASE 1 ('/tnb-digest', 'run my TNB digest', 'weekly TNB digest', 'what's worth surfacing from Slack'): reads the last 7 days across the 5 TNB community channels, filters noise, and produces a categorized, NUMBERED list of the most newsletter-worthy conversations — presented inline in Cowork for Brian to pick from, plus an emailed record + Slack DM confirmation. PHASE 2 ('render 2,5,7', 'draft these', 'turn those picks into narrative'): takes Brian's picked item numbers and produces raw narrative paragraphs + flagged expansion angles in a markdown draft — low-voice, NOT create-content. Also use this skill when Brian wants to tune the digest's editorial filter, add/remove channels, or adjust the format. Private to Brian; never posts anything community-facing."
---

# TNB Weekly Community Digest

You are producing a **private weekly editorial brief** for Brian Hecht from The New Builder (TNB) community Slack (`the-new-builder.slack.com`). The job is to surface the conversations, builds, and wins from the last 7 days that are worth turning into newsletter / LinkedIn / other content — and then, on request, to render the ones he picks into draft narrative he can finish.

This is a **two-phase, manually-triggered** pipeline. It is read-only on Slack and never posts anything community-facing.

- **Phase 1 — The Digest.** Read → filter → categorize → present a numbered, pickable list (the selection surface). Also send an emailed record + a DM confirmation.
- **Phase 2 — The Render.** Brian replies with the numbers he wants. You turn those picks into raw narrative paragraphs + expansion angles in a markdown draft.

**Core principle: selection is the judgment, prose is mechanical.** The high-value human act is Brian deciding *which* items matter and in *what* order. Phase 1 exists to make that pick fast and well-informed. Do not auto-write narrative in Phase 1 — wait for the pick.

---

## Prerequisites & Infrastructure

- **Slack read access:** the first-party Slack connector (`mcp.slack.com`), connected to `the-new-builder` workspace. Tools: `slack_read_channel`, `slack_read_thread`, `slack_search_channels`, `slack_search_users`. If a tool isn't loaded, fetch it via ToolSearch. If Slack returns auth errors, tell Brian to reconnect the Slack connector — do not try to read Slack any other way.
- **Email (record copy):** uses the `comms` skill's email pattern — create a Gmail draft in Brian's account with the auto-send marker `<!--CLAUDE-AUTO-SEND-V1-->` as the first line of the HTML body, To: `brhnyc1970@gmail.com`. It auto-sends within ~5 min.
- **DM confirmation:** POST to `https://brain-inbox-six.vercel.app/api/handoff-notify` (Content-Type: `text/plain`, body JSON-stringified) with `{"project":"TNB Digest","summary":"<confirmation>","recipient":"brhnyc1970@gmail.com","recipientSlackId":"U096WPV71KK","dmOnly":true}`.

### Channel Registry (TNB community, `the-new-builder`)

| Channel | ID | Role |
|---------|-----|------|
| #general | C0AQ7E7DEQM | announcements, events, milestones, kudos |
| #share-and-discuss | C0AQJTEV3J7 | articles, ideas, debate — the editorial spine |
| #shipped | C0B6E1YAXB5 | daily/weekly ship logs |
| #show-me-love | C0B0103K5PA | "amplify my social post" requests (signal, not items — see filters) |
| #what-im-building | C0ATE9CDJTA | works-in-progress, build show-and-tell |

If channel IDs ever fail, re-resolve with `slack_search_channels` (query the bare channel name).

---

## PHASE 1 — The Digest

### Step 1 — Pull 7 days from all 5 channels

Compute the window: `oldest` = (now − 7 days) as a unix epoch (use bash `date -d '7 days ago' +%s`). Call `slack_read_channel` for each channel ID with `oldest=<epoch>`, `limit=100`. If a channel returns a `next_cursor` (more than 100 messages in 7 days — rare), paginate until the window is covered.

The response already includes, per message: author name + user ID, message ts, text (with channel/user mentions resolved), `Reactions: name (count)`, `Thread: N replies (latest: …)`, and file attachments. **You do not need `slack_search_users` for replier names in most cases — names come inline.** Use it only to resolve a name that appears as a raw `Uxxxx` ID.

### Step 2 — Read the hot threads

For any message flagged `Thread: N replies` with **N ≥ 2** that is a candidate for the digest, call `slack_read_thread` (channel_id + parent message_ts) to capture the actual replies and replier names. This is what powers honest "X replied that…" summaries and hot-thread ranking. Don't read every thread — only ones you're likely to surface.

### Step 3 — Filters (apply before selection)

**Hard excludes (never sources):**
- **Builder Bot (`B0AUUVD4L8M`) posts.** These are the *daily* "Top Conversations" recap from Nico's separate pipeline — derived meta, not source conversation. Ignore them entirely. (They're useful only as a cross-check that you haven't missed a thread.)
- System/join messages, bot status posts.

**Down-rank / route to ALSO CONSIDER (rarely RECOMMENDED):**
- Pure logistics & ops noise: scheduling availability ("I'm free Tue/Wed"), "I'll be there at 4:30," RSVP counts, swag/sticker tangents. The *enthusiasm* around an event can be a story; the *logistics* are not.
- `#show-me-love` is almost entirely "please like my LinkedIn post" requests. **Do not surface individual amplification asks as items.** Read the channel as a *signal* of what the community is rallying behind, and only mention it if a specific post is generating real, notable engagement.

**Own-posts rule:** Brian's own posts are eligible — especially genuine milestones (e.g. "first two premium members"). But down-weight them: the digest is a read on the *community*, not a mirror of Brian's week. Don't let more than ~1–2 of his own posts lead.

### Step 4 — Editorial selection (the brain)

**The bar:** *Would this make a non-member want access to the room?* Favor concrete wins, real builds, and honest/sharp takes over meta-discussion or ops noise. Rank candidate threads by reply count + reaction count + recency, but quality clears before count.

**The "why it's newsletter-worthy" test** — every RECOMMENDED item must have a real answer to one of:
- It's a tangible build/tool someone would want to use or copy.
- It's a sharp, quotable idea or honest take that illuminates where building is going.
- It's proof the community is working (a win, a milestone, a ritual, real warmth).
- It's third-party validation of the TNB thesis ("the builder is the role to have").

### Step 5 — Categorize, number, and format

Group RECOMMENDED into these buckets (omit any bucket that's empty — graceful, no placeholders):

- 🔨 **Builds & Shipped Work**
- 💡 **Conversations Worth Amplifying**
- ❤️ **Community Wins & Social Proof**
- 🔥 **Hot Threads**

Then a flat **ALSO CONSIDER** tail for borderline items worth a glance.

**Volume (tight beats bloated — wall-of-text is the #1 failure mode):**
- RECOMMENDED: aim **5–8 items**, hard quality floor. On a quiet week, fewer is correct — never pad.
- ALSO CONSIDER: **3–6 items**.

**Number every item sequentially across the whole digest (1, 2, 3 …), regardless of bucket**, so Brian can pick by number in Phase 2.

**Per-item format:**
```
N. **Headline** (#channel) — One- to two-sentence neutral summary. When citing replies, NAME the replier ("Scott Werner replied that…"); collapse similar repliers into one sentence naming all. *Why:* one line on why it's newsletter-worthy. [link](permalink)
```

**Naming & tone rules (carried from the daily-recap v2 spec — non-negotiable):**
- Always name post authors and repliers by Slack display name. **Never** write "one user noted," "a reply pushed it further," or any anonymous framing. If a replier's name can't be resolved, drop the reply sentence rather than write an anonymous one.
- Neutral and factual. **Banned:** "says he's…," "claims to be…," "supposedly," "the kind of person who…" — never editorialize about authenticity, motive, or vibe.
- Tight noun-verb prose. Cut adjectives that don't carry information.
- **Plain-language first, jargon in parentheses.** The audience is AI-conversant but **non-technical**. Never lead with a technical product, tool, framework, CLI, or feature name on first reference. Describe what the thing *does*, then put the name in parentheses. Write "a tool that scans a whole codebase for accidentally committed passwords and API keys (TruffleHog)" — not "a TruffleHog scanner." Same for things like `/goal`, Antigravity, Codex, MCP, etc.: explain the function, name it second.

**Permalink construction (no extra API call needed):**
`https://the-new-builder.slack.com/archives/{CHANNEL_ID}/p{ts}` where `{ts}` is the message ts with the decimal point removed (e.g. ts `1780969615.908419` → `p1780969615908419`).

### Step 6 — Present inline (primary surface)

Output the full numbered digest directly in the Cowork chat. This is the working surface Brian picks from. Lead with a one-line header: `**TNB Weekly Digest — {Mon D}–{Mon D}** · {X} recommended, {Y} to consider`.

### Step 7 — Deliver the record copy (email + DM)

By default, also:
1. **Email:** create a Gmail draft (auto-send marker, To: brhnyc1970@gmail.com) containing the same numbered digest, subject `TNB Weekly Digest — {date range} · {X} recommended, {Y} to consider`. HTML, with working permalink anchors.
2. **DM:** send the confirmation via handoff-notify dmOnly: `"TNB digest ready — {X} recommended, {Y} to consider. Picks open in Cowork."`

If Brian says "skip email" / "no email" on a run, suppress both and present inline only. (If he wants this to be the permanent default, update this step.)

### Step 8 — Offer Phase 2

End the inline output with: *"Reply `render 2,5,7` to turn picks into draft narrative + angles — or we're done here."*

---

## PHASE 2 — The Render (topic seeds + raw narrative)

**Trigger:** Brian replies with item numbers — `render 2,5,7`, `draft 2 5 7`, "do those," etc.

**Goal:** turn his picks into a *thinking input*, not a finished piece — raw narrative he can react to, plus angles to expand. **Low voice.**

### Steps
1. For each picked number, pull full context — re-read the source message and its thread (`slack_read_thread`) for any quotes or detail you didn't capture in Phase 1.
2. Produce a markdown draft with three parts:
   - **Throughline (1 short paragraph):** the connective thread that ties the picks together — what this week's selections, taken together, say about where building / the TNB community is going. Light editorial spine, not a hot take.
   - **Per pick (1–2 narrative paragraphs each):** clean, readable, reader-facing draft prose summarizing the item with enough substance to stand alone. Neutral-warm observer voice.
   - **Angles to expand (2–3 bullets per pick or grouped):** concrete hooks Brian could develop into his own take — questions, tensions, contrarian readings, "the bigger pattern here is…" prompts. Where his personal opinion belongs, mark it `[Brian's take: …]` rather than inventing one.

### Voice guardrails (critical)
- **Do NOT imitate Brian's first-person voice or fabricate his opinions.** This is draft raw material, not a finished Brian piece.
- Write in clean observer prose. Pull framing vocabulary from TNB positioning (relationship-led community, "the new builder," builders as the emerging role) but don't overreach or sloganeer.
- **Plain-language first, jargon in parentheses (same rule as Phase 1).** Non-technical-but-AI-conversant audience. Lead with what a tool/feature does, then name it in parentheses on first reference — "a tool that finds secrets accidentally committed to a codebase (TruffleHog)," never "a TruffleHog scanner." This matters more in the narrative render than anywhere else.
- **This is not `create-content`.** If Brian wants to develop a single pick into a full, voice-driven essay or LinkedIn post, that's a deliberate, separate hand-off to the `create-content` skill — say so and stop.

### Output
Write the draft to the user's folder as `TNB-Digest-Draft-{YYYY-MM-DD}.md` and present it with `present_files`. Keep a short summary in chat.

---

## Edge Cases
- **Quiet week / sparse channel:** if a channel has no notable activity, skip it silently (no "nothing here" line). If the whole week is thin, deliver fewer items and say so plainly — never pad to hit a count.
- **Unresolvable replier name:** drop the reply sentence; never write an anonymous one.
- **Thread with many replies but low substance:** reaction/reply count is a signal, not a mandate — a 15-reply scheduling thread is still ops noise.
- **Slack auth failure:** stop and tell Brian to reconnect the Slack connector. Do not attempt any other read path.
- **Brian re-runs Phase 1 same day:** that's fine; it's idempotent and read-only.

## Maintenance
- Channels and IDs live in the registry table above. To add/remove a channel, edit that table.
- Workspace: `the-new-builder.slack.com`. Brian's Slack ID: `U096WPV71KK`. Builder Bot (exclude): `B0AUUVD4L8M`.
- This skill is intentionally manual — no cron, no scheduling. Phase 1 and Phase 2 are separate turns in a Cowork session.
