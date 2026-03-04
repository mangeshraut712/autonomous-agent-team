#!/usr/bin/env bash
# ============================================================
# start-gateway.sh — Reliable OpenClaw Gateway Starter
# 
# Usage:
#   ./scripts/start-gateway.sh
#
# For overnight sessions:
#   caffeinate -d & ./scripts/start-gateway.sh
#
# API keys are loaded from ~/.openclaw/.env automatically.
# DO NOT hardcode API keys in this script — use .env files.
# ============================================================
set -e

echo "🦞 OpenClaw Gateway Boot Script"
echo "================================="

# Remove stale lock files (macOS Sequoia provenance restriction workaround)
# The default temp dir gets com.apple.provenance xattr that blocks file creation
LOCK_PATTERN="/var/folders"
if [ -n "$TMPDIR" ] && [ "$TMPDIR" != "/tmp" ]; then
  find "$TMPDIR" -name "*.lock" -path "*openclaw*" -delete 2>/dev/null || true
  echo "✅ Cleared stale lock files"
fi
find /tmp -name "*.lock" -path "*openclaw*" -delete 2>/dev/null || true

# Load API keys from project .env if it exists
if [ -f "$(dirname "$0")/../.env" ]; then
  # Export keys without leaking to shell history
  set -a
  # shellcheck disable=SC1091
  source "$(dirname "$0")/../.env" 2>/dev/null || true
  set +a
  echo "✅ Loaded keys from .env"
fi

# Keys can also live in ~/.openclaw/.env (global for all projects)
# OpenClaw reads that automatically — no extra steps needed

echo ""
echo "🚀 Starting OpenClaw Gateway on port 18789..."
echo "   Gateway config: ~/.openclaw/openclaw.json"
echo "   Workspace: $(pwd)"
echo ""
echo "   Note: Sub-agent sandboxing, web search, and Telegram are"
echo "   configured in ~/.openclaw/openclaw.json"
echo ""
echo "   Press Ctrl+C to stop."
echo "================================="

# Use TMPDIR=/tmp to bypass macOS com.apple.provenance restriction
# on the default temp dir that prevents lock file creation
exec TMPDIR=/tmp openclaw gateway
