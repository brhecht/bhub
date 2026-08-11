/**
 * claude-auto-send.gs — Auto-sends flagged Gmail drafts.
 *
 * TWO independent send paths, run by ONE time-driven trigger (every 5 min) on
 * processClaudeAutoSendDrafts:
 *   1. COMMS (processCommsAutoSend): drafts flagged with the token
 *      [[CLAUDE-AUTO-SEND-V1]] in the SUBJECT. The token is stripped before send
 *      so the recipient never sees it. Subject is used (not an HTML-comment body
 *      marker) because Gmail strips HTML comments when it saves a draft — that
 *      was the July-2026 bug that silently broke comms auto-send.
 *   2. BRIEFING: the Priority Startup Intel daily briefing (subject starts with
 *      'Priority Startup Intel' or carries the legacy MARKER), deduped one per
 *      subject per day, lock drafts skipped.
 *
 * ---------------------------------------------------------------------------
 * FIXED 2026-08-11 — the "sometimes sends, sometimes abandons in drafts" bug.
 *
 * The old comms path did:
 *     draft.update(to, cleanSubject, ...).send()
 * update() stripped the token from the subject BEFORE send() ran. If send()
 * then threw for any reason — quota, transient Gmail error, a malformed
 * recipient — the catch swallowed it and the draft was left sitting in Drafts
 * with a CLEAN subject. No token meant the script could never see it again.
 * One transient failure equalled permanent, silent abandonment. That is why
 * delivery looked random.
 *
 * Now: the token is only given up on success. On failure the token is put back
 * so the next 5-minute run retries. After MAX_ATTEMPTS the draft is marked
 * [[AUTOSEND-FAILED]] so it stops looping and becomes VISIBLE in Drafts, and a
 * best-effort alert is emailed. Nothing fails silently any more.
 * ---------------------------------------------------------------------------
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
const FAILED_TOKEN = '[[AUTOSEND-FAILED]]';
const MAX_ATTEMPTS = 3;
const ALERT_TO = 'brhnyc1970@gmail.com';

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
    if (subject.indexOf(FAILED_TOKEN) !== -1) continue;  // already given up on
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
    if (alreadySent(subject)) { Logger.log('Already sent, skipping: ' + subject); continue; }
    try {
      bySubject[subject].draft.send();
      Logger.log('Sent: ' + subject);
    } catch (err) {
      // The briefing path never rewrites the subject, so it retries naturally
      // on the next run. Just make the failure visible.
      Logger.log('Failed: ' + err.toString());
      alertFailure('briefing', subject, err);
    }
  }
}

// Comms auto-send. NOTE the update() signature: (recipient, subject, PLAIN body,
// options). The plain body MUST be the 3rd positional arg — passing the options
// object there sends the literal string "[object Object]" as the body.
function processCommsAutoSend() {
  const props = PropertiesService.getScriptProperties();
  const drafts = GmailApp.getDrafts();

  for (let i = 0; i < drafts.length; i++) {
    const draft = drafts[i];

    let msg, subject, draftId;
    try {
      msg = draft.getMessage();
      subject = msg.getSubject() || '';
      draftId = draft.getId();
    } catch (e) {
      Logger.log('Comms: unreadable draft, skipping: ' + e);
      continue;
    }

    if (subject.indexOf(SUBJECT_TOKEN) === -1) continue;

    const cleanSubject = subject.replace(SUBJECT_TOKEN, '').trim();

    // Snapshot everything BEFORE any mutation, so we can restore on failure.
    const to = msg.getTo();
    const cc = msg.getCc();
    const bcc = msg.getBcc();
    const plain = msg.getPlainBody() || '';
    const html = msg.getBody() || '';
    const opts = { htmlBody: html, cc: cc, bcc: bcc };

    // Don't double-send if a previous run actually delivered before failing.
    if (alreadySent(cleanSubject)) {
      Logger.log('Comms already sent, clearing token: ' + cleanSubject);
      try { draft.update(to, cleanSubject, plain, opts); } catch (e) {}
      props.deleteProperty('fail:' + draftId);
      continue;
    }

    const failKey = 'fail:' + draftId;
    let fails = parseInt(props.getProperty(failKey) || '0', 10);

    try {
      // Strip the token and send. If send() throws, the catch puts it back —
      // this ordering is the whole point of the 2026-08-11 fix.
      draft.update(to, cleanSubject, plain, opts);
      draft.send();
      props.deleteProperty(failKey);
      Logger.log('Comms sent: ' + cleanSubject);
    } catch (err) {
      fails = fails + 1;
      props.setProperty(failKey, String(fails));
      Logger.log('Comms failed (attempt ' + fails + '): ' + cleanSubject + ' — ' + err);

      if (fails >= MAX_ATTEMPTS) {
        // Give up, but LOUDLY. Mark it so it stops looping and is obvious in Drafts.
        try {
          draft.update(to, FAILED_TOKEN + ' ' + cleanSubject, plain, opts);
        } catch (e) {
          Logger.log('Comms: could not mark failed draft: ' + e);
        }
        props.deleteProperty(failKey);
        alertFailure('comms', cleanSubject, err);
      } else {
        // Put the token back so the next 5-minute run retries this draft.
        try {
          draft.update(to, cleanSubject + ' ' + SUBJECT_TOKEN, plain, opts);
        } catch (e) {
          Logger.log('Comms: could not restore retry token: ' + e);
          alertFailure('comms', cleanSubject, e);
        }
      }
    }
  }
}

// Shared "did this already go out" check. Quoted subjects can break Gmail
// search syntax, so never let a search error look like "not sent".
function alreadySent(subject) {
  try {
    const q = 'in:sent subject:("' + subject.replace(/"/g, '') + '") newer_than:2d';
    return GmailApp.search(q).length > 0;
  } catch (e) {
    Logger.log('alreadySent check failed, assuming not sent: ' + e);
    return false;
  }
}

// Best-effort alert. If sending is what is broken this will also fail, which is
// why the draft is marked in Drafts as well — two independent signals.
function alertFailure(path, subject, err) {
  try {
    GmailApp.sendEmail(
      ALERT_TO,
      'Auto-send FAILED (' + path + '): ' + subject,
      'The Claude Auto-Send script could not deliver this draft after ' +
      MAX_ATTEMPTS + ' attempts.\n\n' +
      'Subject: ' + subject + '\n' +
      'Error: ' + err + '\n\n' +
      'The draft is still in Drafts, marked ' + FAILED_TOKEN + '.\n' +
      'Check script.google.com -> "Claude Auto-Send" -> Executions for detail.'
    );
  } catch (e) {
    Logger.log('Could not send failure alert: ' + e);
  }
}
