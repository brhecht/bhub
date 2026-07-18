/**
 * claude-auto-send.gs — Auto-sends flagged Gmail drafts.
 *
 * TWO independent send paths, run by ONE time-driven trigger (every 5 min) on
 * processClaudeAutoSendDrafts:
 *   1. COMMS (processCommsAutoSend): drafts the comms skill flags with the token
 *      [[CLAUDE-AUTO-SEND-V1]] in the SUBJECT. The token is stripped before send
 *      so the recipient never sees it. Subject is used (not an HTML-comment body
 *      marker) because Gmail strips HTML comments when it saves a draft — that
 *      was the July-2026 bug that silently broke comms auto-send.
 *   2. BRIEFING: the Priority Startup Intel daily briefing (subject starts with
 *      'Priority Startup Intel' or carries the legacy MARKER), deduped one per
 *      subject per day, lock drafts skipped.
 *
 * DEPLOY / UPDATE (the live script runs in Apps Script, NOT from this repo — you
 * must paste this in for changes to take effect):
 *   1. script.google.com -> open the "Claude Auto-Send" project.
 *   2. Select all, delete, paste this file, Save.
 *   3. Triggers (clock icon): ensure ONE time-driven trigger on
 *      processClaudeAutoSendDrafts, Minutes timer, every 5 minutes. That single
 *      trigger now drives BOTH paths (briefing calls comms first each run), so
 *      no separate comms trigger is needed.
 */

const MARKER = '<!--CLAUDE-AUTO-SEND-V1-->';
const SUBJECT_TOKEN = '[[CLAUDE-AUTO-SEND-V1]]';

function processClaudeAutoSendDrafts() {
  // Run the comms pass first; never let a comms error block the briefing.
  try { processCommsAutoSend(); } catch (e) { Logger.log('comms call failed: ' + e); }

  const drafts = GmailApp.getDrafts();
  const bySubject = {};

  // Pass 1: keep the most recent briefing draft per subject; ignore locks.
  for (const draft of drafts) {
    const msg = draft.getMessage();
    const subject = (msg.getSubject() || '').trim();
    if (!subject) continue;
    if (subject.indexOf(SUBJECT_TOKEN) !== -1) continue; // handled by comms pass
    if (subject.indexOf('[LOCK-') !== -1 || subject.indexOf('PSI-LOCK') === 0) continue;
    const isBriefing = subject.indexOf('Priority Startup Intel') === 0 || msg.getBody().indexOf(MARKER) !== -1;
    if (!isBriefing) continue;
    const t = msg.getDate().getTime();
    if (!bySubject[subject] || t > bySubject[subject].time) {
      bySubject[subject] = { draft: draft, time: t };
    }
  }

  // Pass 2: send one per subject, only if not already sent recently.
  for (const subject in bySubject) {
    const already = GmailApp.search('in:sent subject:("' + subject + '") newer_than:2d');
    if (already.length > 0) { Logger.log('Already sent, skipping: ' + subject); continue; }
    try {
      bySubject[subject].draft.send();
      Logger.log('Sent: ' + subject);
    } catch (err) {
      Logger.log('Failed: ' + err.toString());
    }
  }
}

// Comms auto-send. NOTE the update() signature: (recipient, subject, PLAIN body,
// options). The plain body MUST be the 3rd positional arg — passing the options
// object there sends the literal string "[object Object]" as the body.
function processCommsAutoSend() {
  var drafts = GmailApp.getDrafts();
  for (var i = 0; i < drafts.length; i++) {
    try {
      var draft = drafts[i];
      var msg = draft.getMessage();
      var subject = msg.getSubject() || '';
      if (subject.indexOf(SUBJECT_TOKEN) === -1) continue;
      var cleanSubject = subject.replace(SUBJECT_TOKEN, '').trim();
      draft.update(msg.getTo(), cleanSubject, msg.getPlainBody() || '', {
        htmlBody: msg.getBody() || '',
        cc: msg.getCc(),
        bcc: msg.getBcc()
      }).send();
      Logger.log('Comms sent: ' + cleanSubject);
    } catch (err) {
      Logger.log('Comms failed: ' + err.toString());
    }
  }
}
