---
name: content-calendar
description: "Brian's content calendar app (B Content). Use this, not athena or linear-ops, for content cards. A GHOST is a content idea card parked in the calendar, never a ghostwritten post. Triggers without a slash command: 'log a ghost Substack post about AI agents', 'add an idea for a LinkedIn', 'park that', 'put it on hold', 'what ghosts do I have', 'add a LinkedIn for Thursday on the Jesse clip', 'schedule a short for Friday', 'change today's LinkedIn publish date to tomorrow', 'move the Halloween newsletter to Draft', 'rename that card', 'change the due date on the newsletter to Wednesday', 'put this draft on Tuesday's LinkedIn', 'add a note to the Jesse podcast'. Edits cards directly; no Linear. Not for writing the piece (create-content) or Brian's task list (athena)."
---

## Writing to Brian (read first)

Say the point; do not write about the point. Every sentence this skill writes to Brian states a fact or gives an instruction, with a subject that exists and a verb that says what it literally does, including bullets and lines after a colon. Before sending, apply the three questions in `references/writing-to-brian.md` in this skill. The canonical copy is `WRITING-TO-BRIAN.md` at the root of the bhub repo.

# Content Calendar

Brian runs his content calendar (the app B Content) by talking. Every card lives in Firebase. Claude changes it through the **B Content connector**, which gives four tools: `list_cards`, `add_card`, `edit_card` and `delete_card`. Linear is not involved. Do the operation and report it in two lines: what changed and the card's id. No analysis, no alternatives, no recommendations.

## Do not run the handoff bootstrap

These requests change card data, not code. Do not run the `handoff` skill or the B-Suite bootstrap, do not mount or clone any repo, and do not open a browser. Call the connector tools directly. If the B Content connector's tools are not available in this chat, say so in one line ("The B Content connector is not enabled in this chat") and stop.

## The tools

- **`list_cards`** finds cards. By default only open cards (ghosts, held cards, cards on the calendar); set `where` to `archive`, `marketing` or `all` to search published cards or the Marketing Library. Filters: `query` (text in the title), `status`, `date` (publish date), `empty` (cards with nothing typed on them). Use it to find "that ghost", "today's LinkedIn" or "the Halloween newsletter" before editing. If two cards match, ask which one, in one line.
- **`add_card`** adds a card. `title` is required. A ghost has no date. A card on the calendar needs a pipeline status and a `publishDate`: "add a LinkedIn for Thursday on the Jesse clip" is title "Jesse clip", `contentType` `linkedin-post`, `status` `idea`, `publishDate` that Thursday.
- **`delete_card`** deletes cards by id (any card). Use it only in two steps. First show Brian the cards (`list_cards`, with `empty: true` for "show me all empty ghost cards"), each with its title and id. Then, only when he says to delete them, call `delete_card` with those ids and `confirmed: true`. Never delete on your own, never delete a card Brian has not seen in the list, and never widen the list after he approved it. Each deleted card, with its messages, is copied to a recovery area first; say so in the report. Do not delete an archived or Marketing Library card unless Brian named it.
- **`edit_card`** changes a card by `id`: title, status, publish date, due date, format (including promo-video and promo-email), the Marketing flag, notes, draft, tags. Moving a card into the pipeline needs a `publishDate`. Setting the status to `published` archives the card and fills its archive fields, like the app. Moving an archived card to any other status takes it out of the archive. Archived and Marketing Library cards can be edited.

Statuses: `ghost`, `idea`, `draft`, `ready-to-edit`, `ready-to-review`, `ready-to-stage`, `staged`, `approved`, `scheduled`, `on-hold`. The tool descriptions give the format words and the draft shapes.

## Rules

- "Publish date", "ships" and "goes out" mean `publishDate`. "Due date" and "draft due" mean `dueDate`, Brian's writing deadline (usually the day before publish). "Move it to Thursday" with no other word means `publishDate`. If the wording could mean either, ask in one line.
- Resolve relative dates ("Thursday", "tomorrow", "next week") against today's date and send YYYY-MM-DD built from local calendar parts. Never derive a date through `toISOString()`.
- A card Brian names by topic gets a title in his words ("Halloween newsletter"). Do not invent a title when he gave only a format; ask for the topic in one line.
- Publish only when Brian says the piece is published. Deleting follows the two-step rule under `delete_card`.
- If a tool returns an error, report the error text in one line and stop. Do not retry with different fields.
- To tell Nico something, use the `comms` skill.

## Report format

Two lines. Example: "Logged a ghost: Halloween newsletter (card-1792…). It is in Ghost." Or: "Moved the Jesse clip LinkedIn to Oct 30. It shows after you refresh the app."
