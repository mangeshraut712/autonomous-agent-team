#!/usr/bin/env bash
# scripts/add-cron-jobs.sh
# Register default cron jobs for the six-agent workspace.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required. Install with: brew install jq"
  exit 1
fi

if command -v openclaw >/dev/null 2>&1; then
  OC=(openclaw)
else
  OC=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

read_env_value() {
  local key="$1"
  local file="$2"
  [[ -f "$file" ]] || return 1
  awk -F= -v k="$key" '
    $1==k {
      v=$0
      sub(/^[^=]*=/, "", v)
      gsub(/^"|"$/, "", v)
      gsub(/^\047|\047$/, "", v)
      print v
      exit
    }
  ' "$file"
}

COMMON_ARGS=()
if [[ -n "${OPENCLAW_GATEWAY_URL:-}" ]]; then
  COMMON_ARGS+=(--url "$OPENCLAW_GATEWAY_URL")
fi
if [[ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
  COMMON_ARGS+=(--token "$OPENCLAW_GATEWAY_TOKEN")
fi

OC_CMD=("${OC[@]}")
if (( ${#COMMON_ARGS[@]} > 0 )); then
  OC_CMD+=("${COMMON_ARGS[@]}")
fi

TELEGRAM_CHAT_TARGET="${TELEGRAM_CHAT_TARGET:-}"
if [[ -z "$TELEGRAM_CHAT_TARGET" ]]; then
  TELEGRAM_CHAT_TARGET="$(read_env_value TELEGRAM_CHAT_TARGET "$ROOT/.env" || true)"
fi

OPENCLAW_CRON_MODEL="${OPENCLAW_CRON_MODEL:-}"
if [[ -z "$OPENCLAW_CRON_MODEL" ]]; then
  OPENCLAW_CRON_MODEL="$(read_env_value OPENCLAW_CRON_MODEL "$ROOT/.env" || true)"
fi

if ! "${OC_CMD[@]}" health >/dev/null 2>&1; then
  echo "Error: OpenClaw gateway is not healthy."
  echo "Run: openclaw doctor --non-interactive && openclaw gateway restart"
  exit 1
fi

DELIVERY_ARGS=()
if [[ -n "$TELEGRAM_CHAT_TARGET" ]]; then
  DELIVERY_ARGS=(
    --channel telegram
    --to "$TELEGRAM_CHAT_TARGET"
    --account default
    --announce
    --best-effort-deliver
  )
fi

MODEL_ARGS=()
if [[ -n "$OPENCLAW_CRON_MODEL" ]]; then
  MODEL_ARGS=(--model "$OPENCLAW_CRON_MODEL")
fi

add_job() {
  local name="$1"
  local cron_expr="$2"
  local agent_id="$3"
  local session_key="$4"
  local message="$5"

  local existing_id
  existing_id="$("${OC_CMD[@]}" cron list --json 2>/dev/null | jq -r --arg name "$name" '.jobs[]? | select(.name == $name) | .id' | head -n1)"
  if [[ -n "$existing_id" ]]; then
    echo "$existing_id"
    return 0
  fi

  "${OC_CMD[@]}" cron add \
    --name "$name" \
    --cron "$cron_expr" \
    --agent "$agent_id" \
    --session-key "$session_key" \
    --session isolated \
    --message "$message" \
    --timeout-seconds 420 \
    "${MODEL_ARGS[@]}" \
    "${DELIVERY_ARGS[@]}" \
    --json | jq -r '.id'
}

echo
echo "🦞 Registering default cron schedule..."
echo

echo "[1/6] Dwight — Morning Research (8:01 AM)"
DWIGHT_AM="$(add_job \
  "Dwight Morning" \
  "1 8 * * *" \
  "dwight" \
  "agent:dwight:main" \
  "Run morning research sweep. Use web_search with configured provider (Brave/Gemini/Kimi/Perplexity/Grok). If web_search is unavailable, use scripts/parallel-search.sh fallback. Write to intel/data/YYYY-MM-DD.json and intel/DAILY-INTEL.md with citations.")"
echo "  ✓ ID: $DWIGHT_AM"

echo "[2/6] Kelly — Viral Content Checks (9:01 AM, 1:01 PM)"
KELLY_AMPM="$(add_job \
  "Kelly Viral" \
  "1 9,13 * * *" \
  "kelly" \
  "agent:kelly:main" \
  "Read intel/DAILY-INTEL.md and draft 3-5 X posts in voice guidelines. Save drafts to memory/YYYY-MM-DD.md.")"
echo "  ✓ ID: $KELLY_AMPM"

echo "[3/6] Ross — Engineering Tasks (10:01 AM)"
ROSS_AM="$(add_job \
  "Ross Engineering" \
  "1 10 * * *" \
  "ross" \
  "agent:ross:main" \
  "Review queued engineering tasks, validate assumptions, and log concrete next actions in memory/YYYY-MM-DD.md.")"
echo "  ✓ ID: $ROSS_AM"

echo "[4/6] Dwight — Afternoon Research (4:01 PM)"
DWIGHT_PM="$(add_job \
  "Dwight Afternoon" \
  "1 16 * * *" \
  "dwight" \
  "agent:dwight:main" \
  "Run afternoon research sweep and update intel files with new items or explicit no-change status with reasons.")"
echo "  ✓ ID: $DWIGHT_PM"

echo "[5/6] Kelly — Evening X Drafts (5:01 PM)"
KELLY_PM="$(add_job \
  "Kelly X Drafts" \
  "1 17 * * *" \
  "kelly" \
  "agent:kelly:main" \
  "Draft 3-5 evening X options from today's intel. Include one contrarian angle and one practical angle.")"
echo "  ✓ ID: $KELLY_PM"

echo "[6/6] Rachel — LinkedIn Drafts (5:01 PM)"
RACHEL_PM="$(add_job \
  "Rachel LinkedIn" \
  "1 17 * * *" \
  "rachel" \
  "agent:rachel:main" \
  "Draft 2 LinkedIn posts from today's intel with clear takeaways and professional tone.")"
echo "  ✓ ID: $RACHEL_PM"

echo
echo "✅ Cron schedule is ready."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Dwight Morning   (8:01 AM):   $DWIGHT_AM"
echo "Kelly Viral      (9:01,1:01): $KELLY_AMPM"
echo "Ross Engineering (10:01 AM):  $ROSS_AM"
echo "Dwight Afternoon (4:01 PM):   $DWIGHT_PM"
echo "Kelly X Drafts   (5:01 PM):   $KELLY_PM"
echo "Rachel LinkedIn  (5:01 PM):   $RACHEL_PM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Next: paste these IDs into HEARTBEAT.md if they changed."
echo "View jobs: ${OC_CMD[*]} cron list"
