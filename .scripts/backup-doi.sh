#!/bin/bash
set -euo pipefail
SRC="$HOME/Dropbox/Projects/DeckOfInfinity/"
DEST="$HOME/Backups/DeckOfInfinity"
RETAIN_DAYS="${DOI_SOURCE_RETAIN_DAYS:-30}"
STAMP="$(date +%Y-%m-%d_%H%M%S)"
LATEST="$DEST/latest"
mkdir -p "$DEST"

rsync -a --delete \
  --exclude='card-engine/target/' \
  --exclude='card-engine/frontend/node_modules/' \
  --exclude='server/_build/' \
  --exclude='server/deps/' \
  --exclude='**/.DS_Store' \
  ${LATEST:+--link-dest="$LATEST"} \
  "$SRC" "$DEST/$STAMP/"

ln -sfn "$DEST/$STAMP" "$LATEST"

# Prune snapshots older than RETAIN_DAYS; never the one `latest` points at.
KEEP="$(readlink "$LATEST" 2>/dev/null || true)"
while IFS= read -r -d '' d; do
  [[ "$d" == "$KEEP" ]] && continue
  rm -rf "$d"
done < <(find "$DEST" -maxdepth 1 -type d -name '20*-*' -mtime "+$RETAIN_DAYS" -print0)
