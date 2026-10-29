#!/bin/bash
# build-skill.sh <skill-name> [...]  — rebuild skills/<name>.skill bundles.
#
# What it does, per skill:
#   1. Unpacks the existing bundle (so every file already shipped in it is kept as is).
#   2. Replaces <name>/SKILL.md with skills/src/<name>-SKILL.md, the source of truth.
#   3. Adds <name>/references/house-style.md, a copy of bhub/HOUSE-STYLE.md (the B-Suite house
#      style; every bhub skill carries it since Oct 24 2026, under this name since Oct 29 2026),
#      and removes the older references/writing-to-brian.md if the bundle still has one.
#   4. Re-zips to skills/<name>.skill and prints the file list.
#
# It does not touch skills-manifest.json. After building, bump that skill's version,
# set hash to the MD5 of the SKILL.md source, and update "updated" + "changelog" in
# the same commit (dev-deploy rule: source, bundle and manifest move together).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC="$HERE/../HOUSE-STYLE.md"
[[ -f "$SPEC" ]] || { echo "missing $SPEC" >&2; exit 1; }
[[ $# -ge 1 ]] || { echo "usage: build-skill.sh <skill-name> [...]" >&2; exit 1; }
for NAME in "$@"; do
  SRC="$HERE/src/$NAME-SKILL.md"; BUNDLE="$HERE/$NAME.skill"
  [[ -f "$SRC" ]] || { echo "$NAME: no source at $SRC" >&2; exit 1; }
  STAGE="$(mktemp -d)"
  if [[ -f "$BUNDLE" ]]; then unzip -q "$BUNDLE" -d "$STAGE"; chmod -R u+rwX "$STAGE"; fi   # some old bundles stored read-only dirs
  mkdir -p "$STAGE/$NAME/references"
  cp "$SRC" "$STAGE/$NAME/SKILL.md"
  cp "$SPEC" "$STAGE/$NAME/references/house-style.md"
  rm -f "$STAGE/$NAME/references/writing-to-brian.md"
  rm -f "$BUNDLE"
  (cd "$STAGE" && zip -qr -X "$BUNDLE" "$NAME")
  rm -rf "$STAGE"
  echo "$NAME.skill: $(unzip -Z1 "$BUNDLE" | grep -v '/$' | tr '\n' ' ')"
done
