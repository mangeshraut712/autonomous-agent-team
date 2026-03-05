#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ARCHIVE_NOISE=false
if [[ "${1:-}" == "--archive-local-noise" ]]; then
  ARCHIVE_NOISE=true
fi

echo "Cleaning macOS metadata files ..."
find "$ROOT" -name '.DS_Store' -type f -delete || true

if $ARCHIVE_NOISE; then
  TS="$(date +%Y%m%d-%H%M%S)"
  ARCHIVE_DIR="${HOME}/Downloads/AI-Agent-archive/${TS}"
  mkdir -p "$ARCHIVE_DIR"

  for d in "always-on-memory-agent" "_trash"; do
    if [[ -e "$ROOT/$d" ]]; then
      mv "$ROOT/$d" "$ARCHIVE_DIR/"
      echo "Archived: $d -> $ARCHIVE_DIR/$d"
    fi
  done
fi

echo
echo "Root cleanup complete."
