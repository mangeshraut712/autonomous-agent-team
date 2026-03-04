#!/usr/bin/env bash
# scripts/install-proactive-crons.sh
# Compatibility wrapper: keep one canonical cron installer.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "install-proactive-crons.sh is a compatibility wrapper."
echo "Delegating to scripts/add-cron-jobs.sh (canonical installer)."

exec bash "$ROOT/scripts/add-cron-jobs.sh" "$@"
