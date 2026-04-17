/**
 * claude-auto-send.gs — Auto-sends Gmail drafts that contain a hidden Claude marker.
 *
 * Deploy: script.google.com → new project → paste this → save → Triggers →
 *   + Add Trigger → Function: processClaudeAutoSendDrafts → Time-driven →
 *   Minutes timer → Every 5 minutes → Save → approve Gmail permissions.
 *
 * How it works: the comms skill creates Gmail drafts with the marker below
 * embedded as a hidden HTML comment in the body. This script runs every 5 min,
 * finds any draft containing the marker, and sends it. The marker is
 * invisible in the delivered email.
 */

const MARKER = '<!--CLAUDE-AUTO-SEND-V1-->';

function processClaudeAutoSendDrafts() {
  const drafts = GmailApp.getDrafts();
  for (const draft of drafts) {
    const htmlBody = draft.getMessage().getBody();
    if (htmlBody.includes(MARKER)) {
      try {
        draft.send();
        Logger.log('Sent: ' + draft.getMessage().getSubject());
      } catch (err) {
        Logger.log('Failed: ' + err.toString());
      }
    }
  }
}
