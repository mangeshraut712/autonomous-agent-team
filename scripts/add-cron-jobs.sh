#!/usr/bin/env bash
# scripts/add-cron-jobs.sh
# Registers all 6 agent cron jobs with the OpenClaw gateway.
# Run this after `openclaw onboard` completes successfully.
#
# Usage: chmod +x scripts/add-cron-jobs.sh && ./scripts/add-cron-jobs.sh
# Optional:
#   export TELEGRAM_CHAT_TARGET=7969403889
#   export OPENCLAW_CRON_MODEL=openai-codex/gpt-5.3-codex
# CWD: run from workspace root (autonomous-agent-team/)

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required. Install with: brew install jq"
  exit 1
fi

if command -v openclaw >/dev/null 2>&1; then
  OC_BIN=(openclaw)
else
  OC_BIN=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

# Load TELEGRAM_CHAT_TARGET from .env when not exported.
if [[ -z "${TELEGRAM_CHAT_TARGET:-}" && -f ".env" ]]; then
  TELEGRAM_CHAT_TARGET="$(awk -F= '/^TELEGRAM_CHAT_TARGET=/{print $2}' .env | tail -n1 | tr -d '"' | tr -d "'" | xargs || true)"
fi

DELIVERY_ARGS=()
if [[ -n "${TELEGRAM_CHAT_TARGET:-}" ]]; then
  DELIVERY_ARGS=(
    --channel telegram
    --to "$TELEGRAM_CHAT_TARGET"
    --account default
    --announce
    --best-effort-deliver
  )
fi

add_job() {
  local name="$1"
  local cron_expr="$2"
  local agent_id="$3"
  local session_key="$4"
  local message="$5"

  local existing_id
  existing_id="$("${OC_BIN[@]}" cron list --json | jq -r --arg name "$name" '.jobs[] | select(.name == $name) | .id' | head -n1)"
  if [[ -n "${existing_id}" ]]; then
    echo "${existing_id}"
    return 0
  fi

  "${OC_BIN[@]}" cron add \
    --name "$name" \
    --cron "$cron_expr" \
    --agent "$agent_id" \
    --session-key "$session_key" \
    --message "$message" \
    --no-light-context \
    --timeout-seconds 420 \
    --model "${OPENCLAW_CRON_MODEL:-openai-codex/gpt-5.3-codex}" \
    "${DELIVERY_ARGS[@]}" \
    --json | jq -r '.id'
}

echo ""
echo "🦞 Registering agent cron schedule..."
echo ""

echo "[1/6] Dwight — Morning Research (8:01 AM)"
DWIGHT_AM="$(add_job \
  "Dwight Morning" \
  "1 8 * * *" \
  "dwight" \
  "agent:dwight:main" \
  "Run your morning research sweep. Check HN, GitHub trending, arXiv, X. Write findings to intel/DAILY-INTEL.md and intel/data/YYYY-MM-DD.json. If web_search is unavailable, use ../../scripts/parallel-search.sh with PARALLEL_API_KEY for live-source fallback.")"
echo "  ✓ ID: $DWIGHT_AM"

echo "[2/6] Kelly — Viral Content Checks (9:01 AM, 1:01 PM)"
KELLY_AMPM="$(add_job \
  "Kelly Viral" \
  "1 9,13 * * *" \
  "kelly" \
  "agent:kelly:main" \
  "Read intel/DAILY-INTEL.md and draft 3-5 tweet options from today's research. Save drafts to memory/YYYY-MM-DD.md.")"
echo "  ✓ ID: $KELLY_AMPM"

echo "[3/6] Ross — Engineering Tasks (10:01 AM)"
ROSS_AM="$(add_job \
  "Ross Engineering" \
  "1 10 * * *" \
  "ross" \
  "agent:ross:main" \
  "Check for queued engineering tasks, code reviews, or bugs. Log work in memory/YYYY-MM-DD.md.")"
echo "  ✓ ID: $ROSS_AM"

echo "[4/6] Dwight — Afternoon Research (4:01 PM)"
DWIGHT_PM="$(add_job \
  "Dwight Afternoon" \
  "1 16 * * *" \
  "dwight" \
  "agent:dwight:main" \
  "Run your afternoon research sweep. Update intel/DAILY-INTEL.md with late-breaking stories. If web_search is unavailable, use ../../scripts/parallel-search.sh with PARALLEL_API_KEY for live-source fallback.")"
echo "  ✓ ID: $DWIGHT_PM"

echo "[5/6] Kelly — Evening Tweet Drafts (5:01 PM)"
KELLY_PM="$(add_job \
  "Kelly X Drafts" \
  "1 17 * * *" \
  "kelly" \
  "agent:kelly:main" \
  "Read today's intel/DAILY-INTEL.md. Draft 3-5 evening tweet options. Save to memory/YYYY-MM-DD.md.")"
echo "  ✓ ID: $KELLY_PM"

echo "[6/6] Rachel — LinkedIn Drafts (5:01 PM)"
RACHEL_PM="$(add_job \
  "Rachel LinkedIn" \
  "1 17 * * *" \
  "rachel" \
  "agent:rachel:main" \
  "Read today's intel/DAILY-INTEL.md. Draft 2 LinkedIn posts with thought-leadership angle. Save to memory/YYYY-MM-DD.md.")"
echo "  ✓ ID: $RACHEL_PM"

echo ""
echo "✅ All 6 cron jobs registered!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Copy these IDs into HEARTBEAT.md:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Dwight Morning   (8:01 AM):   $DWIGHT_AM"
echo "  Kelly Viral      (9:01,1:01): $KELLY_AMPM"
echo "  Ross Engineering (10:01 AM):  $ROSS_AM"
echo "  Dwight Afternoon (4:01 PM):   $DWIGHT_PM"
echo "  Kelly X Drafts   (5:01 PM):   $KELLY_PM"
echo "  Rachel LinkedIn  (5:01 PM):   $RACHEL_PM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  View all jobs: ${OC_BIN[*]} cron list"
echo "  Dashboard:     http://127.0.0.1:18789"
echo ""
