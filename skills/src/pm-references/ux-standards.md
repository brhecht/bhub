# B-Suite UX Standards (Fallback Snapshot Pointer)

**This file is NOT the source of truth.**

The canonical B-Suite UX Standards live at:

```
~/Developer/B-Suite/bhub/UX-STANDARDS.md
```

That file is versioned in git and pulled cross-device on every `handoff here`. Always read it first when using the pm skill.

This bundled fallback exists only for the unlikely case where a Claude session invokes the pm skill without access to the B-Suite mount (e.g., a brand-new device before bsync has cloned bhub). If you're reading this file instead of the canonical copy, something is off — the pm skill's normal operating assumption is that bhub is mounted.

## What to do

1. Try to read `~/Developer/B-Suite/bhub/UX-STANDARDS.md` first.
2. If that path resolves, use it and ignore this file entirely.
3. If the canonical path is genuinely unavailable, flag the gap to Brian before drafting a brief — don't silently fall back to a stale snapshot.

## Last sync

The contents of `bhub/UX-STANDARDS.md` as of April 24, 2026 were identical to the original `ux-standards-review.html` (March 29, 2026 content). Any subsequent edits live only in the canonical file.
