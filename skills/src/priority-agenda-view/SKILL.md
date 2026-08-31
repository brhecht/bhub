---
name: priority-agenda-view
description: "Opens a read-only view of Brian's priority agenda in the Cowork side panel. Triggers on '/priority-agenda-view', \"Brian's priorities\", \"Brian's agenda\", 'what is Brian working on', 'what does Brian want first', 'check the agenda', 'what is Brian blocked on', or any question about Brian's current priorities or ranking. Read-only: never edits the agenda document. NOT for Nico's own task list."
---

# Priority Agenda (read-only view)

Opens Brian's ranked agenda in the Cowork side panel. This is the same document Brian works from, pulled live, so it is never a stale copy.

## What this is

Brian's ranked to-do and project management list for the day, plus Blocked, Cleared today, Cleared yesterday, and Known open as reference sections.

Check this instead of asking Brian for status. If something looks missing or mis-ranked, tell him rather than changing it.

## Read-only, hard rule

**Never edit the agenda document.** Do not call `save_document` on doc id `4aa0b7df0286` for any reason. Brian owns the ranking. If Nico thinks something is wrong, surface it to Brian and let him decide.

**Do not editorialize.** When answering questions from this document, report what it says. No judgment about Brian's priorities, no predictions, no commentary on what is slipping.

## Architecture

1. **The Linear document is the source of truth.** Title "Brian's priority agenda", doc id `4aa0b7df0286`, in the Team Ops project. Brian maintains it.
2. **The renderer** is a self-contained HTML artifact bundled with this skill as `renderer.html`. It reads that document. Never rewrite or restyle it.

Artifacts register per machine, which is why this skill exists: it registers the renderer on whatever machine is in use.

## Opening it

1. Call `list_artifacts`. Look for an artifact whose description mentions "Brian's priority agenda".
2. **If it exists**, say it is in the side panel. Do not re-create it. It pulls fresh from Linear every time it opens, so there is nothing to refresh.
3. **If it does not exist**, read `renderer.html` from this skill's directory, write it unmodified to the outputs directory, and call `create_artifact` with:
   - `id`: `priority-agenda-view`. If that errors with "already exists", try `brian-agenda-view`, then `priority-agenda-view-2`.
   - `description`: `Read-only view of Brian's priority agenda, pulled fresh from the Linear document "Brian's priority agenda" (Team Ops) each time it opens. Shows Brian's ranked work for the day, what's blocked, and what cleared.`
   - `mcp_tools`: `["mcp__638f3656-20d7-4323-9149-4d05bd4d13fe__get_document"]`
4. Call `verify_artifact` and confirm the Linear call returned without error.

The Linear MCP server id above is per-account and may differ. If `get_document` is not available under that exact name, find the equivalent with ToolSearch and substitute it in both the `mcp_tools` list and inside the HTML.

If the document returns a permission error, Nico does not have access to the Team Ops project in Linear. Tell him to ask Brian for access rather than working around it.

## Answering questions without opening the panel

If the question is small, for example "what is Brian's top priority" or "what is he blocked on", call `get_document` on `4aa0b7df0286` and answer from it directly. No need to build the artifact for a one-line answer.

## Do not

- Do not edit the agenda document.
- Do not restyle or refactor the renderer.
- Do not add tasks to the agenda. Task changes go in Linear as issues, and Brian ranks them.
