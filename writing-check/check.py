#!/usr/bin/env python3
"""Writing check for Claude's replies to Brian. Runs as a Claude Code Stop hook.

Reads the hook JSON on stdin, finds the last assistant reply in the session transcript,
parses every prose sentence, and records the ones that break WRITING-TO-BRIAN.md:
  no-subject      a verb with no stated subject ("Pushed.", "Worth knowing...", "Want me to...?")
  no-verb         a claim with no verb ("Still wrong.", "Two changes.")
  that-is         a sentence opening "That is / This is / It is" (pronoun standing for an idea)
  not-tail        a sentence ending ", not X" with no verb in the tail
  metaphor-verb   an abstract subject with a physical verb from the spec's list

Advisory mode (default): logs to ~/.claude/writing-check/log.jsonl and writes a pending note
that the UserPromptSubmit hook (feedback.py) shows Claude on the next turn. Exit 0, no delay.
Blocking mode (BRIAN_WRITING_BLOCK=1, for unattended runs): if any prose sentence fails,
returns decision=block so Claude rewrites before the reply is delivered.
"""
import json, os, re, sys, time, datetime
HOME = os.path.expanduser('~')
BASE = os.path.join(HOME, '.claude', 'writing-check')
LOG = os.path.join(BASE, 'log.jsonl')
FIN = {'VBZ', 'VBP', 'VBD', 'MD'}
METAPHOR = re.compile(r"\b(sits? (in|on|at|there|between)|sitting (in|on)|lives? (in|on|at)|lands?\b(?! (page|line))|landed|holds? (a|an|the|two|one|no|every|only|it|them|up|together)|carr(y|ies|ied) (a|an|the|it|that|more|less|your|no)|rides? along|surfaces? (it|them|those|the|that|a|an)|stands? as|let stand|load-bearing|backstop|belt and suspenders|costs? you|buys? you|earns? its keep|(is|are|was|were) doing (the|more) work|doing the heavy lifting|carries the argument|pulls? its weight|announced itself|holding pen|doing the job of)\b", re.I)

def last_reply(transcript_path):
    last = None
    try:
        with open(transcript_path, errors='ignore') as fh:
            for line in fh:
                try: d = json.loads(line)
                except Exception: continue
                if d.get('type') != 'assistant' or d.get('isSidechain'): continue
                m = d.get('message')
                if not isinstance(m, dict): continue
                texts = [b.get('text', '') for b in m.get('content', []) if isinstance(b, dict) and b.get('type') == 'text']
                if any(t.strip() for t in texts): last = '\n'.join(texts)
    except FileNotFoundError:
        return None
    return last

def clean(t):
    t = re.sub(r'```.*?```', '', t, flags=re.S)
    t = re.sub(r'^\s*\|.*$', '', t, flags=re.M)
    t = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', t)
    t = re.sub(r'`([^`]*)`', r'\1', t)
    t = re.sub(r'\*\*', '', t)
    return t.replace('—', ', ')

def sentences(text):
    """Yield (context, sentence). context is prose, bullet, heading or label."""
    # Paragraphs are separated by blank lines. Inside a paragraph, a line that starts with a
    # bullet marker or a heading mark stands alone; other lines are joined, so a hard-wrapped
    # sentence in a file is read as one sentence.
    units = []
    for block in re.split(r'\n\s*\n', clean(text)):
        buf = []
        for line in block.split('\n'):
            line = line.strip()
            if not line: continue
            if re.match(r'^(#{1,4}\s|[-*]\s+|\d+\.\s+)', line) or (line.endswith(':') and len(line.split()) <= 8):
                if buf: units.append(' '.join(buf)); buf = []
                units.append(line)
            else:
                buf.append(line)
        if buf: units.append(' '.join(buf))
    for para in units:
        para = para.strip()
        if not para: continue
        ctx = 'prose'
        if re.match(r'^#{1,4}\s', para): ctx = 'heading'; para = re.sub(r'^#+\s*', '', para)
        elif re.match(r'^([-*]|\d+\.)\s+', para): ctx = 'bullet'; para = re.sub(r'^([-*]|\d+\.)\s+', '', para)
        elif para.endswith(':') and len(para.split()) <= 8: ctx = 'label'
        for s in re.split(r'(?<=[.!?])\s+(?=[A-Z"“(])', para):
            s = s.strip()
            if 2 <= len(s.split()) <= 90: yield ctx, s

def classify(nlp, s):
    d = nlp(s)
    toks = [t for t in d if not t.is_punct and not t.is_space]
    if len(toks) < 2: return None
    root = [t for t in d if t.dep_ == 'ROOT'][0]
    fin = [t for t in d if t.tag_ in FIN or (t.pos_ == 'AUX' and t.tag_ != 'VB')]
    subj = [t for t in d if t.dep_ in ('nsubj', 'nsubjpass', 'csubj', 'csubjpass', 'expl')]
    imperative = root.pos_ == 'VERB' and root.tag_ == 'VB' and not subj
    if not fin and not imperative:
        if root.pos_ in ('VERB', 'AUX') and root.tag_ in ('VBN', 'VBD', 'VBG'): return 'no-subject'
        if root.lemma_ == 'worth' or toks[0].lower_ in ('want', 'worth'): return 'no-subject'
        return 'no-verb'
    if toks[0].lower_ in ('want',) and not subj: return 'no-subject'
    if toks[0].lower_ in ('that', 'this', 'it') and toks[0].dep_.startswith('nsubj') and toks[0].head.lemma_ == 'be': return 'that-is'
    m = re.search(r', (not|never) ([^,]+)$', s.rstrip('.!?'))
    if m and not any(t.tag_ in FIN for t in nlp(m.group(2))): return 'not-tail'
    if METAPHOR.search(s): return 'metaphor-verb'
    return None

def main():
    try: hook = json.load(sys.stdin)
    except Exception: hook = {}
    transcript = hook.get('transcript_path'); session = hook.get('session_id', 'unknown')
    block = os.environ.get('BRIAN_WRITING_BLOCK') == '1' or '--block' in sys.argv
    if hook.get('stop_hook_active') and block: return   # never block twice in a row
    text = last_reply(transcript) if transcript else None
    if not text or len(text.split()) < 15: return        # short acks are not worth checking
    import spacy
    nlp = spacy.load('en_core_web_sm', disable=['ner', 'lemmatizer']) if False else spacy.load('en_core_web_sm')
    prose_n = prose_fail = bullet_n = bullet_fail = 0; items = []
    for ctx, s in sentences(text):
        if ctx in ('heading', 'label'): continue
        kind = classify(nlp, s)
        if ctx == 'prose': prose_n += 1
        else: bullet_n += 1
        if kind:
            if ctx == 'prose': prose_fail += 1
            else: bullet_fail += 1
            items.append({'ctx': ctx, 'kind': kind, 's': s[:220]})
    os.makedirs(BASE, exist_ok=True)
    rec = {'ts': datetime.datetime.now().isoformat(timespec='seconds'), 'session': session, 'surface': 'code',
           'words': len(text.split()), 'prose': prose_n, 'prose_fail': prose_fail, 'bullets': bullet_n,
           'bullet_fail': bullet_fail, 'mode': 'block' if block else 'advise', 'items': items}
    with open(LOG, 'a') as fh: fh.write(json.dumps(rec, ensure_ascii=False) + '\n')
    if not items: return
    lines = [f"Writing check on your last reply: {prose_fail} of {prose_n} prose sentences and {bullet_fail} of {bullet_n} bullets broke WRITING-TO-BRIAN.md. Say the point; do not write about it. Every sentence needs a subject that exists and a literal verb."]
    for it in items[:8]:
        lines.append(f"- [{it['kind']}] {it['s']}")
    note = '\n'.join(lines)
    if block and prose_fail:
        print(json.dumps({'decision': 'block', 'reason': note + '\nRewrite the reply so every sentence states a fact with a stated subject and a literal verb, then send it again.'}))
        return
    with open(os.path.join(BASE, f'pending-{session}.md'), 'w') as fh: fh.write(note + '\n')

if __name__ == '__main__':
    try: main()
    except Exception as e:
        try:
            os.makedirs(BASE, exist_ok=True)
            with open(os.path.join(BASE, 'errors.log'), 'a') as fh: fh.write(f"{datetime.datetime.now().isoformat()} {e!r}\n")
        except Exception: pass
