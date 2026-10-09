---
name: priority-agenda-view
description: "Opens Nico's read-only live view of Brian's TNB priority agenda, and answers questions from it. Triggers on '/priority-agenda-view', \"Brian's priorities\", \"Brian's agenda\", 'what is Brian working on', 'what does Brian want first', 'check the agenda', 'what is Brian blocked on', 'what is Brian waiting on', or any question about Brian's current TNB ranking. Read-only: never edits the agenda document. NOT for Nico's own task list."
---

# Priority Agenda (read-only view)

Brian's ranked TNB agenda, read live from the Linear document he works from. Never a stale copy.

## What this is

Brian's ranked work for the day, then the reference sections in this order: Blocked by Nico, Call sheet, Waiting on a reply, Cleared today, Cleared yesterday, Coming up, Nico owes Brian, Decisions waiting, Parked, Optional, Calendar, Reference.

Check this instead of asking Brian for status. If something looks missing or mis-ranked, tell him rather than changing it.

## Read-only, hard rule

**Never edit the agenda document.** Do not call `save_document` on doc id `4aa0b7df0286` for any reason, and do not change any issue because of what the agenda says. Brian owns the ranking and the wording. If Nico thinks something is wrong, surface it to Brian and let him decide.

**Do not editorialize.** Report what the document says. No judgment about Brian's priorities, no predictions, no commentary on what is slipping.

## Where it lives

1. **The Linear document is the source of truth.** "Brian's priority agenda", doc id `4aa0b7df0286`, in the Team Ops project. Brian maintains it; a routine rebuilds it every morning at 6:50 AM ET.
2. **The page** is a published Artifact Brian shares with Nico: **https://claude.ai/artifact/SGXi9rHzqsvJ4m9QYVhs9q**. It reads the document on open, on its Refresh button, every two minutes, and when the tab comes back into view. It calls two Linear tools, `get_document` and `list_issues`, with Nico's own Linear connector, and never a write. Source: `bhub/skills/src/priority-agenda-view/tnb-view.html`.

## Opening it

Give the link. Every reply about Brian's agenda ends with it. Nothing needs to be created, registered or published: the page already exists and reads Linear itself.

The first time Nico opens it, Claude asks once to allow Linear for the page. If the page says the document was not found, Nico does not have access to the Team Ops project in Linear, or Brian has not shared the page with this account yet. Tell him to ask Brian rather than working around it.

## Answering questions without opening the page

For a small question, "what is Brian's top priority" or "what is he blocked on", call `get_document` on `4aa0b7df0286` and answer from it directly. Name the item and its issue code. For a drift check, `list_issues` scoped to the `The New Builder` team only; never a bare `assignee` filter.

## Do not

- Do not edit the agenda document or any issue because of it.
- Do not restyle or republish the page. Brian owns it.
- Do not add tasks to the agenda. Task changes go in Linear as issues, and Brian ranks them.
- Do not read any team other than The New Builder and TNB CRM for this skill.
