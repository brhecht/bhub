---
name: slate
description: >
  Generates a slate of genuinely non-obvious options, tactics, plays, or bets — the anti-mode-collapse generation process. Use whenever Brian asks for options in any plural form: "give me 10 ways to...", "what are my options", "how do I get X to Y", "ideas for...", "what should I do about...", "what am I missing", "/slate", "/what-did-i-miss". Also fires when Brian is about to pick a direction and only has one or two candidates on the table, or when a previous answer came back obvious, derivative, or mis-scaled and he pushes back. NOT for research questions with a findable answer (use `expert`), NOT for stress-testing a decision he has already made (use `grill-me`), NOT for drafting (use `create-content`). The job is not coverage of the option space. Coverage is what a list gives you. The job is options his own frame does not already contain.
---

# /slate

Brian does not need more options. He needs options he would not have written himself.

This skill exists because of a diagnosed, repeated failure: he asks for ten tactics, gets ten samples from the same center of the distribution, recognizes all of them, proposes something of his own, and Claude elaborates it into a plan. Three defects produce that: **mode-collapsed generation** (raising N draws more samples, not more diversity), **anchoring** (everything generated after the conversation is downstream of the conversation), and **premature agreement** (his idea arrives before the scoring criteria, so elaboration is the default).

The fix is a process, not a rule. Run all seven phases. Skipping Phase 1 or Phase 3 turns this back into a list.

---

## The success test, stated up front

**A run succeeds only if at least two delivered options are things Brian would not have produced himself in ten minutes.** Not "well organized." Not "comprehensive." Net-new.

Reflecting his own thinking back at him, however well structured, is a failed run. So is a slate where every item is defensible — that means nothing was staked.

If a run fails this test, say so at the top of the delivery. "Six options, none of which are outside your frame; here is why the frame may be the binding constraint" is a more useful answer than eight items he already knows.

---

## Phase 0 — Load and declare (before generating a single word)

1. **Say which documents you are treating as live.** If a strategy repo is in play, read its `CANON.md` first. Name the LIVE docs, name what you are excluding and why. Never build on a SUPERSEDED or DEAD doc silently.
2. **State the constraint set.** Hard constraints (violating one disqualifies an option on contact), soft constraints (cost points, do not disqualify), and resources actually available. Get these from the record, not from assumption. Where a constraint is inferred rather than stated, mark it and ask.
3. **State the scoring rubric before generating.** must / should / nice. Say what "must" means for this specific question. This has to be on the page before any option is, so that a good idea arriving later gets scored rather than elaborated.
4. **Verify the baseline against live data, not documents.** Member counts, follower counts, revenue, dates — pull the real number. Strategy docs go stale within weeks. A slate built on a stale baseline is mis-scaled by construction, which is one of the three original complaints.

**Never open a held-out evaluation file** (e.g. `HELD-OUT-DO-NOT-READ-*`) during a generation run. Reading it contaminates the test. Open it only when Brian explicitly asks for a run to be scored.

---

## Phase 1 — Attack the frame

Do this before options exist. The July 28 post-mortem found that the partition had been drawn *inside* the frame, which yields coverage, not novelty. Coverage of the wrong space is a well-organized wrong answer.

Produce **three to five frame attacks**. Each must be a specific claim, not a question. Required kinds:

- **The metric attack.** The stated number may be a proxy. What is it a proxy for, and is there a cheaper or faster path to the real thing? Name the substitute metric.
- **The constraint attack.** Pick the constraint doing the most work and argue it is softer than stated, or harder. One of the two. Do not hedge.
- **The denominator attack.** The goal assumes a pool. Is the pool the right pool? Is it big enough for the arithmetic to work at all? Do the division.
- **The inversion.** What would make the goal unnecessary, or make hitting it a bad outcome? Steelman the case for not pursuing it.
- **The timing attack.** Why this window? What changes if it slips, or if it is pulled forward hard?

Deliver the frame attacks, then proceed on the stated frame anyway, with the attacks flagged. Do not stop and wait — a frame attack that blocks the work becomes a reason not to run the skill.

---

## Phase 2 — Partition into structurally distinct classes

Do not sample the same idea N times. Partition first, name the classes, then generate one per class.

**The test for whether two options are in the same class: would the same failure kill both?** If yes, same class, and only one of them ships. This is sharper than topical grouping — "post on LinkedIn" and "post on X" are one class, because "Brian's posting does not convert at this scale" kills both.

Aim for **five to eight classes**. Six forced-distinct beats ten free-form. Never raise the class count to manufacture variety; if only four genuinely distinct mechanisms exist, say four and say why.

Name each class by its **mechanism**, not its channel. "Third-party distribution borrowed from someone with a bigger list" is a mechanism. "Newsletter" is a channel.

---

## Phase 3 — Blind parallel generation (the load-bearing phase)

Spawn **one subagent per class, in a single message so they run concurrently.** Blindness is the point: anything generated inside this conversation is downstream of this conversation.

Each subagent receives:
- the goal and the arithmetic (from → to, by when, the implied rate)
- the hard constraints, verbatim
- **its class, and only its class**
- its assigned lens (below)

Each subagent must NOT receive:
- the conversation history
- the other classes or any other agent's output
- Brian's prior ideas, the existing plan, or the strategy docs' recommendations
- anything about what has been tried before

**Every subagent returns exactly two options:**

1. **The sane one.** Best play in its class within the constraints.
2. **The staked one.** Deliberately extreme: too aggressive, too weird, an order of magnitude off, or violating a soft norm. Required, not optional.

The staked option is not filler. Every genuine input in the July 28 session came from Claude being *specifically wrong* in a way Brian could correct. A specific wrong answer is a better instrument than a vague right one, because it gives him something to push against. An agent that returns two sane options has failed its brief; re-run it.

**Assign divergent lenses** — one per agent, drawn from different disciplines so the priors differ:

- the operator who has done this exact thing at 10x the scale
- the person with the opposite constraint (unlimited budget, zero time; or zero budget, unlimited time)
- the adversary who wants this to fail, run in reverse
- the arithmetic lens: what single variable has to move, and by how much
- the anthropologist: why do people actually join things, ignoring the stated reason
- the arbitrage lens: what asset is already owned and underused
- the systems lens: what makes the next unit cheaper than the last one

---

## Phase 4 — Adversarial kill pass

Collect every option. Run a **second wave of blind subagents whose only job is to kill them** against the hard constraints and the real resource picture. Default to killed when uncertain. An option survives only if the killer could not land a clean hit.

Deduplicate against the *full* set of options seen, not against the survivors — otherwise killed ideas reappear each round and nothing converges.

---

## Phase 5 — Score, rank, mark

For each survivor:

- **Score: must / should / nice.** Same rubric stated in Phase 0. No separate scheme.
- **Every number, date, price, headcount marked DECIDED or ASSUMED.** DECIDED means Brian chose it. ASSUMED means it was filled in to make the option concrete. An invented figure must never read as a commitment. Never quote an ASSUMED figure externally.
- **Every recommendation labeled proven or bet.** If a bet: what would have to be true, and the cheapest way to learn it.
- **A kill criterion on anything that becomes the plan.** What would prove it wrong, and by when. No kill criterion, not a plan.
- **Effort in Brian's real currency.** His limit is energy and dopamine, not calendar hours. An option that costs three hours of something he avoids is more expensive than one costing eight hours of something he likes. Price it that way.

---

## Phase 6 — The originality gate

Before delivering, go through the ranked list and mark each item:

- **KNOWN** — Brian would have written this himself in ten minutes.
- **ADJACENT** — he would have gotten here with a nudge.
- **NET-NEW** — outside his stated frame.

**Move everything KNOWN into an appendix labeled "table stakes, listed so you know it was considered."** It does not go in the body. The body leads with NET-NEW, then ADJACENT.

If fewer than two items are NET-NEW, say so explicitly at the top. Do not pad the body to hide a thin result.

---

## Phase 7 — Deliver

Order:

1. **The arithmetic.** From → to, by when, the implied rate versus the trailing rate. One line. This is what prevents mis-scaled options, the third original complaint.
2. **Frame attacks** (Phase 1), each one sentence.
3. **The recommendation**, if one is warranted — ranked, with its kill criterion.
4. **The slate**, grouped by class, NET-NEW first, each with score, DECIDED/ASSUMED marks, proven/bet, and effort in energy terms.
5. **The staked options**, kept as a visible section titled honestly. Do not quietly drop them; being wrong on the record is the instrument.
6. **Table stakes appendix.**
7. **What this run did not cover** — modality not run, class not generated, claim not verified. Silent truncation reads as completeness.

Write plainly. No metaphor standing in for a concrete detail. No em dashes. No "signal," "noise," "the move," "unlock," "lean in," "high-signal," "space," "room."

---

## After delivery: the anti-sycophancy rule stays on

The skill does not end when the slate lands. Brian's characteristic next move is to propose something of his own.

**When he does: score it against the Phase 0 rubric and rank it against the existing options before elaborating a single word.** If it does not beat what is on the table, say so and say why. If it is a variant of a class already killed in Phase 4, say that and cite the kill.

Agreement that elaborates without challenging is a failure of this skill. Do not capitulate to his frame; where it is wrong or internally inconsistent, show why and steelman both sides. Where he is rationalizing, name it.

Watch for his named patterns forming and call them by name: chasing the interesting over the important, piling up half-done work by starting new things before closing open ones, building tooling instead of the business, canonizing half-formed ideas as settled, rationalizing scope creep as leverage.

---

## Scaling

| Ask | Classes | Agents per class | Kill pass |
|---|---|---|---|
| Quick ("a few ideas for X") | 3-4 | 1 | inline, no subagents |
| Standard | 5-6 | 1 | 1 blind killer per option |
| Consequential (a quarter, a launch, a number he will commit to) | 6-8 | 1, plus a completeness critic at the end | 2-3 blind killers, majority kills |

The completeness critic gets the full slate and one question: what class of mechanism was never generated? Whatever it names becomes one more round.

---

## Never

- Never raise the item count to manufacture variety.
- Never deliver a slate where every option is defensible.
- Never let a generated number read as a commitment.
- Never open a held-out eval file during a run.
- Never put a KNOWN item in the body.
- Never elaborate his mid-conversation idea before ranking it.
