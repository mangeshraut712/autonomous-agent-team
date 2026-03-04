#!/usr/bin/env bash
# scripts/workspace-setup.sh
# Configure this repository as an OpenClaw workspace.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v openclaw >/dev/null 2>&1; then
  echo "Error: openclaw CLI is required. Install via: npm install -g openclaw@latest"
  exit 1
fi

CFG="$HOME/.openclaw/openclaw.json"
SKILLS_DIR="$ROOT_DIR/skills"

echo "🦞 Applying workspace configuration..."

openclaw config set agents.defaults.workspace "$ROOT_DIR"
echo "✅ agents.defaults.workspace -> $ROOT_DIR"

if [[ -d "$SKILLS_DIR" ]]; then
  EXTRA_DIRS='[]'
  if [[ -f "$CFG" ]]; then
    EXTRA_DIRS="$(jq -c --arg d "$SKILLS_DIR" '((.skills.load.extraDirs // []) + [$d]) | unique' "$CFG" 2>/dev/null || echo '[]')"
  else
    EXTRA_DIRS="$(jq -cn --arg d "$SKILLS_DIR" '[$d]')"
  fi
  openclaw config set skills.load.extraDirs "$EXTRA_DIRS"
  echo "✅ skills.load.extraDirs includes $SKILLS_DIR"
else
  echo "⚠️  skills/ directory not found; skipping skills.load.extraDirs"
fi

if [[ -n "${OPENCLAW_WEB_PROVIDER:-}" ]]; then
  openclaw config set tools.web.search.provider "$OPENCLAW_WEB_PROVIDER"
  echo "✅ tools.web.search.provider -> $OPENCLAW_WEB_PROVIDER"
fi

echo
echo "Optional but recommended: sync project .env to gateway service env"
echo "  bash scripts/sync-openclaw-env.sh"
echo
echo "Then run:"
echo "  openclaw doctor --non-interactive"
echo "  openclaw gateway restart"
