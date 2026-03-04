#!/usr/bin/env bash
# scripts/enforce-root-boundary.sh
# Validate and optionally fix workspace boundary drift.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANONICAL="/Users/mangeshraut/Downloads/AI Agent"
MODE="${1:-check}"
CFG="$HOME/.openclaw/openclaw.json"

RC=0
ok(){ echo "✅ $1"; }
warn(){ echo "⚠️  $1"; }
fail(){ echo "❌ $1"; RC=1; }

if [[ "$ROOT" == "$CANONICAL" ]]; then
  ok "Running from canonical root"
else
  fail "Current root '$ROOT' != '$CANONICAL'"
fi

if [[ "$MODE" == "--fix" ]]; then
  openclaw config set agents.defaults.workspace "$CANONICAL" >/dev/null || true
  openclaw config set gateway.trustedProxies '["127.0.0.1","::1"]' >/dev/null || true

  if [[ -f "$CFG" ]]; then
    tmp="$(mktemp)"
    jq '
      .agents.list = ((.agents.list // []) | map(
        if .id == "dwight" then .workspace = "/Users/mangeshraut/Downloads/AI Agent/agents/dwight"
        elif .id == "kelly" then .workspace = "/Users/mangeshraut/Downloads/AI Agent/agents/kelly"
        elif .id == "rachel" then .workspace = "/Users/mangeshraut/Downloads/AI Agent/agents/rachel"
        elif .id == "ross" then .workspace = "/Users/mangeshraut/Downloads/AI Agent/agents/ross"
        elif .id == "pam" then .workspace = "/Users/mangeshraut/Downloads/AI Agent/agents/pam"
        else . end
      ))
    ' "$CFG" > "$tmp"
    mv "$tmp" "$CFG"
  fi

  ok "OpenClaw workspace + trusted proxy settings repaired"
fi

if [[ -f "$CFG" ]]; then
  WS="$(jq -r '.agents.defaults.workspace // ""' "$CFG")"
  if [[ "$WS" == "$CANONICAL" ]]; then
    ok "agents.defaults.workspace is canonical"
  else
    fail "agents.defaults.workspace drift: $WS"
  fi

  BAD_AGENT_WS="$(jq -r '.agents.list[]? | select(.workspace != null and (.workspace | startswith("/Users/mangeshraut/Downloads/AI Agent") | not)) | "\(.id): \(.workspace)"' "$CFG")"
  if [[ -n "$BAD_AGENT_WS" ]]; then
    fail "Agent workspace(s) outside root detected:"
    echo "$BAD_AGENT_WS"
  else
    ok "All explicit agent workspaces are within root"
  fi
else
  warn "~/.openclaw/openclaw.json not found; skipped config checks"
fi

ROGUE=$(grep -R "AI Agent " "$HOME/Library/LaunchAgents"/ai.openclaw*.plist 2>/dev/null || true)
if [[ -n "$ROGUE" ]]; then
  fail "Rogue LaunchAgent references trailing-space path detected"
  echo "$ROGUE"
  echo "Fix: remove offending plist and reload services"
else
  ok "No trailing-space LaunchAgent path drift"
fi

if [[ -d "/Users/mangeshraut/Downloads/AI Agent " ]]; then
  fail "Trailing-space sibling folder exists: /Users/mangeshraut/Downloads/AI Agent "
else
  ok "No trailing-space sibling folder"
fi

EXT=$(rg -n "/Users/mangeshraut/Downloads/(?!AI Agent)" -S "$ROOT/AGENTS.md" "$ROOT/USER.md" "$ROOT/MEMORY.md" 2>/dev/null || true)
if [[ -n "$EXT" ]]; then
  warn "External absolute paths found in core context files"
  echo "$EXT"
else
  ok "Core context files have no external absolute paths"
fi

if (( RC > 0 )); then
  exit 1
fi
