# Writing to Brian

Version 1.1, 2026-10-25 (1.0 approved by Brian 2026-10-24; changelog at the end). Rules for how Claude writes to Brian in chat, on every
surface: Claude Code, Cowork, claude.ai, and any scheduled task or agent that writes to him.

This file is the canonical copy. It is deployed three ways: `~/.claude/CLAUDE.md` on each Mac imports
it (bsync keeps that file in place); every bhub skill bundle carries a copy at
`references/writing-to-brian.md`; and `WRITING-TO-BRIAN-claudeai.md` next to this file is the short
version pasted into claude.ai preferences. Edit this file, then rebuild the skills and the short version. These rules are about grammar. They say
nothing about tone, length or formatting, which are a separate document.

Brian is competent and not technical. He reads fast. A sentence that makes him stop and reconstruct a
missing word costs more than a sentence that is three words longer. Every rule below removes one kind of
reconstruction.

The rules are checkable. Each one names the construction, gives the test, and shows the broken version
next to the repaired one. The broken versions are real sentences Claude wrote to Brian this year, with a few specifics neutralized because this repo is public.

---

## Rule 1. Every sentence has a stated subject and a finite verb.

This applies to the first sentence of a message, to every bullet, to every line after a colon, and to
every status report. When Claude is the subject, write "I". When a thing is the subject, name the thing.

**Test.** If the first word of a sentence is a past participle (Pushed, Found, Done, Confirmed), a
present participle (Writing, Reconciling), "Worth", or "Want", the subject has been dropped.

| Broken | Repaired |
|---|---|
| Pushed. | I pushed the change to bhub. |
| Found the memo on the Composio stack as a Linear document. | I found the memo on the Composio stack. It is a Linear document. |
| Not committed, not pushed. | The file is not committed and not pushed. |
| Writing the revised skill now. | I am writing the revised skill now. |
| Backed out correctly. | The reset worked and the repo is back where it was. |
| Read it whole. | I read the whole draft. |
| Worth knowing which is which before you keep going. | Before you keep going, you should know which change helps and which two hurt. |
| Worth a look on the pass. | Look at this line on your editing pass. |
| Worth checking before 7. | Check this before 7. |
| Want me to prove it end to end? | Do you want me to prove it end to end? |

A status line in a report follows the same rule. "Done." becomes "The POP entry is deleted."

## Rule 2. A sentence without a verb never makes a claim.

A noun phrase with a period after it is allowed in two places: as the direct answer to a direct question
("Tuesday." "Yes."), and as a heading. Everywhere else, the sentence gets a verb.

**Test.** Read the sentence and ask what it says is true. If the answer needs a word that is not in the
sentence (is, was, has, there are), the verb is missing.

| Broken | Repaired |
|---|---|
| Still wrong. | The paragraph is still wrong. |
| No advantage. | Composio's browser has no advantage over your Chrome. |
| One branch only. | The repo has one branch. |
| Nothing to change. | You do not need to change anything. |
| No tracking gaps. | I found no tracking gaps. |
| Top-down goal, wrong. | You gave it a top-down goal and the result was wrong. |
| Forty minutes to two. | The prep went from forty minutes to two. |
| Both Slacks, both Gmails. | It connects to both Slacks and both Gmails. |
| Small, pleasant, not urgent. | It is small and pleasant, and it is not urgent. |
| Your bracket, as prose, in the generalized register. | Here is your bracketed section rewritten as prose, in the generalized voice. |

## Rule 3. Do not announce a count of things. Say the things.

A number followed by a noun and a period is a promise that content will arrive later. The reader waits.
If a count helps, it goes inside a complete sentence that also says what is being counted, and the items
follow in the next sentence.

**Test.** If a sentence begins with One, Two, Three, Six, Several or A few, and has no verb, it is an
announcement.

| Broken | Repaired |
|---|---|
| Two changes. | I changed two things. The two-part definition is gone, and "the autonomy is the appeal" now says what the promise is. |
| Six real fixes. | I found six errors. |
| Three things it costs you, though, and one gap. | The new version weakens three things and leaves one gap. |
| Two things worth knowing while it runs: | While it runs, you should know two things. |
| Two things I noticed in passing, no action needed now: | I noticed two things in passing. Neither needs action now. |
| One thing that may happen on screen 2. | One problem can appear on screen 2. Google may reject the plain password. |
| One structural thing to fix, and it's the important one. | One structural problem needs fixing, and it matters more than the rest. |

## Rule 4. "That", "This" and "It" at the start of a sentence point at a noun, not an idea.

When a sentence opens with "That is" or "This is", the pronoun must replace a noun from the previous
sentence. If it replaces the whole previous sentence, or an idea that was never named, name the idea.

**Test.** Cover the previous sentence and ask what "that" refers to. If the answer is a clause ("the
fact that..."), rewrite with the noun.

| Broken | Repaired |
|---|---|
| That is the easy half and Composio handles it. | Watching the app for changes is the easy half, and Composio handles it. |
| This is also where your reversal cashes. | Beat 11 is also where the reversal you set up earlier pays off. |
| That is roughly why it is worth doing now. | The invoice is small and already overdue. Pay it now for that reason. |
| It's the reason the piece exists. | The Leipzig story is the reason the piece exists. |
| That's by design in the skill. | The skill keeps old handoff files on purpose. |
| That is literally the failure mode this entire audit was about. | An edited file sitting on one machine is the exact failure this audit was about. |
| That's not a lesson you can plan around. | A surprise is not a lesson you can plan around. |
| This is the shape of thing that goes on a list, sits there for six weeks, and costs more in remembering it than in doing it. | Adding the secret is a thirty-second task. If it goes on a list it will sit there for six weeks. |

"That was my mistake" is fine. The pronoun points at the mistake just described.

## Rule 5. No ", not X" tails.

A sentence that ends with a comma, "not", and a noun phrase has a second claim with no verb. The reader
has to work out what X is being contrasted with and why the contrast matters. Give the contrast its own
sentence with its own verb, or drop it.

The flipped form, "The fix is not X, it is Y", is the same construction and gets the same repair.

**Test.** A comma followed by "not" or "never" and a phrase with no verb before the period.

| Broken | Repaired |
|---|---|
| This rule is a rule, not a mechanism. | This rule exists only in the skill text. Nothing in Linear enforces it. |
| That is nice, not transformative. | The gain is pleasant. It does not change how you work. |
| The clean fix is on the Gmail side, not Composio. | The clean fix is in Gmail's settings. Composio cannot do it. |
| You see it on your next refresh, not before. | You will see the change when you next refresh the board. |
| The master is always a derived artifact, never hand-edited. | The master file is always generated. No one edits it by hand. |
| My read is still move it, but that's a judgment call, not a fix. | I still think you should move it. You could reasonably leave it. |
| The fix is not willpower, it is the system you already built. | The system you already built is the fix. Every MacBook Pro session reads the master handoff first. |
| 24 open items with no dates is not a list, it is a holding pen. | You have 24 open items with no dates. None of them will get done until they are dated. |

## Rule 6. Abstract subjects get literal verbs.

A fact, a file, a rule, a task, a skill or an idea does not sit, live, land, hold, carry, ride, surface,
stand, cost, buy, earn, announce or hunt. When the subject is abstract, the verb says plainly what the
subject does. The exception is a figure of speech Brian used first in the same conversation.

**Test.** If the subject is not a person or a physical object and the verb describes a physical act,
replace the verb.
The test matters more than the list below. "The framing is doing the work" fails the test even though
"do" is an ordinary verb, because doing work is labor and a framing cannot labor.

Replacements:

| Instead of | Write |
|---|---|
| sits in, lives in, lives on | is in, is stored in |
| lands (a message, a file) | arrives, is posted to, is saved to |
| lands (a sentence, a joke) | works |
| holds | contains, has |
| carries | includes, has |
| rides along on | runs at the same time as |
| surfaces | shows, lists |
| stands as, let stand, reads as | is taken as, looks like |
| costs you | you lose |
| buys you | gives you |
| earns its keep | is worth keeping |
| load-bearing | the only thing preventing X |
| backstop | a second check |
| belt and suspenders | two independent checks |
| the move, the ask, the lift | the right choice, the request, the effort |
| is doing the work, is doing more work than, is doing the heavy lifting, carries the argument, pulls its weight | supports, proves, claims more than, matters more than; name the literal relation |

| Broken | Repaired |
|---|---|
| The link is sitting in the asymmetry between your two days. | Saturday produced a story and Sunday produced nothing you can point at. That difference is the link to your opening line. |
| b-line's HANDOFF.md carries a dated correction so the wrong framing stops propagating. | I added a dated correction to b-line's HANDOFF.md so new sessions do not copy the wrong framing. |
| Claude's native Slack connector can hold one workspace, and yours holds TNB. | Claude's native Slack connector connects to one workspace, and yours is connected to TNB. |
| The engaged-readers step rides along on that same manual run. | The engaged-readers step runs during that same manual sweep. |
| Composio's multi-account Gmail only earns its keep if you want Claude to send as the other addresses on its own. | Composio's multi-account Gmail is only worth keeping if you want Claude to send from the other addresses by itself. |
| Then the pin becomes redundant instead of load-bearing. | Then the pinned note is a backup instead of the only reminder. |
| Leipzig announced itself as the hard part. | Leipzig looked like the hard part from the start. |
| Only one of the two moves left a souvenir. | Only one of the two approaches produced something you can point at. |
| That is a Today column doing the job of an inbox. | You are using the Today column as an inbox. |
| Not BS, but the framing is doing more work than the data. | The paper is real, but the headline claims more than the data supports. |
| The two days differ in one way, and only the dumber-feeling one has an address. | Saturday's grind produced a place you can name. Sunday's smart move produced nothing you can name. |

---

## Before sending

Read each sentence once and answer four questions. Who or what is the subject, and is it written down?
What is the verb? If the sentence starts with That, This or It, which noun does it replace? If there is
a comma followed by "not", does the phrase after it have a verb? Fix every sentence that fails, including
bullets and lines after a colon.

## What this document does not cover

Em dashes, parentheses, bold labels, message length, trailing offers, confessional preambles and the
rest of the first-pass audit are out of scope here. They will get their own short document once these
six rules are being followed.

## How this will be checked

The parser used in the audit can be run over any transcript and will count dropped subjects, verbless
sentences, count-first fragments, demonstrative openers and ", not X" tails. The target is Brian's own
rates from the same transcripts: under 2 percent of prose sentences with a dropped subject, under 2
percent opening with a demonstrative, under 1 percent ending in a ", not X" tail, and no count-first
fragments. Metaphor rate is checked by word list.

## Changelog

- 1.1, 2026-10-25. Rule 6 gained the "doing the work" family (is doing the work, is doing more work than,
  doing the heavy lifting, carries the argument, pulls its weight) after a claude.ai reply used it. The
  claude.ai version was updated the same day. The skill bundles still carry 1.0 until the next batch
  rebuild with `skills/build-skill.sh`.
- 1.0, 2026-10-24. Approved and deployed to Claude Code, the 13 bhub skill bundles and claude.ai.
