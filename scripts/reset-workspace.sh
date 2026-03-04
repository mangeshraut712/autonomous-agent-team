#!/usr/bin/env bash
# scripts/reset-workspace.sh
# Quickly clear daily memory and intel to start a fresh test run.
# Does NOT delete your API keys or root setup.

set -uo pipefail

echo "⚠️  This will delete all daily memory and intel files."
read -rp "Are you sure? (y/N) " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo "Cleaning agents/*/memory/*.md..."
rm -vf agents/*/memory/*.md

echo "Cleaning intel directories..."
rm -vf intel/DAILY-INTEL.md
rm -vf intel/data/*.json
rm -vf memory/*.md

echo "✅ Workspace reset completed."
