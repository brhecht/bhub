/**
 * claude-auto-send.gs — Auto-sends Gmail drafts flagged by the comms skill.
 *
 * DETECTION: a token in the SUBJECT line — [[CLAUDE-AUTO-SEND-V1]].
 *
 * Why the subject (and not an HTML comment in the body, like the old version):
 * Gmail strips HTML comments (<!-- ... -->) when it SAVES a draft, so the old
 * body marker silently disappeared and drafts never matched — that's the bug
 * that broke auto-send. The subject line is the one field Gmail never rewrites,
 * so detection there is bulletproof. The script removes the token before
 * sending, so the recipient never sees it.
 *
 * DEPLOY / UPDATE (the live script runs in Apps Script, NOT from the repo — you
 * must paste this in for changes to take effect):
 *   1. Go to script.google.com and open the auto-send project.
 *   2. Select all existing code, delete it, paste this file in full, and Save.
 *   3. Confirm the time trigger still exists: Triggers (clock icon) ->
 *      there should be one for processClaudeAutoSendDrafts, Time-driven,
 *      Minutes timer, Every 5 minutes. If not, add it.
 *   4. (First time only) approve the Gmail permissions prompt.
 */

const SUBJECT_TOKEN = '[[CLAUDE-AUTO-SEND-V1]]';
// Safety net: also fire if this literal string appears as real body text
// (NOT as an HTML comment — those get stripped). Lets old/alternate drafts work.
const BODY_FALLBACK = 'CLAUDE-AUTO-SEND-V1';

function processClaudeAutoSendDrafts() {
  const drafts = GmailApp.getDrafts();
  for (const draft of drafts) {
    try {
      const msg = draft.getMessage();
      const subject = msg.getSubject() || '';
      const body = msg.getBody() || '';

      const hasSubjectToken = subject.indexOf(SUBJECT_TOKEN) !== -1;
      const hasBodyToken = body.indexOf(BODY_FALLBACK) !== -1;
      if (!hasSubjectToken && !hasBodyToken) continue;

      if (hasSubjectToken) {
        // Strip the token (and any trailing whitespace) so the recipient never
        // sees it, then rebuild the draft preserving To/Cc/Bcc and body.
        const cleanSubject = subject.replace(SUBJECT_TOKEN, '').replace(/\s+$/, '').trim();
        const updated = draft.update(msg.getTo(), cleanSubject, {
          htmlBody: body,
          cc: msg.getCc(),
          bcc: msg.getBcc()
        });
        updated.send();
        Logger.log('Sent (subject-token): ' + cleanSubject);
      } else {
        // Body-fallback path: token is plain text in the body; just send as-is.
        draft.send();
        Logger.log('Sent (body-fallback): ' + subject);
      }
    } catch (err) {
      Logger.log('Failed: ' + err.toString());
    }
  }
}
