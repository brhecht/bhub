---
name: priority-agenda
description: "Opens, rebuilds and re-ranks Brian's Priority Agenda, and refreshes the panel that shows it. Triggers on '/priority-agenda', 'my agenda', 'my priorities', 'priority agenda', 'open my agenda', 'what is my day look like', 'rebuild my priorities', 're-rank my day', 'update my agenda', 'refresh panel', 'reload the panel', 'show me the panel', or any request to see or change his ranked list of what he is working on. The agenda lives in the Linear document 'Brian's priority agenda' (Team Ops, doc id 4aa0b7df0286); the panel reads that document live and has its own Refresh button, so a content change needs no republish. Covers The New Builder and TNB CRM teams only, never the private Athena team. NOT the morning brief (that is `morning`) and NOT a plain Linear issue list."
---

# Priority Agenda

Brian's ranked agenda for the day, rendered in the Cowork side panel.

## This skill is process, not business strategy

Read this first, because it is the rule this skill breaks most often.

**The job is to keep the list accurate and correctly ordered. That is all of it.** Not to assess whether Brian will hit a goal, not to point out tension between his decisions, not to say what a pattern of behaviour suggests, not to weigh in on the business.

**This binds chat replies exactly as hard as it binds the document.** Writing the ban into the document and then delivering the same commentary in the reply is the same violation. Brian has corrected this repeatedly. A paragraph opening with "one thing to name", "worth deciding", "the tension here" or anything of that shape does not belong in a priority-agenda turn, however well argued.

He has other skills for that and he invokes them by name: `grill-me` to stress-test a decision, `tnb-strategy` for the business, `slate` for options. At most, this skill offers in one sentence to look at something in the right skill, and only when he has not just asked for a confirmation. When in doubt, leave it out.

**Report only what changes what he does.** A reply says what changed on the list and what is now first. It does not report which email address something was sent from, which of two similar links was used, formatting details, how many tool calls it took, or anything else that is true but does not alter his next action. Brian calls this nitpicking and he is right: it buries the answer he asked for.

**Match the reply to the ask.** "Update please", "confirm", "did that go through" get one to three lines. A rebuild gets two or three. Nothing here warrants an essay.

## When Brian says something changed, re-rank

When Brian reports that he sent, called, replied, emailed or finished something, his statement is authoritative. Act on it immediately; do not verify first and do not leave the item ranked pending a check.

**Three things happen in the same turn, always:**

1. Close the issue in Linear.
2. Move the CRM card to the stage that now matches.
3. **Re-rank.** The item leaves its numbered position, everything below moves up, and it lands in Cleared today, in Waiting on a reply, or both.

Step 3 is the one that gets skipped. Editing an item's body line to describe the new status while leaving it at rank 1 is a failure, not a partial fix: Brian refreshes, sees the finished thing still at the top of his day, and has to correct you. **If the work is done, the number is gone.**

**A task can be complete even when the relationship is not.** "Email X and schedule a chat" is finished when the email is sent, whatever X does next. Close it and put the outstanding piece in Waiting on a reply with its own dated follow-up. Never keep a done task ranked as a proxy for an open thread.

If he says a status changed and you cannot see how, ask in one line. Do not silently rank it as though nothing happened.

## Surface the panel every time, unprompted

Every reply that answers what Brian is working on, his priorities, or his agenda, includes the panel's link so he can open it himself: **https://claude.ai/code/artifact/10c87103-5daf-489e-a883-93275fe73ae0**

He should never have to separately say "show me the panel" after asking about his priorities. That request is exactly what this rule exists to remove. Giving him the link costs nothing and needs no tool call and no permission prompt.

This does not mean republishing. Republishing the artifact and linking to it are different things. See "The panel is live" below. Link to the existing URL every time.

## Scope, and the firewall

This agenda covers TNB work only: the `The New Builder` and `TNB CRM` teams in Linear.

**The private `Athena` team is out of scope, always.** Athena is Brian's own list and Nico must never see it.

- Never read the `Athena` team when building, rebuilding, or refreshing this agenda.
- Never write an Athena issue, identifier, title, or any detail from one into the agenda document.
- Every `list_issues` call this skill makes must name a team explicitly. Never call `list_issues` with only `assignee: "me"`, because that sweeps the whole workspace and picks up Athena.
- The same rule binds the published page. Every `list_issues` the panel itself runs is team-scoped. A bare assignee filter in the page would put Athena titles in a view Nico can read.
- Unassigned Athena issues are not protection. The exclusion is by team, not by whether an assignee happens to be set.
- If Brian asks to see Athena items and TNB items together, say the two are firewalled and ask him to lift it for that one request. Do not merge them on your own.

This holds until Brian explicitly says otherwise. He lifts it per request or sets a new rule; nothing else changes it.

## What this is, and the hard rule

This is an intelligent, lightly annotated to-do and project management list. Ranked items for the day, plus Blocked by Nico, Call sheet, Waiting on a reply, Cleared today, Cleared yesterday, Calendar today, Decisions waiting, Known open, Optional, and Reference. That is the entire job.

**Annotate with adjacent facts only.** A body line under an item exists to save Brian or Nico a lookup: current status, the real date, what the item depends on, who is waiting on whom, what changed. Nothing else belongs there.

**No editorializing, in the document or in chat.** See the first section. Never write judgment, diagnosis, prediction, ultimatums, or pattern-calling. Concretely, never write copy like:

- "TNB-46, TNB-145 and TNB-121 have all been canceled in twelve days with no recording booked. Either a guest and a date land by Friday or the format pauses through September."
- "A goal with no started mechanism is a wish."
- "You just put a call gate in front of the four people who could get you to 80 by Friday."
- Counts of how many times something has slipped, or what that says about Brian.

**Do not name repeat cancellations** unless the cancellation is directly relevant to the task being ranked, for example a task that was folded into another one.

**Do not add standing rules on your own.** Re-ranking, reordering, marking something in progress, and moving items between sections are working updates, not rule changes. Only edit this skill when Brian explicitly says to make something a rule.

**Do not comment on how Brian spends his time.**

## Open with the list. Reference material goes below

**The dated section starts with rank 1.** No preamble, no build narrative, no restatement of what the pipeline is, no member counts, no calendar block above the ranking. Brian opens this panel to see what to do next, and every line above rank 1 pushes that down the screen.

Everything that used to sit up top now has a home lower down:

- Member counts, the current goal, the office hours link and its details, and the one-line note on how the build was made all go in `### Reference` at the very bottom.
- The day's schedule goes in `### Calendar today, UK time`, below the cleared sections.
- Per-item context, including CRM stage and what a prospect is building, belongs in that item's own body line, not in a paragraph above the ranking.

**One exception.** A single line may sit above rank 1 when something is urgent, dated today, and needs Brian to act outside the ranked list. A calendar conflict happening this afternoon qualifies. A member count does not, a build note does not, and an explanation of how a section works never does. One line, one fact, then rank 1. If nothing meets that bar, the dated header is followed immediately by rank 1.

**Never use markdown link syntax in this document.** The renderer does not parse it and prints `[text](<url>)` on screen verbatim, which is what Brian sees. Write bare URLs and bare email addresses instead: `https://calendar.app.google/hwHqM6Pv3SiouX3DA`, not a bracketed link. Linear's own issue-code linkification is fine and happens on save; that is different and does not need markdown.

## Name first, code in parentheses

**Never refer to an issue by its identifier alone.** Every mention, everywhere, is the name followed by the code in parentheses: `Write Thursday's LinkedIn post (TNB-258)`. Not `TNB-258`, and not `TNB-258, write Thursday's post`.

This holds in the agenda document, in the panel, in every banner, and in every chat reply to Brian. He reads this at a glance and must never have to remember what a number means or open Linear to find out.

The only place a bare code is acceptable is inside a link's own text where the name already sits immediately beside it in the same sentence.

**All money amounts are in US dollars.** Nico is paid in USD. Never write an amount in pounds, and never leave a figure unmarked: `USD 150`.

**Every line carries its issue code, or it is invisible.** The drift check matches on the `TNB-xxx` link inside a line. A line written without one cannot be checked against Linear, so it silently survives after the work is done and Brian gets reminded of something he already finished. The Morning Brief often lists an item as a plain checkbox with no link; that is not evidence there is no issue. Search Linear by title before writing any line without a code, and if no issue exists, create one. A ranked line with no issue code is a defect, not a shortcut.

## Done means moved, never struck through

When something is finished it leaves the ranked list and appears under Cleared today. That is the only representation of done. There is no strikethrough state, there never was one in the spec, and nothing in this skill or the renderer may reintroduce one.

An issue closed in Linear that is still sitting in a ranked position, a sub-bullet, or the call sheet is not a done item. It is **drift**: the document is behind Linear. Drift is fixed, not styled. On any run of this skill, check for it and rebuild the document so those lines move to Cleared today. The renderer raises a banner for the same condition, because Brian can open the panel without running the skill, but a banner is a prompt to rebuild, never a way to show something as handled.

A struck-through line reads as handled. That is the wrong signal, and it is why this rule exists.

**Drift-check every issue named in the document, not just Brian's.** Blocked by Nico and some Call sheet lines are owned by Nico, not Brian, and Nico's issues never appear in an `assignee: "me"` result no matter how it is team-scoped. An `assignee: "me"` sweep alone will silently miss a closed Nico issue still sitting in a live position. Check those either with `get_issue` on each one by id, or one `list_issues` call per team with no `assignee` filter at all (still team-scoped, per the firewall above) and match ids against what is in the document. Do this before telling Brian anything above is current.

## Sent and waiting on a reply

When Brian sends something and the next move belongs to the other person, the task is done and the relationship is not. Closing the issue and saying nothing else loses the thread; leaving the issue open makes done mean two different things and corrupts the Cleared count he uses to read his day. Neither is right on its own.

So do all three of these, in the same turn:

1. **Close the original issue** and put it in Cleared today, exactly as any other finished task. "Email X an invitation" is complete when the email is sent.
2. **Add the person to `### Waiting on a reply`.** One entry each: the person's name with their CRM card code, their current stage, what was sent and when, anything the reply depends on, and the ping issue with its date. The CRM code is what makes the line drift-checkable, so never write an entry without one.
3. **Create a dated ping issue** for anyone in the membership pipeline, assigned to Brian, `state: "Todo"`, due on the ping date, parented to the Call sheet (TNB-179), project Member CRM. Title it as the action, for example "Ping Madhura Kumar if she has not replied". Its body carries what was sent, when, and what would make the ping unnecessary. It stays out of the ranking until its due date arrives, then surfaces as ranked work on its own.

The ping issue is what makes this work; the section alone is only a list Brian has to remember to read. Create one for every membership-pipeline follow-up, because a missed one costs a member. For anything outside the pipeline, the section entry alone is enough unless Brian says otherwise.

**Pick the ping date from how long the person has already waited, not a fixed interval.** Someone who first reached out days ago and has been waiting gets a short leash, two or three days. A fresh cold invitation gets four business days. Mark the date as ASSUMED when reporting it to Brian in chat, since it is your choice and not his.

An entry leaves this section when the person replies, when the thing they were going to do is done, or when Brian says to drop it. On reply, move the outcome into Cleared today and close the ping issue.

**Kill criterion Brian set for this notation:** if `Waiting on a reply` passes eight entries, or he starts ignoring ping issues when they surface as ranked work, the notation has failed and the replacement is a CRM stage-age sweep built by Nico, surfacing any card that has sat in one stage too long. Say so plainly if either happens; do not quietly keep adding entries.

## The two membership paths

Set by Brian on Sep 9, 2026. It changes what a ranked item means, so keep it straight.

- **Referred by a member.** Brian sends an invitation. Nico's Slack invite follows off the copy. The card goes to `2. Invited`.
- **Unsolicited application, no referrer.** Brian offers a call first. **No Slack invite until Brian explicitly says so, per person.** The card goes to `1. Reached Out`. This is Nico's standing rule in TNB-307; the invite keys off the card reaching `2. Invited`, never off a copied email.

Never describe an unsolicited applicant's email as an invitation, and never tell Nico to invite one.

## The panel is live. Refresh is a button in the page

**The panel reads Linear on demand.** It calls `get_document` when it opens and again every time Brian clicks **Refresh** in its header. A change to the Linear document is already a change to what the panel shows. Content reaches Brian without a publish.

**So never republish for a content change.** Re-ranking, closing an item, snoozing one, adding a call sheet entry, adding a Waiting on entry, rebuilding the whole day: none of these touch the page's code, and none of them need the Artifact tool.

**When a panel already open on his screen shows stale content, the fix is the Refresh button in the panel header.** He clicks it, the page re-reads Linear in place, the stamp updates to `read HH:MM`. He does not have to close and reopen the panel, and nothing has to be published. This is the answer every single time he says the panel is behind. Say it in one line and move on.

**Refresh re-reads, it does not re-rank.** Refresh picks up any change to the Linear document no matter who made it: Nico, Brian in the Linear web app, another Cowork session. What it cannot do is place work. A closed issue still ranked, a day-old ranking, or an issue created since the last rebuild all raise a banner instead. Fixing any of them takes a rebuild, which means running this skill. State that split plainly when he asks: **Refresh gets him the current document, a rebuild gets him a current ranking.**

**Why there is no built-in refresh notice.** The reload prompt Brian has seen on other artifacts is a republish notice: the app raises it when an artifact he has open receives a new published version. This panel is never republished for content, so that notice never appears. That is by design, not a fault, and the Refresh button exists because of it. Do not treat its absence as a bug and do not go looking for it again.

**Auto-open works the same way.** An artifact opens itself only when a publish happens in that turn, because it is the publish that puts the card in the conversation. No publish, no card, nothing opens. So a normal agenda turn hands him the link as text, and that is correct behaviour, not a failure. Do not publish just to make the panel open.

**Artifact reads are blocked in this account; `force: true` is the only publish path.** Brian's configuration carries a WebFetch deny rule that blocks artifact reads. A normal publish to an existing artifact has to read the current version first, so it is refused before it begins. Brian confirmed in Sep 2026 that he cannot change this rule and has already tried. `force: true` publishes without reading and works: proven on Sep 8, 2026, when the Refresh button and the missing-item banner shipped. Settled, not a problem to solve.

Consequences, all of them binding:

- Never reach for the Artifact tool to make the panel show current content. Refresh is the fix.
- Never propose that Brian change, remove, or narrow the deny rule. He cannot. Raising it again wastes his time and is the exact loop this section exists to end.
- Never spend tool calls rediscovering this. Do not attempt a plain republish "to see if it works."
- If the page's own HTML genuinely needs to change, for example a renderer fix or a new banner, say so plainly in chat and tell him it takes `force: true`, which overwrites the live version without reading it. Do not pass `force` unless he explicitly tells you to in that turn.
- Never tell him a republish updated the panel's content. It did not; the panel reads Linear.

**Read Linear before you present the list.** Other sessions, on other machines, close issues all day. The document is only as current as the last rebuild, so run the drift check (including the Nico-owned items above) on every turn that shows or changes the agenda, not just on a full rebuild. Anything closed since the last read moves to Cleared today before Brian sees it. Never present an item as open on the strength of the document alone.

**Order inside the turn:** run the drift check, change Linear, edit the document, then report in two or three lines, with the panel link per "Surface the panel every time" above. If he had the panel open, add the one line telling him to hit Refresh.

**Report what changed, not how it got there.** A turn that changes the agenda names the change in two or three lines. Do not narrate the publishing mechanism and do not explain how the panel works. He knows how his own panel works.

**Delivery.** The panel is an already-published Artifact living at the URL above, declaring the `mcp` capability for Linear (`get_document`, `list_issues`) and Google Calendar (`list_events`). It reads the Linear document itself, on open and on Refresh. It already exists; this skill does not rebuild or redeploy it in normal use.

**Check before you finish.** Confirm the Linear document saved. There is nothing else to confirm, because nothing else was published.

## Architecture

1. **The Linear document is the source of truth.** "Brian's priority agenda", doc id `4aa0b7df0286`, Team Ops project. It holds the ranked list and the wording. Nico reads the same document.
2. **The panel only renders it.** It stores nothing and is never edited to change content.
3. There is no third piece.

## Opening it

### Step 0: check the date first, always

Call `get_document` on `4aa0b7df0286` and compare its `## Today, <Day Mon D>` header to today's date.

- **Today.** Render it.
- **Past.** Stale. Rebuild for today per "Sources" and "Ranking" below, then render. Say how many days stale it was.
- **Future.** Deliberately built ahead. **Do not rebuild or overwrite.** Render it and say which day it covers.

Only a past date triggers a rebuild. This applies to every phrasing that asks to see the agenda, including bare `/priority-agenda`. The drift check does not cover this: it only flags closed issues, so a week-old document whose items are all open raises nothing. Only the header date tells you the ranking is current.

Exception: Brian asks for a past day, or says not to rebuild.

### If the page itself ever has to be rebuilt

This should be rare, and per the section above it needs Brian's explicit `force`. Reuse `renderer.html`'s stylesheet verbatim so it looks like the panel he knows, and its markup: `.item` cards with `.title` and `.body`, `.item.rank1` for rank 1, `ul.sub` for sub-bullets, `h3.cleared` and `h3.plain` for headings. Published as an Artifact the page carries no doctype, html, head or body tags of its own.

The bundled `renderer.html` calls `window.cowork.callMcpTool`, which does not exist in a published Artifact. A published page reaches connectors through the `mcp` capability instead: `await claude.use("mcp")`, then `mcp.callTool(server, tool, input)`, with `server` as the connector's display name ("Linear", "Google Calendar") and the result on `result.payload`. Port every data call or the panel loads empty. Resolve the capability once into a module-level variable, branch on `null` with a message pointing at the Linear document, and only then run the first load, because the grant resolves after the page's first script run.

**The live page is `renderer.html` plus four things it does not have.** Keep all four on any rebuild:

1. **The Refresh button.** In the header, beside the stamp: a `button.refresh` that calls the same `load()` the page runs on open, disabled and spinning while a load is in flight. The stamp reads `read HH:MM · doc updated <Mon D, h:mm>`, so Brian can see how fresh what he is looking at is.
2. **A `#banners` strip** at the top of the rendered output. All three checks append into it, so they never fight over insertion order.
3. **The stale-date banner.**
4. **The missing-item banner.**

All three checks are described under "Renderer changes" below.

## Renderer changes

`renderer.html` is the bundled reference implementation, and it is behind the live page: it predates the Refresh button and the missing-item banner, and it still calls `window.cowork.callMcpTool`. The live panel is the published Artifact built from it, ported to the `mcp` capability and extended as described above.

The page runs three checks, and each one covers a failure the others cannot see:

**1. Drift, an item here that is already closed.** Reads `.item > .title`, `.item ul.sub li` and `p.cs` only. It skips `.body` lines and the Cleared sections: a body line naming a closed issue as an adjacent fact is not drift, and scanning bodies raised a false banner on a correct agenda. It checks every issue id found in those elements against Linear regardless of assignee, so it already catches Nico-owned drift; it is the chat-side manual check (above) that must be told to do the same.

**2. A stale ranking.** Parses the date out of the `## Today, <Day Mon D>` header, compares it to the browser's date, and raises a banner when that day has passed. A future date is left alone. This catches what drift cannot see, a week-old ranking whose items are all still open.

**3. A missing item, work that is nowhere on the ranking.** Drift can only look at issues the document already names, so an issue created after the last rebuild is invisible to it: no line, no code, no banner. This closes that gap. It pulls Brian's own open issues with three team-scoped calls, `The New Builder` in unstarted and started states plus `TNB CRM`, and names anything whose code appears nowhere in the document. Unlike the drift check it scans the whole document text, body lines included: an item parked in Known open, in Waiting on a reply, or named as an adjacent fact is placed, not missing. Never widen these queries to a bare `assignee: "me"`; see the firewall above.

All three fail silently. If a lookup errors the agenda still renders.

## Sources to read before every rebuild

Read both, every time. The agenda is not a copy of either one.

1. **Linear, team-scoped.** Call `list_issues` once per in-scope team, open issues assigned to Brian:
   - `{ team: "The New Builder", assignee: "me", state: "unstarted" }` and the same for started states.
   - `{ team: "TNB CRM", assignee: "me" }`.

   Never a bare `{ assignee: "me" }` with no team. That sweeps Athena into the agenda. Move anything that closed or got canceled out of the ranked list and into the cleared section.

   These `assignee: "me"` calls find Brian's own open work, nothing more. They will never surface a Nico-owned issue, whether it is still open or already closed. For Blocked by Nico and any Call sheet line owned by Nico, check status separately: see "Drift-check every issue named in the document, not just Brian's" above.
2. **The day's Morning Brief.** Nico writes one every night as a Linear document in the Morning Brief project, titled "Morning Brief: YYYY-MM-DD, Day (No. N)". Find it with `get_project` on Morning Brief with `includeResources: true`, then `get_document` on the newest one. It routinely carries items Linear alone does not surface: approvals queued behind Nico, things Brian owes Nico, the member counts, calendar conflicts, and Nico's own day.

   **The brief is not redundant with Linear.** It regularly lists items assigned to Nico or unassigned that are in fact Brian's to send, and it carries facts that are not Linear issues at all: the member count against the goal, double-booked calendar slots, and what Nico shipped overnight. A Linear-only rebuild will silently drop these.

   If the brief for the target day does not exist yet, use the most recent one and say so in `### Reference`, naming its number and date.

**Incorporate the Morning Brief, do not transcribe it.** Its Today list is unranked and grouped by theme. Take its items, drop them into the ranking rules below alongside the Linear items, and let them land wherever they land. An item the brief lists first may rank fourth here, and that is correct. Note in `### Reference` that the build came from Linear plus the day's Morning Brief, re-ranked.

Carry these across from the brief when present: the headline member counts and current goal into `### Reference`, calendar conflicts that need Brian to act, items on Brian that Linear does not show as his, the "Run in parallel" item kept in its own section, and Nico's shipped list folded into Cleared yesterday.

When the two disagree on whether something is done, Linear wins on status and the brief wins on what Brian actually owes today.

**Check the mail before ranking any outreach item, every time.** A card titled "Email X" or "Schedule a chat with X" is not evidence the email is unsent. Linear and the Morning Brief both lag Brian's inbox by hours or days. Before ranking anything that involves contacting a person, search his sent mail and that person's thread: whether the email went, whether they replied, and whether Nico's Slack invite already landed. Brandie Knox (TNB-230) sat at rank 1 on Sep 9 as an unsent email when it had gone Aug 31, she had accepted Sep 1, and she had been in Slack since Sep 2. That is the failure this rule exists to prevent.

**Read the actual source when a prospect is ranked.** The Linear card and the Morning Brief both paraphrase. The application email at `admin@thenewbuilder.ai`, the Slack DM that carried a referral, and Brian's own sent mail hold facts neither one keeps: the referral field's real wording, what the person actually said they are building, what Brian already promised and when.

**Watch for supersedes and duplicates.** Nico's generators recreate cards: a recurring task can fire twice for the same day, and an issue Brian already has can be reissued under a new code with the original parked in Backlog rather than marked Duplicate. Rank the live one, name the superseded code in the body line as an adjacent fact, and tell Brian in chat which duplicates exist. Do not cancel or retire anything on your own; that is his call.

## Updating and re-ranking

Edit the Linear document with `save_document` on id `4aa0b7df0286`. Never edit the artifact to change content. The artifact only renders. The panel picks the change up the next time it opens or Brian clicks Refresh.

When Brian says he has finished something, follow "When Brian says something changed" above: close the issue, move the CRM card, and re-rank, all in the same turn. If the next move now belongs to someone else, also follow "Sent and waiting on a reply".

When Brian says he has started something, set that issue to In Progress in Linear with `save_issue`. The document and the issue tracker should agree.

**Move the CRM card too.** A membership task and its CRM card are two halves of one fact. The member count is computed from card stages, so a card left behind makes the count wrong. The stages are `0. Identified`, `1. Reached Out`, `2. Invited`, `3. Ping`, `4. Accepted`, `5. Introduced`, `6. Needs Attention`, `7. Active Member`, plus `No / Dropped` and `Duplicate`. A call offer moves a card to `1. Reached Out`; an invitation moves it to `2. Invited`. Do not guess past `2. Invited`: a person who has been emailed is Invited, not Accepted, until they say yes.

**Always set `state` explicitly when creating an issue.** Linear's default for a new issue on The New Builder is **Backlog**, and this skill's rebuild reads Todo and In Progress only. An issue created without a state is real work that silently never reaches the agenda. Any issue you create that is actual work, and certainly any issue with a due date, gets `state: "Todo"` in the same `save_issue` call. Never rely on the default.

Backlog stays out of the agenda deliberately: it is where Brian parks things he is not committing to. The fix for a missing item is always to correct the issue's state, never to widen the rebuild query to include Backlog. If something Brian expects is missing from the agenda, check its state first; a dated task sitting in Backlog is a creation error, not a reason to change what the agenda reads.

**Note on editing this document with `patch`.** Linear linkifies bare issue codes on save, turning `TNB-259` into an `<issue id="..." href="...">TNB-259</issue>` tag, so any anchor containing an issue code will fail to match on a later edit. Pick anchors from plain prose or from a `###` heading, and `get_document` first to copy them from the current stored content rather than from what you sent.

Structure the document exactly this way, because the renderer parses it:

- `## What this is` stays at the top. The renderer skips everything above the first dated section.
- `## Today, <Day Mon D>` starts the rendered content, and rank 1 follows it immediately. See "Open with the list" above for the single-line exception.
- `**1. Title,** TNB-123` for each ranked item. Rank 1 gets red treatment automatically. Write issue identifiers as plain text; Linear linkifies them on save.
- A plain paragraph under an item becomes that item's body. Keep it to facts.
- `### Blocked by Nico` renders in an orange box. Inside it, a bold-led line becomes its own card, same shape as a ranked item but with no number. One per line.
- `### Call sheet, TNB-179` and any other `###` render muted. Put the container issue id in the heading itself, not in a paragraph underneath. No explanatory prose in these sections, just the entries.
- `### Waiting on a reply` holds people whose reply Brian is waiting for, one entry per person, each naming their CRM card and their ping issue.
- `### Cleared today` and `### Cleared yesterday` render with a green heading.
- `### Calendar today, UK time` holds the day's schedule, one event per line, below the cleared sections.
- `### Decisions waiting`, `### Known open, not today` and `### Optional, not priorities` follow.
- `### Reference` is last: member counts and the goal, the office hours link and details, and one line on how the build was made.
- Bullets and `**bold**` work. Nothing else does, and markdown links do not.

## Ranking

Brian sets the order. When he states one, use it.

Standing rules he has set:

- **Time-sensitive actions come before decisions,** unless a decision is blocking a time-sensitive action, in which case it ranks with the thing it blocks. When that exception applies, the body line names the blocked item and its date. That is a fact, not an argument.
- **Work that unblocks Nico outranks work that only affects Brian.**
- **Brian's calls, intros and outreach are always Brian's own to-dos.** Nico is never responsible for them and they are never framed as work Nico is waiting on, even when the Morning Brief lists them under Waiting on you. They live in the Call sheet.
- **Direct communication to members outranks a public content post.**
- **Prospective member emails rank first, then the newsletter, then everything else.** Set by Brian on Sep 9, 2026.

Where he has not specified, rank by hard external dates first, then commitments to other people, then internal due dates.

**Approvals queued behind Nico are not ranked items.** If Brian cannot start it until Nico hands it over, it goes in Blocked by Nico, named, not in the numbered list.

**Optional work is not ranked.** If Brian says something is optional, move it to an "Optional, not priorities" section even when it carries a due date in Linear. Optional is not canceled: leave the issue open, add the `snooze` label to mark the date soft, and keep it listed there.

**Content timing while Brian is in the UK.** He writes a post the night before it publishes, or the morning of. That lands it in Nico's queue with room to stage during Nico's own hours. A post still unwritten the evening before is on schedule, not late, and never gets flagged as slipping.

**Promises Brian owes people go in the Call sheet,** unranked, container TNB-179, one sub-issue each. They enter the numbered list only when Brian promotes one. When one of them turns up as its own dated, urgent issue outside the call sheet, keep it at the top of the Call sheet with the date and priority named, and ask Brian in chat whether to promote it. Do not promote it on your own.

The apply form now creates membership tasks as sub-issues of TNB-179 automatically, so parentage alone no longer means an item belongs in the Call sheet. A dated, urgent membership-pipeline email ranks with the rest of the pipeline regardless of its parent; say in chat that you placed it there.

**Self-blocking is not blocking.** If the only thing holding up a send or a publish is Brian finishing the draft, that belongs in the item body, not in Blocked.

Write plainly: no em dashes, no filler adjectives, no metaphor standing in for a specific.

## Do not

- Do not editorialize about the business, in the document or in chat. See the first section.
- Do not report detail that does not change Brian's next action.
- Do not leave a finished item ranked. Close it, move the card, and re-rank in the same turn.
- Do not rank an outreach item without checking his sent mail first.
- Do not restyle or refactor the renderer unless Brian asks for a change.
- Do not widen the renderer's team scoping on any `list_issues` call.
- Do not read or reference the Athena team.
- Do not invent tasks. Everything traces to a Linear issue, the Morning Brief, or something Brian said in session.
- Do not build a second artifact for priorities. One view, one document.
- Do not republish the panel for content. Content reaches him from Linear. Tell him to click Refresh instead.
- Do not remove the Refresh button, the stamp, or any of the three banners from the page.
- Do not ask Brian to change the WebFetch deny rule. He cannot.
- Do not call the Artifact tool just to "show" the panel. Link to the existing URL instead. See "Surface the panel every time" above.
- Do not drift-check with `assignee: "me"` alone and call it complete. See "Drift-check every issue named in the document, not just Brian's" above.
- Do not put narrative, counts, the calendar, or build notes above rank 1. See "Open with the list" above.
- Do not write markdown links into the document. The renderer prints the raw syntax.