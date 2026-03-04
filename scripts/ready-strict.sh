#!/usr/bin/env bash
# scripts/ready-strict.sh
# Strict operational readiness checks aligned with official OpenClaw diagnostics.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v openclaw >/dev/null 2>&1; then
  OC=(openclaw)
else
  OC=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

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

PASS=0
WARN=0
FAIL=0

green() { printf '  ✅ %s\n' "$1"; PASS=$((PASS + 1)); }
yellow() { printf '  ⚠️  %s\n' "$1"; WARN=$((WARN + 1)); }
red() { printf '  ❌ %s\n' "$1"; FAIL=$((FAIL + 1)); }

run_check() {
  local label="$1"
  shift
  local out
  out="$(mktemp)"
  if "$@" >"$out" 2>&1; then
    green "$label"
  else
    red "$label"
    sed -n '1,12p' "$out" | sed 's/^/     /'
  fi
  rm -f "$out"
}

read_env_value() {
  local key="$1"
  local file="$2"
  [[ -f "$file" ]] || return 1
  awk -F= -v k="$key" '
    $1==k {
      val=$0
      sub(/^[^=]*=/, "", val)
      gsub(/^"|"$/, "", val)
      gsub(/^\047|\047$/, "", val)
      print val
      exit
    }
  ' "$file"
}

check_key() {
  local key="$1"
  local value=""

  if [[ -n "${!key:-}" ]]; then
    printf '%s' "${!key}"
    return 0
  fi

  value="$(read_env_value "$key" "$ROOT/.env" || true)"
  if [[ -n "$value" ]]; then
    printf '%s' "$value"
    return 0
  fi

  value="$(read_env_value "$key" "$HOME/.openclaw/.env" || true)"
  if [[ -n "$value" ]]; then
    printf '%s' "$value"
    return 0
  fi

  return 1
}

printf '\n'
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
printf '  🦞 OpenClaw Strict Readiness\n'
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
printf '\n'

printf '[ 1/7 ] Workspace path hygiene\n'
BASE_NAME="$(basename "$ROOT")"
TRIMMED_BASE="$(printf '%s' "$BASE_NAME" | sed 's/[[:space:]]*$//')"

if [[ "$BASE_NAME" != "$TRIMMED_BASE" ]]; then
  red "Current workspace path has trailing spaces: '$ROOT'"
else
  green "Workspace path has no trailing spaces"
fi

PARENT_DIR="$(dirname "$ROOT")"
if [[ -d "$PARENT_DIR/$TRIMMED_BASE " && "$ROOT" != "$PARENT_DIR/$TRIMMED_BASE " ]]; then
  yellow "Found sibling folder with trailing space: '$PARENT_DIR/$TRIMMED_BASE '"
else
  green "No trailing-space sibling workspace detected"
fi

printf '\n'
printf '[ 2/7 ] Required local files\n'
for f in README.md AGENTS.md SOUL.md MEMORY.md HEARTBEAT.md scripts/add-cron-jobs.sh scripts/test.sh scripts/status.sh scripts/notify.sh scripts/notifier-install.sh; do
  if [[ -f "$f" ]]; then
    green "$f"
  else
    red "$f missing"
  fi
done

printf '\n'
printf '[ 3/7 ] OpenClaw runtime diagnostics\n'
run_check "openclaw --version" "${OC[@]}" --version
run_check "openclaw status" "${OC_CMD[@]}" status
run_check "openclaw status --all" "${OC_CMD[@]}" status --all
run_check "openclaw gateway probe" "${OC_CMD[@]}" gateway probe
run_check "openclaw gateway status" "${OC_CMD[@]}" gateway status
run_check "openclaw doctor --non-interactive" "${OC_CMD[@]}" doctor --non-interactive
run_check "openclaw channels status --probe" "${OC_CMD[@]}" channels status --probe

printf '\n'
printf '[ 4/7 ] Cron scheduler\n'
CRON_JSON="$(mktemp)"
if "${OC_CMD[@]}" cron list --json >"$CRON_JSON" 2>/dev/null; then
  CRON_COUNT="$(jq -r '(.total // (.jobs | length) // length // 0)' "$CRON_JSON" 2>/dev/null || echo 0)"
  if [[ "$CRON_COUNT" =~ ^[0-9]+$ ]] && (( CRON_COUNT >= 7 )); then
    green "Cron jobs registered: $CRON_COUNT"
  elif [[ "$CRON_COUNT" =~ ^[0-9]+$ ]] && (( CRON_COUNT > 0 )); then
    yellow "Cron jobs registered: $CRON_COUNT (expected at least 7)"
  else
    red "Could not verify cron jobs"
  fi
else
  red "openclaw cron list --json"
fi
rm -f "$CRON_JSON"
run_check "openclaw cron status" "${OC_CMD[@]}" cron status

printf '\n'
printf '[ 5/7 ] Telegram channel\n'
CFG="$HOME/.openclaw/openclaw.json"
if [[ -f "$CFG" ]]; then
  TG_TOKEN="$(jq -r '.channels.telegram.botToken // empty' "$CFG" 2>/dev/null || true)"
  TG_POLICY="$(jq -r '.channels.telegram.dmPolicy // "unknown"' "$CFG" 2>/dev/null || true)"
  if [[ -n "$TG_TOKEN" ]]; then
    TG_RESP="$(curl -s "https://api.telegram.org/bot${TG_TOKEN}/getMe")"
    TG_OK="$(echo "$TG_RESP" | jq -r '.ok // false' 2>/dev/null || echo false)"
    if [[ "$TG_OK" == "true" ]]; then
      TG_USER="$(echo "$TG_RESP" | jq -r '.result.username // "unknown"' 2>/dev/null || echo unknown)"
      green "Telegram token valid (@$TG_USER)"
    else
      red "Telegram token appears invalid"
    fi
  else
    yellow "Telegram bot token not found in ~/.openclaw/openclaw.json"
  fi

  if [[ "$TG_POLICY" == "allowlist" ]]; then
    ALLOW_COUNT="$(jq -r '(.channels.telegram.allowFrom // []) | length' "$CFG" 2>/dev/null || echo 0)"
    if [[ "$ALLOW_COUNT" =~ ^[0-9]+$ ]] && (( ALLOW_COUNT > 0 )); then
      green "Telegram dmPolicy=allowlist with allowFrom entries"
    else
      red "Telegram dmPolicy=allowlist but allowFrom is empty"
    fi
  elif [[ "$TG_POLICY" == "pairing" || "$TG_POLICY" == "open" ]]; then
    yellow "Telegram dmPolicy is '$TG_POLICY' (verify this matches your security intent)"
  else
    yellow "Telegram dmPolicy is '$TG_POLICY'"
  fi
else
  yellow "~/.openclaw/openclaw.json not found"
fi

printf '\n'
printf '[ 6/7 ] Web search provider coverage\n'
HAS_PROVIDER_KEY=0
for key in BRAVE_API_KEY GEMINI_API_KEY KIMI_API_KEY MOONSHOT_API_KEY PERPLEXITY_API_KEY XAI_API_KEY; do
  if check_key "$key" >/dev/null 2>&1; then
    HAS_PROVIDER_KEY=1
    green "$key available"
  fi
done
if (( HAS_PROVIDER_KEY == 0 )); then
  yellow "No official web_search provider key detected (Brave/Gemini/Kimi/Perplexity/Grok)"
fi

if check_key PARALLEL_API_KEY >/dev/null 2>&1; then
  green "PARALLEL_API_KEY available (custom fallback script enabled)"
else
  yellow "PARALLEL_API_KEY not set (custom fallback disabled)"
fi

printf '\n'
printf '[ 7/7 ] Security quick checks\n'
if git ls-files --error-unmatch .env >/dev/null 2>&1; then
  red ".env is tracked by git"
else
  green ".env is not tracked"
fi
if git ls-files --error-unmatch .openclaw >/dev/null 2>&1; then
  red ".openclaw is tracked by git"
else
  green ".openclaw is not tracked"
fi

printf '\n'
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
printf '  Results: ✅ %s passed  ❌ %s failed  ⚠️  %s warnings\n' "$PASS" "$FAIL" "$WARN"
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
printf '\n'

if (( FAIL > 0 )); then
  printf 'Fix the failing checks, then re-run: make ready-strict\n\n'
  exit 1
fi

printf 'Strict readiness checks passed.\n\n'
