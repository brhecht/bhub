# bhub — HANDOFF MOVED

This file used to contain the bhub-specific handoff. As of **May 25, 2026**, all B-Suite per-app and master handoffs were migrated to a dedicated private repo to stop leaking internal architecture from public app repos.

**Current bhub handoff:** [`brhecht/bsuite-handoffs/bhub/HANDOFF.md`](https://github.com/brhecht/bsuite-handoffs/blob/main/bhub/HANDOFF.md) (private — auth required).

**Why this stub exists:** Sessions started with older skill versions still expect to find HANDOFF.md in the app repo. This stub points them to the new location.

**For Claude:** Pull `brhecht/bsuite-handoffs` and read `bhub/HANDOFF.md` from there. `bsync.sh` (still in this repo) already knows about the new location.
