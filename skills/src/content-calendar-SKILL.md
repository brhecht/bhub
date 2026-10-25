---
name: content-calendar
description: "Controls Brian's content calendar (B Content) by talking. Logs, renames, moves and re-dates cards, and puts drafts on cards. Triggers without a slash command on any request to add, log, park, rename, move, re-date, hold or look up a content idea or piece: 'log a ghost newsletter about Halloween', 'add an idea for a LinkedIn on X', 'park that', 'put it on hold', 'what ghosts do I have', 'what's on my content calendar', 'move that ghost to Idea on Dec 3', 'add a LinkedIn for Thursday on the Jesse clip', 'rename that card', 'put this draft on Tuesday's LinkedIn', 'schedule a short for Friday', 'change the due date for this week's newsletter to Thursday'. Ghosts, holds and drafts go to B Content directly; dated pieces go to Linear. Not for writing the piece itself (that is create-content) and not for Brian's personal task list (that is athena)."
---

## Writing to Brian (read first)

Say the point; do not write about the point. Every sentence this skill writes to Brian states a fact or gives an instruction, with a subject that exists and a verb that says what it literally does, including bullets and lines after a colon. Before sending, apply the three questions in `references/writing-to-brian.md` in this skill. The canonical copy is `WRITING-TO-BRIAN.md` at the root of the bhub repo.

# Content Calendar

Brian runs his content calendar (the app B Content, https://content-calendar-nine.vercel.app) by talking. Do the operation and report it in two lines: what changed, and the card's id or Linear key. No analysis, no alternatives, no recommendations.

## Where each kind of card lives

| What Brian says | Where it lives | How |
|---|---|---|
| A ghost, an idea, a parked or held card ("log a ghost newsletter about Halloween", "park that") | Firestore only | `cards-admin` `add` or `edit` |
| A piece with a format and a publish date ("add a LinkedIn for Thursday on the Jesse clip") | A Linear issue in the Content Calendar project (team TNB) | the `linear-ops` skill |
| Words on a card (a draft, notes, tags, a transcript) | Firestore | `cards-admin` `edit` for a ghost; `cards-admin` `set` for a piece |
| Moving a ghost into the calendar ("move that ghost to Idea on Dec 3") | Becomes a Linear issue | `cards-admin` `edit` with a status and a publish date |

A piece with a date is a Linear issue because Nico already plants the weekly set there. A ghost has no date and nothing is owed yet, so it stays out of Linear. Cards appear in the app on its next refresh (up to 2 minutes, a window focus, or the Refresh button).

## The calls

Base URL `https://content-calendar-nine.vercel.app/api/cards-admin`, header `Authorization: Bearer <VITE_FIREBASE_API_KEY>`. The key is the content-calendar app's Firebase web key (the same one `create-content` uses; it lives in the app's `.env` and Vercel settings). Never print it in chat and never write it into a file in a repo.

From a shell that can reach vercel.app, use curl. From a Cowork session, the shell cannot reach `*.vercel.app`; run the same `fetch` from Brian's signed-in B Content tab in the browser, where the app exposes the key as `window.__store.getState().user.auth.config.apiKey`.

- **List the open Firestore-only cards.** `GET ?open=1` returns `id, title, status, contentType, publishDate, dueDate`. Use it to find "that ghost" by title. If two cards match, ask which one, in one line.
- **Add a ghost.** `POST {"action":"add","fields":{"title":"Halloween newsletter","contentType":"beehiiv-post"}}`. `status` is `ghost` unless Brian says hold (`"status":"on-hold"`). Add refuses dates and pipeline statuses.
- **Edit a Firestore-only card.** `POST {"action":"edit","id":"card-…","fields":{…}}`. Fields: `title`, `status`, `publishDate` (YYYY-MM-DD), `contentType`, `body`, `notes`, `transcript`, `sourceUrl`, `tags`, `dueDate`. Moving a ghost or held card to a pipeline status (`idea`, `draft`, and on up) needs a title, a format and a `publishDate`; the call then creates the Linear issue in Content Calendar and links the card. Without all three, nothing is written and the call returns what is missing; ask Brian for it in one line.
- **Put a draft on a piece that is already a Linear issue.** `POST {"action":"set","linearId":"TNB-694","fields":{"contentType":"linkedin-post","body":{"liBody":"<p>Text</p>","liFooter":""},"notes":"…"}}`. `linearId` takes the issue key or its uuid. `set` refuses title, status and publish date.

Format words to `contentType`: newsletter or Substack is `beehiiv-post`; LinkedIn is `linkedin-post`; YouTube or video is `yt-video`; podcast is `podcast`; short is `yt-short`. Body shapes: `linkedin-post` is `{liBody, liFooter}`; `yt-video` and `yt-short` are `{ytTitle, description, timeCodes, footer}`; `beehiiv-post` is `{subjectLine, subHead, imageCaption, essayBody, bestOfWeek, theySaidQuote, theySaidAttribution}`. `body` may be sent as an object.

## Rules

- Resolve relative dates ("Thursday", "next week") against today's date and send YYYY-MM-DD built from local calendar parts. Never derive a date through `toISOString()`.
- A card Brian names by topic gets a title in his words ("Halloween newsletter"). Do not invent a title when he gave only a format; ask for the topic in one line.
- Never publish, archive, delete or touch the Marketing Library from here. Publishing happens in the app, which fills the archive fields. A card linked to Linear is cancelled in Linear (`linear-ops`), never deleted.
- "Due date" on a piece means the Linear due date, which the app shows as the Publish Date. Brian's private writing deadline is a separate field; change it only when he says "writing deadline" or "draft due" (use `set` with `dueDate`). Tell Brian which one changed in the report.
- Change the date, stage or assignee of a planted issue when Brian asks for that piece ("this week's newsletter", "Thursday's LinkedIn"). Do not change the title or labels of a planted issue unless he asks for that. Nico's Friday job names and labels them; Brian renamed TNB-698, 699 and 700 himself.
- Moving a piece's stage in Linear moves the issue for Nico too: Ready to edit assigns it to Nico and Ready to review assigns it to Brian. Say so in the report when it happens.
- If a call returns an error, report the error text in one line and stop. Do not retry with different fields.

## Report format

Two lines. Example: "Logged a ghost: Halloween newsletter (card-1792…). It is in Ghost." Or: "Moved Halloween newsletter to Idea on Dec 3 and created TNB-820. It shows in the app after the next refresh."
