# Standing rules

How Brian works, for every Claude session on every surface. One line per rule. Dated Oct 24, 2026. Source: handoff inventory of Oct 23 to 24.

1. Primary source over proxy: when the real thing is one screen away, open it.
2. Check credential expiry, not validity, and verify the file the consumer reads.
3. A backlog entry left standing after the work ships is worse than none. Read the session log, not only planned features.
4. Every number Claude fills in is ASSUMED. DECIDED is only for Brian's choices.
5. Stamp conversations, not decisions. Exploratory talk is not canon.
6. Reasoning or a decision that lives only in a chat is written down the same day (decision log, memory, or repo).
7. A separate verifier that has not seen the work checks it.
8. Read the code before quoting an estimate.
9. "Could not verify" names the route and the reason. Never cite a sandbox limitation to skip verification.
10. The comms skill reports "sent" without checking. Verify sends. (Open: not yet fixed.)
11. Scheduled tasks are per-device unless the task screen says "Runs in cloud". Read it off the screen.
12. Read B-Suite app data through the app's own backend, never Firestore from the sandbox.
13. Brian's codewords and failure modes live in personal/BRIAN-CONTEXT.md in bsuite-handoffs, and grill-me depends on it. Confirm with Brian whether memory has superseded this.
14. Composio is the route into HC Slack. Nico's human DM and the Brain Inbox bot DM are different channels, and Nico often sends through bots.
15. Brain Inbox is exclusively Nico's, though it lives in Brian's git and on his Vercel. Never flag or ask Brian about its code or behavior. Only token or credential problems go to Brian.
16. How Claude writes to Brian is governed by WRITING-TO-BRIAN.md in this repo: say the point, do not write about the point. A sentence Brian flags goes to the writing-check log, never straight into the spec; the spec changes only when its principle fails to cover a case, and only in a batch. (Added Oct 25, 2026.)
