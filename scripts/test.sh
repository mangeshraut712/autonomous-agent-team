#!/usr/bin/env bash
# scripts/test.sh — Verify your autonomous agent team is working end-to-end
# Usage: ./scripts/test.sh
# CWD:   Run from workspace root (autonomous-agent-team/)

set -uo pipefail

if command -v openclaw >/dev/null 2>&1; then
  OC_BIN=(openclaw)
else
  OC_BIN=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

PASS=0
FAIL=0
WARN=0

green()  { echo "  ✅ $1"; }
red()    { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
yellow() { echo "  ⚠️  $1"; WARN=$((WARN+1)); }
inc_pass() { PASS=$((PASS+1)); }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🦞 Autonomous Agent Team — Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── 1. Workspace files ──────────────────────────────────────────────────────
echo "[ 1/5 ] Workspace files"

check_file() {
  if [ -f "$1" ]; then
    green "$1"
    inc_pass
  else
    red "$1 — MISSING"
  fi
}

check_file "SOUL.md"
check_file "AGENTS.md"
check_file "MEMORY.md"
check_file "HEARTBEAT.md"
check_file "agents/dwight/SOUL.md"
check_file "agents/dwight/AGENTS.md"
check_file "agents/dwight/MEMORY.md"
check_file "agents/kelly/SOUL.md"
check_file "agents/kelly/AGENTS.md"
check_file "agents/kelly/MEMORY.md"
check_file "agents/rachel/SOUL.md"
check_file "agents/rachel/AGENTS.md"
check_file "agents/ross/SOUL.md"
check_file "agents/ross/AGENTS.md"
check_file "agents/pam/SOUL.md"
check_file "agents/pam/AGENTS.md"
check_file "scripts/parallel-search.sh"

# Runtime intel files are generated locally and may not exist yet in a fresh clone.
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
  yellow "intel/data/README.md missing (optional schema doc)"
fi

echo ""

# ─── 2. Security checks ──────────────────────────────────────────────────────
echo "[ 2/5 ] Security"

if [ -f ".gitignore" ]; then
  green ".gitignore exists"
  inc_pass
else
  red ".gitignore MISSING — secrets may be committed!"
fi

if [ -f ".env" ]; then
  if git ls-files --error-unmatch .env >/dev/null 2>&1; then
    red ".env IS TRACKED BY GIT — remove it immediately! Run: git rm --cached .env"
  else
    green ".env exists and is gitignored (not tracked)"
    inc_pass
  fi
else
  yellow ".env not found — copy .env.example to .env and fill in credentials"
fi

if git ls-files --error-unmatch .openclaw/ >/dev/null 2>&1; then
  red ".openclaw/ IS TRACKED BY GIT — run: git rm -r --cached .openclaw/"
else
  green ".openclaw/ not tracked by git"
  inc_pass
fi

echo ""

# ─── 3. OpenClaw gateway ─────────────────────────────────────────────────────
echo "[ 3/5 ] OpenClaw Gateway"

if "${OC_BIN[@]}" health >/dev/null 2>&1; then
  green "Gateway health check passed"
  inc_pass
else
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789/ 2>/dev/null || echo "000")
  if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "401" ]; then
    green "Gateway responding at http://127.0.0.1:18789 (HTTP $HTTP_STATUS)"
    inc_pass
  else
    red "Gateway not reachable — run: openclaw onboard"
  fi
fi

echo ""

# ─── 4. Cron jobs ────────────────────────────────────────────────────────────
echo "[ 4/5 ] Cron Jobs"

CRON_COUNT=$("${OC_BIN[@]}" cron list --json 2>/dev/null | jq -r '(.total // (.jobs | length) // length // 0)' 2>/dev/null || echo "0")

if [ "$CRON_COUNT" -ge 6 ] 2>/dev/null; then
  green "$CRON_COUNT cron jobs registered (expected ≥6)"
  inc_pass
elif [ "$CRON_COUNT" -gt 0 ] 2>/dev/null; then
  yellow "$CRON_COUNT cron jobs found (expected 6) — run scripts/add-cron-jobs.sh to add or refresh"
else
  red "No cron jobs found — run: chmod +x scripts/add-cron-jobs.sh && ./scripts/add-cron-jobs.sh"
fi

echo ""

# ─── 5. Telegram ─────────────────────────────────────────────────────────────
echo "[ 5/5 ] Telegram"

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
    if [ "$TG_POLICY" = "pairing" ]; then
      yellow "dmPolicy is 'pairing' — pair your Telegram account first"
    else
      green "dmPolicy: $TG_POLICY"
      inc_pass
    fi
  else
    red "Telegram bot token invalid — re-run: openclaw configure --section telegram"
  fi
else
  red "No Telegram bot token found in ~/.openclaw/openclaw.json"
fi

echo ""

# ─── Summary ────────────────────────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: ✅ $PASS passed  ❌ $FAIL failed  ⚠️  $WARN warnings"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "  Fix the ❌ errors above before going to production."
  echo "  See docs/telegram-setup.md for Telegram pairing help."
  echo ""
  exit 1
else
  echo "  All checks passed! Your agent team is ready."
  echo ""
  echo "  Next: Open Telegram and message your bot to start chatting."
  echo "  Dashboard: http://127.0.0.1:18789"
  echo ""
fi
