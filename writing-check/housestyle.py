#!/usr/bin/env python3
"""House-style checker: the parser behind every check in writing-check/.

check_text(text) parses every prose sentence and bullet in a block of markdown and returns the
sentences that break HOUSE-STYLE.md (bhub repo root). Each failing sentence is tagged with one or
more kinds, named after the catalogue entries in that document:

  no-subject        1   a verb with no stated subject ("Pushed.", "Worth knowing", "Want me to?")
  no-verb           2   a claim with no verb ("Still wrong.", "No advantage.")
  count-first       3   a count announced before the things ("Two changes.")
  that-is           4   "That is / This is / It is" pointing at an idea
  not-tail          5   a ", not X" tail, or the flipped "not X, it is Y"
  metaphor-verb     6   an abstract subject with a physical verb from the list
  label-line        7   a noun phrase and a colon where a sentence would go ("So:", "Status: drafted.")
  which-clause      8   ", which is why" / ", which means" hung on a whole clause
  stitch            9   So / And / But opening a sentence after a fragment
  confessional     12   "I want to be honest", "my honest read", "the real answer"
  grade-first      13   "Almost.", "Not quite." opening a reply to a draft
  announced-aside  16   "two things worth naming"
  reveal-opener    17   "Here's where things stand:", "All green."
  trailing-offer   18   the reply ends on "Want me to?", "Let me know!", "Your call?"
  em-dash          19   an em dash in the sentence
  parenthetical    19   an aside in parentheses of fifteen characters or more
  bold-label       20   a bold label, a colon and a fragment; a checkmark and a fragment
  bare-verdict     21   "That's fragile.", "The plan is the plan."
  conduct-report   22   narrating Claude's own good conduct
  numbers-in-prose 23   three or more figures, or two issue identifiers, in one prose sentence
  agreement-opener 24   "You're right", "Fair point", "Good call"
  third-person     27   "Claude" as the speaker's own name

Entries 10, 11, 14, 15, 25 and 26 are not detected mechanically. Headings are never checked.

Usage as a library:   from housestyle import check_text; r = check_text(markdown)
Usage from the shell: housestyle.py < text.md         (prints a JSON report)
                      housestyle.py --strip-quotes < text.md   (drops quoted text first, for
                                                                 text that quotes other people)
"""
import json, re, sys

FIN = {'VBZ', 'VBP', 'VBD', 'MD'}
METAPHOR = re.compile(
    r"\b(sits? (in|on|at|there|between|behind)|sitting (in|on|between)|lives? (in|on|at)|lands?\b(?! (page|line))|landed"
    r"|holds? (a|an|the|two|one|no|every|only|it|them|up|together)|carr(y|ies|ied) (a|an|the|it|that|more|less|your|no)"
    r"|rides? along|surfaces? (it|them|those|the|that|a|an)|stands? as|let stand|load-bearing|backstop|belt and suspenders"
    r"|costs? you|buys? you|earns? its keep|(is|are|was|were) doing (the|more) work|doing the heavy lifting"
    r"|carries the argument|pulls? its weight|announced itself|holding pen|doing the job of|left a souvenir"
    r"|the (move|ask|lift)\b(?! (to|of|for|from|was|is)\b)|blast radius)\b", re.I)
CONFESSIONAL = re.compile(
    r"(^(to be )?(honest|honestly|candidly|frankly|genuinely)\b|\b(my|the) (honest|real|straight|candid) (read|answer|position|estimate|take|view)\b"
    r"|\bI (want|would like|'d like|need) to be (honest|straight|clear|candid|upfront)\b|\bI would rather be straight\b|\bthe real answer is\b"
    r"|\b(honestly|genuinely|candidly|frankly), )", re.I)
GRADE_FIRST = re.compile(r"^(Almost|Not quite|Close, but|Close\.|Better, but|Yes, and worse)[,.!]?\s", re.I)
ANNOUNCED = re.compile(
    r"\b(one|two|three|four|several|a few|a couple of) (more |other |small |structural )?(things?|points?|notes?|items?|observations?) "
    r"(worth|to) (naming|noting|knowing|flagging|mentioning|your attention|keep in mind)\b|\bworth (naming|noting|flagging|mentioning)\b", re.I)
REVEAL = re.compile(r"^(Here'?s|Here is) (where|what|the|how|why)\b|^(All green|Ingested|Located|Confirmed|Verified|Done|Sorted)\.$", re.I)
TRAILING = re.compile(
    r"^(Want me to|Shall I|Should I|Would you like me to|Happy to|Let me know|Just say the word|Say the word)\b|\bYour call\?$|\bLet me know!?$", re.I)
AGREEMENT = re.compile(r"^(You'?re right|You are right|Fair point|Fair enough|Good call|Good catch|Good question|Ha\.|Ha,|Yes, and worse)\b", re.I)
VERDICT = re.compile(
    r"^(That|This|It)('s| is) (fragile|a problem|fine|the (easy|hard) (half|part)|a real \w+|by design|the move|the whole point|the tell)\.?$"
    r"|^(The|Your) (?P<n>\w+) is (the|your) (?P=n)\.?$", re.I)
CONDUCT = re.compile(
    r"\b(nothing else was (changed|touched|edited)|my (chrome )?tab is closed|rather than edit|no locks left behind"
    r"|I (left|did not touch) (it|that|them) alone|without touching anything else|I did not (overstep|go further))\b", re.I)
THIRD_PERSON = re.compile(r"(?<!'s )(?<!his )(?<!your )(?<!my )(?<!own )(?<!other )\bClaude's (job|call|role|problem|turn)\b|(?<!'s )(?<!his )(?<!your )(?<!my )\bClaude (interviews|handles|asks|tells|reads|writes|drafts) (you|your)\b")
STAMPS = {'done', 'confirmed', 'verified', 'ingested', 'located', 'sorted', 'fixed', 'pushed', 'shipped', 'merged', 'deployed', 'noted', 'agreed', 'checked', 'handled', 'understood'}
WHICH = re.compile(r", which (is why|means|is what|is how|is the (reason|point|part)|matters)\b", re.I)
LABEL_START = re.compile(r"^(So|Real answer|Net|Bottom line|Short version|Upshot|TL;DR|The notable finding|Status|Next|Done|Not done|Mode|Directionality|Result|Verdict|Plainly, what I meant|In short)\s*:", re.I)
COUNT_WORDS = r"(one|two|three|four|five|six|seven|eight|nine|ten|several|a few|a couple of|\d+)"
NUMBERS = re.compile(r"\b\d[\d,.:/%]*\b")
IDENTS = re.compile(r"\b[A-Z]{2,5}-\d{1,5}\b")
BOLD_LABEL = re.compile(r"^(\*\*[^*]{1,60}:\*\*|\*\*[^*]{1,60}:[^*]{0,80}\*\*$|[✅❌⚠️🟢🔴🟡✔︎✔️☑️]\s)")
FLIPPED_NOT = re.compile(r"\b(is|are|was|were|'s)\s?n[o']t\b[^,.;]{1,60}, (it|that|this|they|he|she) (is|are|was|were|'s)\b", re.I)
EMDASH = '—'
MARK = '⟂'   # stands in for an em dash while the sentence is parsed

_nlp = None
def nlp():
    global _nlp
    if _nlp is None:
        import spacy
        _nlp = spacy.load('en_core_web_sm')
    return _nlp

def strip_quotes(t):
    """Drop quoted material: lines starting with '>' and runs of six or more words in quotation marks."""
    t = re.sub(r'^\s*>.*$', '', t, flags=re.M)
    t = re.sub(r'["“](?:[^"”]+\s){5,}[^"”]*["”]', '', t)
    return t

def clean(t):
    t = re.sub(r'```.*?```', '', t, flags=re.S)
    t = re.sub(r'^\s*\|.*$', '', t, flags=re.M)
    t = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', t)
    t = re.sub(r'`([^`]*)`', r'\1', t)
    return t.replace(EMDASH, f' {MARK} ')

def units(text):
    """Split markdown into (ctx, raw_line, body) units: a paragraph, a bullet, a heading or a label."""
    out = []
    for block in re.split(r'\n\s*\n', clean(text)):
        buf = []
        for line in block.split('\n'):
            line = line.strip()
            if not line: continue
            bare = re.sub(r'\*\*', '', line)
            if re.match(r'^(#{1,4}\s|[-*]\s+|\d+\.\s+)', bare) or (bare.endswith(':') and len(bare.split()) <= 8):
                if buf: out.append(' '.join(buf)); buf = []
                out.append(line)
            else:
                buf.append(line)
        if buf: out.append(' '.join(buf))
    for raw in out:
        raw = raw.strip()
        if not raw: continue
        bare = re.sub(r'\*\*', '', raw)
        ctx = 'prose'
        if re.match(r'^#{1,4}\s', bare): ctx = 'heading'; bare = re.sub(r'^#+\s*', '', bare)
        elif re.match(r'^([-*]|\d+\.)\s+', bare):
            ctx = 'bullet'; bare = re.sub(r'^([-*]|\d+\.)\s+', '', bare); raw = re.sub(r'^([-*]|\d+\.)\s+', '', raw)
        elif bare.endswith(':') and len(bare.split()) <= 8: ctx = 'label'
        yield ctx, raw, bare

def split_sentences(para):
    for s in re.split(r'(?<=[.!?])\s+(?=[A-Z"“(])', para):
        s = s.strip()
        if 1 <= len(s.split()) <= 90: yield s

def finite(d):
    return [t for t in d if t.tag_ in FIN or (t.pos_ == 'AUX' and t.tag_ != 'VB')]

def is_imperative(s):
    """True when the sentence is an instruction: "Build the installer." "Check this before 7." """
    d = nlp()(s)
    toks0 = [t for t in d if not t.is_punct and not t.is_space]
    root = [t for t in d if t.dep_ == 'ROOT'][0]
    subj = [t for t in d if t.dep_ in ('nsubj', 'nsubjpass', 'csubj', 'csubjpass', 'expl')]
    if root.pos_ == 'VERB' and root.tag_ == 'VB' and not subj: return True
    first = s.split()[0]
    low = first.lower().strip('.,!?')
    # A participle or "Worth"/"Want" at the start is a dropped subject, never an instruction.
    if toks0 and toks0[0].tag_ in ('VBN', 'VBD', 'VBG'): return False
    if low in ('worth', 'want', 'wanted', 'found') or low.endswith('ed') or low.endswith('ing'): return False
    # spaCy often tags a sentence-initial verb as a noun ("Build Nico's installer" -> NN). Re-parse with a
    # subject supplied; if the first word becomes a base-form verb, the original was an imperative.
    if first[0].isupper() and first.isalpha():
        d2 = nlp()('You should ' + first.lower() + s[len(first):])
        toks = [t for t in d2 if not t.is_space]
        if len(toks) > 2 and toks[2].tag_ == 'VB' and toks[2].pos_ in ('VERB', 'AUX'): return True
    return False

def classify(s, prev_failed=False, is_last=False):
    """Return the list of kinds the sentence breaks, primary first. Empty list = clean."""
    kinds = []
    s = s.replace(EMDASH, f' {MARK} ')
    has_dash = MARK in s
    s_parse = re.sub(rf'\s*{MARK}\s*', ', ', s)
    d = nlp()(s_parse)
    toks = [t for t in d if not t.is_punct and not t.is_space]
    if not toks: return kinds
    first = toks[0].lower_
    if len(toks) == 1:
        # One-word stamps: "Pushed." "Done." A one-word noun ("Tuesday.") is a direct answer and passes.
        if toks[0].tag_ in ('VBN', 'VBD', 'VBG') or first in STAMPS or first.endswith('ed'): kinds.append('no-subject')
        return kinds
    root = [t for t in d if t.dep_ == 'ROOT'][0]
    fin = finite(d)
    subj = [t for t in d if t.dep_ in ('nsubj', 'nsubjpass', 'csubj', 'csubjpass', 'expl')]
    root_subj = [t for t in subj if t.head == root]
    if not fin and root.pos_ == 'VERB' and root.tag_ == 'VB' and root_subj:
        fin = [root]   # a plural present-tense verb ("instructions import the file") is tagged as base form
    if not fin and len(toks) >= 5:
        # The small model sometimes reads a clause as a noun phrase ("his instructions import the file").
        # Embed it under a verb of saying; if a finite verb then appears inside the clause, there is one.
        d2 = nlp()('I think that ' + s_parse[0].lower() + s_parse[1:])
        if any(t.tag_ in FIN for t in list(d2)[3:]): fin = ['embedded']
    # Group A, entries 1 to 3: missing subject, missing verb, count first.
    if not fin and not is_imperative(s_parse):
        if re.match(rf'^{COUNT_WORDS} ', s_parse, re.I): kinds.append('count-first')
        elif root.pos_ in ('VERB', 'AUX') and root.tag_ in ('VBN', 'VBD', 'VBG'): kinds.append('no-subject')
        elif root.lemma_ == 'worth' or first in ('want', 'worth'): kinds.append('no-subject')
        else: kinds.append('no-verb')
    elif first in ('want', 'worth') and not root_subj: kinds.append('no-subject')
    elif not subj and toks[0].pos_ in ('VERB', 'AUX') and toks[0].tag_ in ('VBD', 'VBN', 'VBG') and not is_imperative(s_parse):
        kinds.append('no-subject')   # "Found the memo on the Composio stack."
    elif re.match(rf'^{COUNT_WORDS} ', s_parse, re.I) and root.pos_ == 'NOUN': kinds.append('count-first')
    # Entry 4. The antecedent cannot be read mechanically, so three shapes are let through: past tense
    # ("That was my mistake"), a possessive complement ("That is my job"), and "It is" + adjective
    # ("It is small and pleasant"), which describe a thing just named rather than an idea.
    if first in ('that', 'this', 'it') and toks[0].dep_.startswith('nsubj') and toks[0].head.lemma_ == 'be':
        head = toks[0].head
        comp = [c for c in head.children if c.dep_ in ('attr', 'acomp', 'advmod', 'advcl', 'prep', 'ccomp', 'xcomp', 'npadvmod')]
        acomp = any(c.dep_ == 'acomp' for c in comp)
        poss = any(c.dep_ == 'attr' and any(g.dep_ == 'poss' for g in c.children) for c in comp)
        if head.tag_ != 'VBD' and comp and not poss and not (acomp and first == 'it'):
            kinds.append('that-is')
    # Entry 5, both forms.
    m = re.search(r', (not|never) ([^,]+)$', s_parse.rstrip('.!?'))
    if m and not finite(nlp()(m.group(2))): kinds.append('not-tail')
    elif FLIPPED_NOT.search(s_parse): kinds.append('not-tail')
    # Entry 6.
    if METAPHOR.search(s_parse): kinds.append('metaphor-verb')
    # Entry 7: a label at the start of a sentence, or a short colon line with no verb (handled by the caller for ctx label).
    if LABEL_START.match(s_parse): kinds.append('label-line')
    # Entry 8.
    if WHICH.search(s_parse): kinds.append('which-clause')
    # Entry 9.
    if prev_failed and re.match(r'^(So|And|But)\b', s_parse): kinds.append('stitch')
    # Group B.
    if CONFESSIONAL.search(s_parse): kinds.append('confessional')
    if GRADE_FIRST.match(s_parse): kinds.append('grade-first')
    if ANNOUNCED.search(s_parse): kinds.append('announced-aside')
    if REVEAL.match(s_parse): kinds.append('reveal-opener')
    if is_last and TRAILING.search(s_parse): kinds.append('trailing-offer')
    if has_dash: kinds.append('em-dash')
    if re.search(r'\([^)]{15,}\)', s_parse): kinds.append('parenthetical')
    if VERDICT.match(s_parse): kinds.append('bare-verdict')
    if CONDUCT.search(s_parse): kinds.append('conduct-report')
    if AGREEMENT.match(s_parse): kinds.append('agreement-opener')
    if THIRD_PERSON.search(s_parse): kinds.append('third-person')
    return kinds

def check_text(text, strip_quoted=False, surface='code'):
    """Check a block of markdown. Returns a dict with counts and the failing items."""
    if strip_quoted: text = strip_quotes(text)
    prose_n = prose_fail = bullet_n = bullet_fail = 0; items = []
    seq = []   # (ctx, raw, sentence) in reading order, so "last sentence" and "previous failed" are known
    for ctx, raw, bare in units(text):
        if ctx == 'heading': continue
        if ctx == 'label':
            seq.append((ctx, raw, bare)); continue
        for i, s in enumerate(split_sentences(bare)):
            seq.append((ctx, raw if i == 0 else '', s))
    prev_failed = False
    for idx, (ctx, raw, s) in enumerate(seq):
        is_last = idx == len(seq) - 1
        kinds = []
        if ctx == 'label':
            if not finite(nlp()(s.rstrip(':'))) and not re.match(r'^(#|\d+\.)', s): kinds = ['label-line']
            ctx_count = 'prose'
        else:
            kinds = classify(s, prev_failed=prev_failed, is_last=is_last)
            ctx_count = ctx
            if raw and BOLD_LABEL.match(raw): kinds.append('bold-label')
            if ctx == 'prose' and (len(NUMBERS.findall(s)) >= 3 or len(IDENTS.findall(s)) >= 2): kinds.append('numbers-in-prose')
        if ctx_count == 'prose': prose_n += 1
        else: bullet_n += 1
        if kinds:
            if ctx_count == 'prose': prose_fail += 1
            else: bullet_fail += 1
            items.append({'ctx': ctx_count, 'kind': kinds[0], 'kinds': kinds, 's': s[:220]})
        prev_failed = bool(kinds) and kinds[0] in ('no-subject', 'no-verb', 'count-first', 'label-line')
    words = len(text.split())
    return {'surface': surface, 'words': words, 'prose': prose_n, 'prose_fail': prose_fail,
            'bullets': bullet_n, 'bullet_fail': bullet_fail, 'long': words > 300, 'items': items,
            'ok': not items}

def note_for(r, what='your last reply'):
    """The short message handed back to Claude."""
    lines = [f"Writing check on {what}: {r['prose_fail']} of {r['prose']} prose sentences and {r['bullet_fail']} of {r['bullets']} bullets broke HOUSE-STYLE.md. Say the point; do not write about it. Every sentence needs a subject that exists and a literal verb."]
    for it in r['items'][:8]:
        lines.append(f"- [{'/'.join(it['kinds'])}] {it['s']}")
    if r.get('long') and what == 'your last reply':
        lines.append(f"- [length] The reply ran {r['words']} words. A report that long goes in a file, with three sentences in the reply.")
    return '\n'.join(lines)

if __name__ == '__main__':
    # housestyle.py [--strip-quotes] [--log SURFACE] [--session NAME] < text
    # --log appends the result to ~/.claude/writing-check/log.jsonl under that surface, so the Sunday
    # review counts it (the Linear sweep uses --log linear-sweep).
    import os, datetime
    args = sys.argv[1:]
    surface = args[args.index('--log') + 1] if '--log' in args and args.index('--log') + 1 < len(args) else None
    session = args[args.index('--session') + 1] if '--session' in args and args.index('--session') + 1 < len(args) else 'cli'
    text = sys.stdin.read()
    r = check_text(text, strip_quoted='--strip-quotes' in args, surface=surface or 'cli')
    if surface:
        base = os.path.join(os.path.expanduser('~'), '.claude', 'writing-check'); os.makedirs(base, exist_ok=True)
        rec = {'ts': datetime.datetime.now().isoformat(timespec='seconds'), 'session': session, 'surface': surface, 'words': r['words'],
               'prose': r['prose'], 'prose_fail': r['prose_fail'], 'bullets': r['bullets'], 'bullet_fail': r['bullet_fail'], 'mode': 'sweep', 'items': r['items']}
        with open(os.path.join(base, 'log.jsonl'), 'a') as fh: fh.write(json.dumps(rec, ensure_ascii=False) + '\n')
    print(json.dumps(r, ensure_ascii=False, indent=1))
