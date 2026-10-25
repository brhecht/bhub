---
name: content-calendar
description: "Brian's content calendar app (B Content). Use this, not athena or linear-ops, for content cards. A GHOST is a content idea card parked in the calendar, never a ghostwritten post. Triggers without a slash command: 'log a ghost Substack post about AI agents', 'add an idea for a LinkedIn', 'park that', 'put it on hold', 'what ghosts do I have', 'add a LinkedIn for Thursday on the Jesse clip', 'schedule a short for Friday', 'change today's LinkedIn publish date to tomorrow', 'move the Halloween newsletter to Draft', 'rename that card', 'change the due date on the newsletter to Wednesday', 'put this draft on Tuesday's LinkedIn', 'add a note to the Jesse podcast'. Edits cards directly; no Linear. Not for writing the piece (create-content) or Brian's task list (athena)."
---

## Writing to Brian (read first)

Say the point; do not write about the point. Every sentence this skill writes to Brian states a fact or gives an instruction, with a subject that exists and a verb that says what it literally does, including bullets and lines after a colon. Before sending, apply the three questions in `references/writing-to-brian.md` in this skill. The canonical copy is `WRITING-TO-BRIAN.md` at the root of the bhub repo.

# Content Calendar

Brian runs his content calendar (the app B Content, https://content-calendar-nine.vercel.app) by talking. Every card lives in Firebase (Firestore). Claude changes the data there and the app shows it on the next refresh. Linear is not involved. Do the operation and report it in two lines: what changed and the card's id. No analysis, no alternatives, no recommendations.

## Do not run the handoff bootstrap, and do not open a browser first

These requests change card data, not code. Do not run the `handoff` skill or the B-Suite bootstrap for them, and do not mount or clone any repo. Try the call from a shell first. Open the browser only when the shell cannot reach the app. If the browser tab is not signed in to B Content, or the key is not available, say so in one line and stop; do not click through a sign-in.

## The calls

Base URL `https://content-calendar-nine.vercel.app/api/cards-admin`, header `Authorization: Bearer <VITE_FIREBASE_API_KEY>`. The key is the content-calendar app's Firebase web key (the same one `create-content` uses; it lives in the app's `.env` and Vercel settings). Never print it in chat and never write it into a file in a repo.

From a shell that can reach vercel.app, use curl. From a Cowork session, the shell cannot reach `*.vercel.app`; run the same `fetch` from Brian's signed-in B Content tab in the browser, where the app exposes the key as `window.__store.getState().user.auth.config.apiKey`.

- **Find cards.** `GET ?open=1` returns every open card with `id, title, status, contentType, publishDate, dueDate`. Match "that ghost", "today's LinkedIn" or "the Halloween newsletter" by title, format and date. If two cards match, ask which one, in one line.
- **Add a card.** `POST {"action":"add","fields":{...}}`. `title` is required. `status` is `ghost` unless Brian says otherwise. A card on the calendar needs a status in the pipeline (`idea`, `draft`, `ready-to-edit`, `ready-to-review`, `ready-to-stage`, `staged`, `approved`, `scheduled`) and a `publishDate`. "Add a LinkedIn for Thursday on the Jesse clip" is `{"title":"Jesse clip","contentType":"linkedin-post","status":"idea","publishDate":"2026-10-29"}`.
- **Change a card.** `POST {"action":"edit","id":"card-…","fields":{...}}`. Fields: `title`, `status`, `publishDate`, `dueDate`, `contentType`, `body`, `notes`, `transcript`, `sourceUrl`, `tags`. A card moved into the pipeline needs a `publishDate`; the call returns what is missing.

Statuses: `ghost`, `idea`, `draft`, `ready-to-edit`, `ready-to-review`, `ready-to-stage`, `staged`, `approved`, `scheduled`, `on-hold`. Format words to `contentType`: newsletter or Substack is `beehiiv-post`; LinkedIn is `linkedin-post`; YouTube or video is `yt-video`; podcast is `podcast`; short is `yt-short`. Body shapes: `linkedin-post` is `{liBody, liFooter}`; `yt-video` and `yt-short` are `{ytTitle, description, timeCodes, footer}`; `beehiiv-post` is `{subjectLine, subHead, imageCaption, essayBody, bestOfWeek, theySaidQuote, theySaidAttribution}`. `body` may be sent as an object.

## Rules

- "Publish date", "ships" and "goes out" mean `publishDate`. "Due date" and "draft due" mean `dueDate`, Brian's writing deadline (usually the day before publish). "Move it to Thursday" with no other word means `publishDate`. If the wording could mean either, ask in one line.
- Resolve relative dates ("Thursday", "tomorrow", "next week") against today's date and send YYYY-MM-DD built from local calendar parts. Never derive a date through `toISOString()`.
- A card Brian names by topic gets a title in his words ("Halloween newsletter"). Do not invent a title when he gave only a format; ask for the topic in one line.
- Never publish, archive or delete a card, and never touch the Marketing Library from here. Publishing happens in the app, which fills the archive fields. The calls refuse these.
- If a call returns an error, report the error text in one line and stop. Do not retry with different fields.
- To tell Nico something, use the `comms` skill.

## Report format

Two lines. Example: "Logged a ghost: Halloween newsletter (card-1792…). It is in Ghost." Or: "Moved the Jesse clip LinkedIn to Oct 30. It shows after you refresh the app."
