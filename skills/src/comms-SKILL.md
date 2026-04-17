---
name: comms
description: "Send messages between Brian and Nico via Email, Slack DM, or Brain Inbox ping. Use this skill whenever the user says 'email', 'DM', 'ping', 'send to', 'message', 'notify', or 'tell' followed by a person's name (Nico, Brian) — even if they don't explicitly say 'comms'. Also triggers on 'send to Brain Inbox', 'send to B Things Bot', or any request to communicate something to a team member. Handles channel routing automatically: email for longer content (creates Gmail draft), DM for quick Slack messages, ping for task-oriented Brain Inbox notifications."
---

# Comms Skill

Route messages between Brian and Nico through the right channel. This skill works for **both users** — it detects who the current user is from the `<user>` tag in the system prompt (which contains Name and Email), then routes to the other person accordingly.

Three channels: Email (longer, structured — creates a Gmail draft for review), DM (short Slack direct message — sends immediately), and Ping (Brain Inbox / B Things Bot notification — sends immediately).

## Sender Detection

**Always check the `<user>` tag in the system prompt first.** This tells you who is using the skill right now.

- If `Name: Brian` or `Email: brhnyc1970@gmail.com` → sender is Brian, default recipient is Nico
- If `Name: Nico` or `Email: nico@humbleconviction.com` or `Email: nmejiawork@gmail.com` → sender is Nico, default recipient is Brian

The user can override the recipient explicitly (e.g., Brian saying "email myself" or Nico saying "ping Nico" for a self-reminder).

## Channel Selection

Pick the channel based on what the user says, or infer from content length and intent:

| Signal | Channel |
|--------|---------|
| User says "email" | Email |
| User says "DM" or "message" | DM |
| User says "ping", "notify", "send to Brain Inbox", "send to B Things Bot" | Ping |
| Content is >500 chars or has structure (headers, lists, instructions) | Suggest Email |
| Content is a quick status update, question, or "hey check this" | DM |
| Content is task-oriented ("deploy is done", "PR is ready", "check this issue") | Ping |

If ambiguous, default to DM for short content and Email for long content. Always tell the user which channel you chose and why.

## Contact Registry

```
Brian:
  email: brhnyc1970@gmail.com
  slackId: U096WPV71KK

Nico:
  email: nico@humbleconviction.com
  altEmail: nmejiawork@gmail.com
  slackId: U09GRAMET4H
```

## Channel: Email

Use the Gmail MCP's draft-creation tool to create a draft in the **current user's** Gmail. The tool name may vary by MCP version — at the time of writing it is exposed as `create_draft` (previously `gmail_create_draft`). If the expected name doesn't resolve, use `ToolSearch` with `select:` or a keyword query (e.g., `gmail draft`) to find the currently registered tool on the Gmail MCP and call that. The user reviews and sends manually — this is a Gmail limitation, not a bug.

**Routing based on sender:**

- **Brian sending to Nico:** Draft in Brian's Gmail → To: nico@humbleconviction.com
- **Nico sending to Brian:** Draft in Nico's Gmail → To: brhnyc1970@gmail.com
- **Self-send:** Draft to sender's own email (useful for notes-to-self)

Note: The Gmail MCP tool drafts in whichever Gmail account is connected to the current user's Cowork session. Each user must have Gmail connected in their own Cowork setup.

Write the email in a professional but casual tone matching Brian and Nico's working relationship. No corporate fluff. Clear, direct, actionable.

After creating the draft, tell the user: "Draft created in Gmail — review and hit send when ready."

## Channel: DM (Slack Direct Message)

Send a short Slack DM via the Brain Inbox handoff-notify API with the `dmOnly` flag. This skips Brain Inbox / Firestore — it's just a direct Slack message.

**Endpoint:** `https://brain-inbox-six.vercel.app/api/handoff-notify`

**Method:** POST with `Content-Type: text/plain` (avoids CORS preflight)

**Body (JSON stringified):**
```json
{
  "project": "<project name or 'Comms'>",
  "summary": "<the message content>",
  "recipient": "<recipient email>",
  "recipientSlackId": "<recipient slack ID>",
  "dmOnly": true
}
```

**Important:** The `dmOnly` flag requires a code change to `brain-inbox/api/handoff-notify.js` (see Code Changes section below). Until that change is deployed, DMs to Nico will also write to Brain Inbox and post to the Brain Inbox Slack channel. DMs to Brian work correctly already since Brian's path is already DM-only.

**Character guidance:** Keep DMs under ~500 chars. If the content is longer, suggest email instead. The handoff-notify API truncates at 3000 chars for Slack.

**Execution:** Use the Network Resilience Protocol below. DMs send immediately with no approval step. Tell the user: "DM sent to [name] on Slack."

## Channel: Ping (Brain Inbox / B Things Bot)

Send a task-oriented notification that lands in the recipient's triage queue. This is the standard handoff-notify path — writes to Firestore (if recipient has a UID) and posts to the appropriate Slack channel/DM.

**Endpoint:** Same as DM but WITHOUT the `dmOnly` flag.

**Body (JSON stringified):**
```json
{
  "project": "<project name>",
  "summary": "<notification content — include context, what happened, what's needed>",
  "recipient": "<recipient email>",
  "recipientSlackId": "<recipient slack ID>"
}
```

**Routing:**
- **To Nico:** Writes to Brain Inbox Firestore + posts to Brain Inbox Slack channel
- **To Brian:** Sends Slack DM directly (no Firestore — Brian doesn't have a Brain Inbox UID yet)

**Execution:** Use the Network Resilience Protocol below. Pings send immediately with no approval step. Tell the user: "Pinged [name] via Brain Inbox."

## Network Resilience Protocol (DM + Ping channels)

The Cowork VM's outbound network access is unreliable — DNS resolution and HTTPS requests fail in some sessions. Because the handoff-notify API must be reachable to send DMs and Pings, this skill uses a tiered fallback to ensure delivery regardless of VM network state.

**Try these in order. Move to the next tier only when the current one fails.**

### Tier 1: Chrome JavaScript execution (preferred — always has network)

The user's browser runs on their Mac, which always has internet. Use the `mcp__Claude_in_Chrome__javascript_tool` to execute the fetch from any open browser tab. This is the most reliable path.

First get available tabs via `mcp__Claude_in_Chrome__tabs_context_mcp`, then execute on any tab:

```javascript
// Execute via mcp__Claude_in_Chrome__javascript_tool
fetch('https://brain-inbox-six.vercel.app/api/handoff-notify', {
  method: 'POST',
  headers: { 'Content-Type': 'text/plain' },
  body: JSON.stringify({
    project: '<project>',
    summary: '<message>',
    recipient: '<email>',
    recipientSlackId: '<slackId>',
    dmOnly: true  // omit for Ping channel
  })
}).then(r => r.json()).then(d => JSON.stringify(d))
```

If Chrome tools are connected, this will work every time. If Chrome returns an error about not being connected or no tabs available, move to Tier 2.

### Tier 2: VM direct request (works when VM has network)

Try a simple fetch from the VM via Bash. This works in sessions where the VM has outbound access:

```bash
node -e "
fetch('https://brain-inbox-six.vercel.app/api/handoff-notify', {
  method: 'POST',
  headers: { 'Content-Type': 'text/plain' },
  body: JSON.stringify({
    project: '<project>',
    summary: '<message>',
    recipient: '<email>',
    recipientSlackId: '<slackId>',
    dmOnly: true
  })
}).then(r => r.text()).then(console.log).catch(e => { console.error(e.message); process.exit(1) })
"
```

If this fails with DNS/network errors (`EAI_AGAIN`, `ENOTFOUND`, `ETIMEDOUT`), move to Tier 3.

### Tier 3: User paste (last resort)

Only reach this if both Chrome and VM network are unavailable — a rare double-fault. Give the user a single-line JS snippet to paste into any browser console (Option+Cmd+J on Mac), with brief instructions:

1. Tell them: "Chrome extension is disconnected and the VM can't reach the internet right now. Paste this into any browser console (Option+Cmd+J):"
2. Provide the fetch one-liner (single line, no line breaks)
3. Tell them they'll see a JSON response with `ok: true` when it works

This should almost never happen — it requires both Chrome disconnected AND VM network blocked simultaneously.

## Content Resolution

The user may reference content by context rather than writing it out. Resolve these references:

- **"Email the device setup instructions to Nico"** → Pull from the handoff skill's Device Setup Protocol section, format for email
- **"DM Brian about the deploy"** → Compose from current session context, send to Brian
- **"Ping Brian that the deploy is done"** → Short notification with project name and what deployed
- **"Email Nico the content calendar handoff"** → Read the latest Content Calendar handoff file, format as email body or reference
- **"Tell [name] [anything from conversation]"** → Compose from the current conversation context, route to named recipient

If the reference is ambiguous, ask the user to clarify what content they mean.

## Code Changes Needed (Not Yet Deployed)

The `dmOnly` flag in handoff-notify.js needs to be implemented for the DM channel to work cleanly for Nico. The change is small:

**File:** `brain-inbox/api/handoff-notify.js`

**What to add:** Parse `dmOnly` from the request body. When `dmOnly === true`:
1. Skip the Firestore `inboxMessages` write (don't set `firestoreId`)
2. For Nico: DM to `slackUserId` directly instead of `BRAIN_CHANNEL_ID`
3. For Brian: no change needed (already DMs)

This gives a clean "DM only" path without Brain Inbox noise. Until deployed, DMs to Nico will also trigger Brain Inbox writes — functional but noisier than intended.

## Setup Requirements

Each user needs the following in their Cowork session for full functionality:

1. **Gmail MCP connected** — required for email drafts. Each user connects their own Gmail account.
2. **Skill installed** — double-click `comms.skill` to install, restart session.
3. **User profile set** — Cowork's `<user>` tag must have correct Name and Email so sender detection works.

## What This Skill Does NOT Do

- Does not send email directly (Gmail creates drafts only — user must hit send)
- Does not create B Things tasks (that's the `--notes` Slack flow, separate system)
- Does not handle group messages or Slack channels
- Does not handle recipients outside Brian and Nico (extend the contact registry to add more)
