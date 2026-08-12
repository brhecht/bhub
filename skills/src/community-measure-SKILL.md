---
name: community-measure
description: "Measures participation in the TNB community Slack against the decisions in tnb-strategy/community/MEASUREMENT-CANON.md. Produces the primary number (distinct non-host initiators, trailing 30 days), the secondary active-member count, the full participation ladder per member, and the reactivation list ranked by how far each member fell. Triggers on '/community-measure', 'run the community measurement', 'community numbers', 'how many active members', 'distinct initiators', 'who went quiet', 'reactivation list', 'the ladder', 'measure the community', or any request for how vibrant or active the TNB community is. Read-only on Slack; never posts. NOT the gross event counter (that is slack-stats), NOT the weekly editorial pick-list (that is tnb-digest), and NOT per-person Tendys scoring (that is Builder Bot)."
---

# TNB Community Measurement

You are computing the participation numbers for The New Builder community Slack
(`the-new-builder.slack.com`). This skill is the counting-and-classifying engine that
`slack-stats`, `tnb-digest` and Builder Bot deliberately do not provide.

**The canon governs. This skill executes.** Every definition, threshold and exclusion lives
in `tnb-strategy/community/MEASUREMENT-CANON.md`. If this file and the canon ever disagree,
**the canon wins and this file is the bug.** Do not encode a definition here that the canon
does not already contain.

This skill was written *after* the method ran end to end on 2026-08-12, per the canon's own
instruction not to canonize an unrun method. Everything below is what actually worked, and
several steps exist because something specific went wrong.

---

## Step 0 — Load the canon first, always

Clone or pull `tnb-strategy` and read `community/MEASUREMENT-CANON.md` **before touching
Slack**. Read the most recent `community/FIRST-PASS-*.md` or later results doc too, so you
know the prior baseline you are about to move.

Extract from the canon at runtime rather than assuming: the primary metric and its baseline
(section 1), the definition of active (section 2), the ladder and which rungs are live
(section 3), the bot rules (section 5), the blind spots (section 6), the event log URL
(section 7), and the build requirements (section 8).

**Do not hardcode numbers from this file into your output.** As of writing, the primary
metric is distinct non-host initiators over a trailing 30 days with a baseline of 18, and
the hosts are Brian Hecht and Nico Mejia — but read all of that from the canon, because it
has already changed once.

---

## Step 1 — Enumerate channels live. Never hardcode.

Call `slack_search_channels` with `channel_types: "public_channel,private_channel"` and a
broad query to list everything.

The count has been 11, then 12, within a single day. `slack-stats` has a documented failure
where a copied five-channel registry silently undercut replies by 20%. **Enumerate every
run and diff against the canon's list.** If a channel exists that the canon does not name,
say so in the output rather than quietly folding it in.

**Public channels supply every number.** Private limited-membership channels are excluded
from the ladder and both metrics, per canon section 8. **List every excluded channel by name
and reason in the output** — silent exclusion is indistinguishable from having missed one.

---

## Step 2 — Read every public channel to exhaustion

**Never use any Slack search tool.** The index is stale: it once reported the last DM with
Nico as July 29 when it was August 10, and returned nothing from a day with hours of
activity. Any number that came from search is an undercount.

Use `slack_read_channel` with `response_format: "detailed"`, `limit: 25`, paginating on the
returned cursor until exhausted. Then call `slack_read_thread` on **every** message with
replies, also fully paginated.

**Thread replies are not optional.** In `#share-and-discuss`, 45% of reaction-bearing
messages were thread replies, and several members' only appearances were there. A root-only
pass misses roughly half the quieter participation.

### Fan this out, and write to disk as you go

Reading the whole workspace inline will exceed context — `#general` alone was 59KB for 100
messages. Dispatch one subagent per channel (or per small group), and have **each subagent
write its own ledger file** rather than returning the table. Returning it defeats the point.

Ledger line format, one line per message:

```
channel | YYYY-MM-DD | Author Display Name | root|reply|join | reply_count_if_root | reactors: ... | first 10 words
```

Replies must carry `[in thread by RootAuthorName]` in the text column — the own-welcome
exclusion in step 4 is impossible without it.

**Commit the ledgers to `tnb-strategy/community/ledgers/` as each batch lands, not at the
end.** They are the expensive artifact: they make the next run cheap and this run checkable,
and scratch directories do not survive. The sandbox `/tmp` was cleared mid-session during
the first pass and only the committed copies survived.

---

## Step 3 — Build the roster and filter bots

Call `slack_list_channel_members` on every public channel, `response_format: "concise"`,
**fully paginated** (30 per page; the first page alone will mislead you), and take the union.

Exclude bot and app accounts per canon section 5: Builder Bot, `builder_bot2`, Linear,
Google Drive, Slack, Claude, and **Otto**.

**Otto is an author filter, not a content filter.** The canon once recorded OTTO shift-updates
as an unfilterable hard case posted from Mike Cerrone's human account. That is wrong: they
post from a separate app account displayed as `Otto` (`U0B35AK97NU`), and an author filter
catches them cleanly.

**Never content-filter `#shipped`.** 41 of its 50 templated-looking messages are genuine
human posts in that channel's native "Shipped `<date>`" format. A pattern filter would
delete most of the channel's real human volume.

**Merge duplicate accounts.** `scott` and `scott511` are the same human. Check for others;
an unmerged duplicate inflates the denominator and manufactures a phantom silent member.

Accounts with no display name set are a finding, not a formatting problem — someone who never
set a display name most likely never finished onboarding, which is an activation failure at
the door and wants a different intervention from a lapsed member.

---

## Step 4 — Compute the metrics

Window: trailing 30 days from today.

**Primary — distinct non-host initiators.** Count members other than the hosts who authored
at least one root post in a public channel inside the window. **Exclude their own welcome
post in `#introduce-yourself`** — that is prompted and one-time.

**Secondary — active members.** Posted or replied inside the window, excluding anything
inside their own welcome thread: their own intro root, and their own replies within it.

The exclusion is worth real accuracy, not pedantry: applying it moved the first pass from 29
to 26, a 12% difference, because three members were active *only* inside their own
introduction.

**The ladder, twice per member** — highest rung ever, and rung within the window. Rungs are
0 (never posted), 1 (introduced and stopped), 3 (replies, never initiates), 4 (initiates).

**Rung 2 is retired permanently. Do not attempt it, and do not call
`slack_get_reactions` to rebuild it.** Reactions carry no timestamp, so rung 2 can never have
a trailing-30 form, and a rung that cannot go down cannot show anyone falling. Canon section
6 records this as a closed impossibility with an explicit do-not-reopen. Note in the output
that some members counted silent may be reacting unseen — that is the known, accepted cost.

**Reactivation list** — every member whose ever-rung exceeds their window-rung, ranked by the
gap. Ex-initiators now at zero are the top of the list and the only part that reliably
matters; they are specific conversations, not a campaign.

**Also report concentration**, because the primary metric alone can hide it: total
initiations, the top-three share of non-host initiations, and the host share. The canon's
whole premise is that four people posting while everyone else responds is an audience.

---

## Step 5 — Event log, conditional

Read the event log URL from **canon section 7**. Behave differently depending on what is there,
and **do not edit this skill when the URL lands** — that is the point of reading it at runtime.

**If section 7 contains a real URL:** read the Sheet (one row per person per event:
`date | event_type | event_name | attendee | member_or_prospect | brought_by | notes`). Apply
the canon section 3 override — **anyone who attended an event inside the window is active,
full stop, regardless of Slack**. Someone who travels to have dinner with Brian is more
engaged than someone who posts a link. Report how many members the override added, and use
`brought_by` for the referral trail, which exists nowhere else.

Attendance does **not** promote anyone to initiator. The primary metric stays Slack-only;
the override lifts the secondary active count.

**If section 7 still says `TBD`:** skip it silently. Do not ask, do not stall, do not
improvise a substitute. State one line in the output: *the active count is understated
because the event log does not exist yet and the attendance override could not be applied.*
The first pass missed a dinner of 13 members plus 3 prospects this way.

---

## Step 6 — State the floor on the face of the output

Every count is a floor. Say so where it cannot be missed, with the reasons: the retention
wall (oldest surviving message ~May 14, 2026; six weeks of the founding period are gone and
`#daily-recap-bot` is confirmed empty, so nothing reconstructs it), invisible member-to-member
DMs, uncountable read-only members, and — when applicable — the missing event log.

**Do not report channel joins as engagement.** Tested and dead: in `#events`, 20 of 20 joins
landed on creation day inside a 62-second window, none later, and 48 of 68 members produced
no join event at all. Do not re-run this test.

---

## Step 7 — Verify before you ship

Re-derive the headline numbers through a **separate code path** that shares no helper
functions with the one that produced the tables. The first pass caught nothing this way,
which is the outcome you want and is not a reason to skip it.

Then check: every ledger's own footer total matches the lines you parsed; no malformed lines;
no dates before the retention wall or in the future; every member classified rung 0 truly has
zero messages anywhere rather than merely zero recent ones; and spot-check the top of the
reactivation list against raw lines. Confirm explicitly in the output that no Slack search was
used.

---

## Step 8 — Write it up, commit, push

Write a dated results doc to `tnb-strategy/community/RESULTS-<YYYY-MM-DD>.md`: primary number
against its prior baseline, secondary beneath it, the ladder both ways, the reactivation list,
concentration, what moved since the last run, and what this pass did not settle.

Mark every figure the canon did not decide as ASSUMED and every canon decision as DECIDED.
Attach a kill criterion to any new recommendation.

Commit the results doc **and** the ledgers, push, and stamp `bsuite-handoffs/tnb-strategy/HANDOFF.md`
per the handoff skill.

**If the run produces a finding that contradicts the canon, do not silently correct it in the
output.** Edit the canon, date it in the change log, and say in the results doc that you did.
The first pass overturned the OTTO case and killed both the join signal and rung 2 that way.

---

## What this skill must never do

- Use Slack search for any number.
- Post anything to Slack. Read-only, always.
- Count bots, or count private-channel activity toward either metric.
- Report a total-membership figure as a headline. Inactive members inflate every denominator;
  cite the primary, then active.
- Treat inactive members as losses. They are pre-qualified leads who joined on purpose and
  were introduced by someone. The frame is reactivation, not rescue, and nobody is ever removed
  for inactivity.
- Rebuild rung 2.
