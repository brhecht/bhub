---
name: priority-agenda
description: "Opens or rebuilds Brian's Priority Agenda in the Cowork side panel, and re-ranks his day. Triggers on '/priority-agenda', 'my priorities', 'priority agenda', 'my agenda', 'open my agenda', 'what's my day look like', 'rebuild my priorities', 're-rank my day', 'update my agenda', or any request to see or change Brian's ranked list of what he's working on. The agenda lives in the Linear document 'Brian's priority agenda' (Team Ops, doc id 4aa0b7df0286); the side-panel artifact only renders it. NOT the morning brief (that is `morning`) and NOT a Linear issue list."
---

# Priority Agenda

Brian's ranked agenda for the day, rendered in the Cowork side panel.

## What this is, and the hard rule

This is an intelligent, lightly annotated to-do and project management list. Ranked items for the day, plus Blocked, Cleared today, Cleared yesterday, Known open, and the calendar as reference sections. That is the entire job.

**Annotate with adjacent facts only.** A body line under an item exists to save Brian or Nico a lookup: current status, the real date, what the item depends on, who is waiting on whom, what changed. Nothing else belongs there.

**No editorializing. This skill has no role overseeing the business.** Do not write judgment, diagnosis, prediction, ultimatums, or pattern-calling into the document. Concretely, never write copy like:

- "TNB-46, TNB-145 and TNB-121 have all been canceled in twelve days with no recording booked. Either a guest and a date land by Friday or the format pauses through September."
- "A goal with no started mechanism is a wish."
- Counts of how many times something has slipped, or what that says about Brian.

**Do not name repeat cancellations** unless the cancellation is directly relevant to the task being ranked, for example a task that was folded into another one.

**Do not add standing rules on your own.** Re-ranking, reordering, marking something in progress, and moving items between sections are working updates, not rule changes. Only edit this skill when Brian explicitly says to make something a rule.

**Do not comment on how Brian spends his time.**

## Architecture

Three pieces. Do not confuse them.

1. **The Linear document is the source of truth.** Title "Brian's priority agenda", doc id `4aa0b7df0286`, in the Team Ops project. It holds the ranked list and the wording. Nico reads the same document. Linear holds the tasks, this document holds the order.
2. **The renderer** is a self-contained HTML artifact bundled with this skill as `renderer.html`. It reads that document plus the rest of today's calendar. Never rewrite or restyle it. Brian chose this format.
3. **There is no third piece.** No skill logic renders anything.

Artifacts register per machine, which is why this skill exists: it re-registers the renderer on whatever machine Brian is on. The renderer travels inside this skill, so no mounted folder is required.

## Opening it

1. Call `list_artifacts`. Look for an artifact whose description mentions "Brian's priority agenda".
2. **If it exists**, tell him it's in the side panel. Do not re-create it. It pulls fresh from Linear every time it opens, so there is nothing to refresh.
3. **If it does not exist**, read `renderer.html` from this skill's directory, write it unmodified to the outputs directory, and call `create_artifact` with:
   - `id`: `priority-agenda`. If that errors with "already exists", try `brian-priority-agenda`, then `priority-agenda-2`. A stale folder from a deleted or cloud-synced artifact can hold the name. The id is cosmetic; the document is the source of truth, so mismatched ids across machines are harmless.
   - `description`: `Brian's live priority agenda, pulled fresh from the Linear document "Brian's priority agenda" (Team Ops) each time it opens. Shows ranked work for the day, what's blocked, what cleared, plus the rest of today's calendar. Same document Nico reads, so the two never drift.`
   - `mcp_tools`: `["mcp__638f3656-20d7-4323-9149-4d05bd4d13fe__get_document", "mcp__2818b737-df40-4ae8-8d87-4468c0475010__list_events"]`
4. Call `verify_artifact`. Confirm both MCP calls returned without error before telling him it's ready.

The Linear and Google Calendar MCP server ids above are per-account and may differ elsewhere. If `get_document` is not available under that exact name, find the equivalents with ToolSearch and substitute them in both the `mcp_tools` list and inside the HTML.

## Updating and re-ranking

Edit the Linear document with `save_document` on id `4aa0b7df0286`. Never edit the artifact to change content. The artifact only renders.

Before writing, pull real state with `list_issues` for issues assigned to Brian, open only. Move anything that closed or got canceled out of the ranked list and into the cleared section.

When Brian says he has started something, set that issue to In Progress in Linear with `save_issue`. The document and the issue tracker should agree.

Structure the document exactly this way, because the renderer parses it:

- `## What this is` stays at the top. The renderer skips everything above the first dated section.
- `## Today, <Day Mon D>` starts the rendered content.
- `**1. Title,** TNB-123` for each ranked item. Rank 1 gets red treatment automatically. Write issue identifiers as plain text; Linear linkifies them on save.
- A plain paragraph under an item becomes that item's body. Keep it to facts, usually one line.
- `### Blocked` renders in an orange box. Name who is blocked on whom.
- `### Cleared today` and `### Cleared yesterday` render with a green heading.
- `### Known open, not today` and any other `###` render muted.
- Bullets and `**bold**` work. Nothing else does.

## Ranking

Brian sets the order. When he states one, use it.

Standing rule he has set: **time-sensitive actions come before decisions, unless a decision is blocking a time-sensitive action, in which case it ranks with the thing it blocks.** When that exception applies, the body line names the blocked item and its date. That is a fact, not an argument.

Where he has not specified, rank by hard external dates first, then commitments to other people, then internal due dates.

Write plainly: no em dashes, no filler adjectives, no metaphor standing in for a specific.

## Do not

- Do not restyle, refactor, or improve the renderer HTML.
- Do not invent tasks. Everything traces to a Linear issue or something Brian said in session.
- Do not build a second artifact for priorities. One view, one document.
