/**
 * claude-auto-send.gs — Gmail Apps Script that auto-sends drafts created by Claude.
 *
 * HOW IT WORKS
 * ------------
 * When the comms skill (or any other Claude workflow) needs an email to send
 * automatically, it creates a Gmail draft with a special invisible marker in
 * the HTML body:
 *
 *     <!--CLAUDE-AUTO-SEND-V1-->
 *
 * This script runs on a time-based trigger (every few minutes), scans your
 * drafts, and sends any draft containing that marker. The marker is a hidden
 * HTML comment, so it's invisible in the delivered email.
 *
 * ONE-TIME DEPLOYMENT (~3 min)
 * ----------------------------
 * 1. Go to https://script.google.com and click "+ New project"
 * 2. Name it "Claude Auto-Send"
 * 3. Delete the default `function myFunction()` stub
 * 4. Paste this entire file into the editor
 * 5. Save (⌘S)
 * 6. Click the "Triggers" icon in the left sidebar (looks like a clock)
 * 7. Click "+ Add Trigger" (bottom-right)
 *    - Choose which function to run: processClaudeAutoSendDrafts
 *    - Event source: Time-driven
 *    - Type of time-based trigger: Minutes timer
 *    - Select minute interval: Every 5 minutes
 *    - Save. Grant Gmail permissions when prompted.
 *
 * That's it. Now any draft created with the marker will be sent within 5 min.
 *
 * SAFETY
 * ------
 * - Only drafts containing the EXACT marker string are sent. No false positives.
 * - Runs as you (Brian), so emails come from your Gmail account.
 * - Capped at MAX_SENDS_PER_RUN to prevent runaway in case of a bug.
 * - After sending, the draft is auto-removed (as is standard Gmail behavior
 *   when you send a draft).
 *
 * MAINTENANCE
 * -----------
 * To disable temporarily: Triggers → pause or delete the trigger.
 * To change frequency: Triggers → edit interval.
 * To see what's happened: Executions tab (shows every run + any errors).
 */

const MARKER = '<!--CLAUDE-AUTO-SEND-V1-->';
const MAX_SENDS_PER_RUN = 10;  // Safety cap

function processClaudeAutoSendDrafts() {
  const drafts = GmailApp.getDrafts();
  let sentCount = 0;

  for (const draft of drafts) {
    if (sentCount >= MAX_SENDS_PER_RUN) {
      Logger.log(`Hit MAX_SENDS_PER_RUN cap (${MAX_SENDS_PER_RUN}). Stopping early.`);
      break;
    }

    const message = draft.getMessage();
    const htmlBody = message.getBody();  // raw HTML

    if (htmlBody.includes(MARKER)) {
      const subject = message.getSubject();
      const to = message.getTo();

      try {
        draft.send();
        sentCount++;
        Logger.log(`✅ Sent: "${subject}" to ${to}`);
      } catch (err) {
        Logger.log(`❌ Failed to send "${subject}" to ${to}: ${err.toString()}`);
      }
    }
  }

  if (sentCount > 0) {
    Logger.log(`Run complete. Sent ${sentCount} draft(s).`);
  }
}
