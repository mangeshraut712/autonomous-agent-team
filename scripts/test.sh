#!/usr/bin/env bash
# scripts/test.sh — Validate workspace structure + runtime integration

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v openclaw >/dev/null 2>&1; then
  OC=(openclaw)
else
  OC=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

PASS=0
FAIL=0
WARN=0

green()  { echo "  ✅ $1"; }
red()    { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
yellow() { echo "  ⚠️  $1"; WARN=$((WARN+1)); }
inc_pass() { PASS=$((PASS+1)); }

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

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🦞 Autonomous Agent Team — Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Workspace files
echo "[ 1/6 ] Workspace files"
check_file() {
  if [ -f "$1" ]; then
    green "$1"
    inc_pass
  else
    red "$1 — MISSING"
  fi
}

check_file "README.md"
check_file "Makefile"
check_file "SOUL.md"
check_file "AGENTS.md"
check_file "MEMORY.md"
check_file "HEARTBEAT.md"
check_file "scripts/add-cron-jobs.sh"
check_file "scripts/status.sh"
check_file "scripts/test.sh"
check_file "scripts/ready-strict.sh"
check_file "scripts/notify.sh"
check_file "scripts/notifier-install.sh"
check_file "scripts/sync-openclaw-env.sh"
check_file "scripts/parallel-search.sh"
check_file "agents/dwight/SOUL.md"
check_file "agents/kelly/SOUL.md"
check_file "agents/rachel/SOUL.md"
check_file "agents/ross/SOUL.md"
check_file "agents/pam/SOUL.md"

if [ -f "intel/DAILY-INTEL.md" ]; then
  green "intel/DAILY-INTEL.md"
  inc_pass
else
  yellow "intel/DAILY-INTEL.md missing (will be created by Dwight cron runs)"
fi

if [ -f "intel/data/README.md" ]; then
  green "intel/data/README.md"
  inc_pass
else
  yellow "intel/data/README.md missing"
fi

echo ""

# 2. Security checks
echo "[ 2/6 ] Security"
if [ -f ".gitignore" ]; then
  green ".gitignore exists"
  inc_pass
else
  red ".gitignore MISSING"
fi

if [ -f ".env" ]; then
  if git ls-files --error-unmatch .env >/dev/null 2>&1; then
    red ".env IS TRACKED BY GIT — run: git rm --cached .env"
  else
    green ".env exists and is gitignored"
    inc_pass
  fi
else
  yellow ".env not found — copy .env.example to .env"
fi

if git ls-files --error-unmatch .openclaw/ >/dev/null 2>&1; then
  red ".openclaw/ IS TRACKED BY GIT"
else
  green ".openclaw/ not tracked by git"
  inc_pass
fi

echo ""

# 3. OpenClaw runtime
echo "[ 3/6 ] OpenClaw runtime"
if "${OC[@]}" health >/dev/null 2>&1; then
  green "Gateway health check passed"
  inc_pass
else
  red "Gateway health check failed"
fi

if "${OC[@]}" status >/dev/null 2>&1; then
  green "openclaw status succeeded"
  inc_pass
else
  yellow "openclaw status failed (run manually for details)"
fi

if "${OC[@]}" doctor --non-interactive >/dev/null 2>&1; then
  green "openclaw doctor --non-interactive passed"
  inc_pass
else
  yellow "openclaw doctor reported issues (review manually)"
fi

if "${OC[@]}" channels status --probe >/dev/null 2>&1; then
  green "channels status --probe succeeded"
  inc_pass
else
  yellow "channels status --probe reported issues"
fi

echo ""

# 4. Cron jobs
echo "[ 4/6 ] Cron Jobs"
CRON_COUNT="$("${OC[@]}" cron list --json 2>/dev/null | jq -r '(.total // (.jobs | length) // length // 0)' 2>/dev/null || echo "0")"
if [ "$CRON_COUNT" -ge 7 ] 2>/dev/null; then
  green "$CRON_COUNT cron jobs registered (expected ≥7)"
  inc_pass
elif [ "$CRON_COUNT" -gt 0 ] 2>/dev/null; then
  yellow "$CRON_COUNT cron jobs found (expected 7)"
else
  red "No cron jobs found — run: make cron-install"
fi

echo ""

# 5. Telegram
echo "[ 5/6 ] Telegram"
CFG_PATH="$HOME/.openclaw/openclaw.json"
BOT_TOKEN=""
if [ -f "$CFG_PATH" ]; then
  BOT_TOKEN=$(jq -r '.channels.telegram.botToken // empty' "$CFG_PATH" 2>/dev/null || true)
fi

if [ -n "$BOT_TOKEN" ]; then
  TG_RESP=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getMe" 2>/dev/null)
  TG_OK=$(echo "$TG_RESP" | jq -r '.ok // false' 2>/dev/null || echo "false")
  TG_NAME=$(echo "$TG_RESP" | jq -r '.result.username // "unknown"' 2>/dev/null || echo "unknown")

  if [ "$TG_OK" = "true" ]; then
    green "Telegram bot active: @$TG_NAME"
    inc_pass

    TG_POLICY=$(jq -r '.channels.telegram.dmPolicy // "unknown"' "$CFG_PATH" 2>/dev/null || echo "unknown")
    if [ "$TG_POLICY" = "allowlist" ]; then
      TG_ALLOW_COUNT=$(jq -r '(.channels.telegram.allowFrom // []) | length' "$CFG_PATH" 2>/dev/null || echo "0")
      if [ "$TG_ALLOW_COUNT" -gt 0 ] 2>/dev/null; then
        green "dmPolicy allowlist has allowFrom entries"
        inc_pass
      else
        red "dmPolicy=allowlist but allowFrom is empty"
      fi
    else
      yellow "dmPolicy is '$TG_POLICY'"
    fi
  else
    red "Telegram bot token invalid"
  fi
else
  yellow "No Telegram bot token found in ~/.openclaw/openclaw.json"
fi

echo ""

# 6. Web search provider keys
echo "[ 6/6 ] Web search provider keys"
KEY_FOUND=0
for key in BRAVE_API_KEY GEMINI_API_KEY KIMI_API_KEY MOONSHOT_API_KEY PERPLEXITY_API_KEY XAI_API_KEY; do
  val="${!key:-}"
  if [ -z "$val" ]; then
    val="$(read_env_value "$key" "$ROOT/.env" || true)"
  fi
  if [ -n "$val" ]; then
    green "$key is configured"
    inc_pass
    KEY_FOUND=1
  fi
done
if [ "$KEY_FOUND" -eq 0 ]; then
  yellow "No official web_search provider key found in env/.env"
fi

PARALLEL_KEY="${PARALLEL_API_KEY:-}"
if [ -z "$PARALLEL_KEY" ]; then
  PARALLEL_KEY="$(read_env_value PARALLEL_API_KEY "$ROOT/.env" || true)"
fi
if [ -n "$PARALLEL_KEY" ]; then
  green "PARALLEL_API_KEY configured (fallback search available)"
  inc_pass
else
  yellow "PARALLEL_API_KEY not set (fallback disabled)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: ✅ $PASS passed  ❌ $FAIL failed  ⚠️  $WARN warnings"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "Fix the ❌ errors above before production use."
  echo "Run strict checks: make ready-strict"
  echo ""
  exit 1
else
  echo "Core checks passed."
  echo "Run strict checks before deploy: make ready-strict"
  echo ""
fi
