#!/usr/bin/env bash
# scripts/workspace-setup.sh
# Configures advanced OpenClaw settings for this workspace.
# Run this once after cloning.

set -euo pipefail

if ! command -v openclaw >/dev/null 2>&1; then
  echo "Error: openclaw CLI is required."
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🦞 Applying advanced OpenClaw configuration..."

# 1. Register the current path as the root OpenClaw workspace
openclaw config set agents.defaults.workspace "$ROOT_DIR"
echo "✅ Default workspace set to $ROOT_DIR"

# 2. Add local skills to the path
openclaw config set skills.load.extraDirs '["'"$ROOT_DIR"'/skills"]'
echo "✅ Local skills path registered ($ROOT_DIR/skills)"

# 3. Allow bundled features + our newly added parallel-search
openclaw config set skills.allowBundled '["parallel-search", "healthcheck", "session-logs", "summarize"]'
echo "✅ Hand-picked skills whitelisted"

# 4. Agent security: we encourage non-main sessions run inside Docker.
echo "⚠️  To enable Docker Sandboxing for extra security, run:"
echo "openclaw config set agents.defaults.sandbox.mode \"non-main\""

# 5. Tailscale support
echo "⚠️  To expose your Gateway securely via Tailscale Serve, run:"
echo "openclaw config set gateway.tailscale.mode \"serve\""

echo ""
echo "🚀 Workspace upgrade complete! Now restart your gateway:"
echo "openclaw gateway restart"
