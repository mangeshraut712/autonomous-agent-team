#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required. Install Docker Desktop/Engine first."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose v2 is required (docker compose ...)."
  exit 1
fi

echo "Validating docker-compose.yml ..."
docker compose config >/dev/null

echo "Starting OpenClaw gateway container ..."
docker compose up -d gateway

PORT="${OPENCLAW_GATEWAY_PORT:-18789}"

echo
echo "Gateway container status:"
docker compose ps gateway

echo
echo "Dashboard: http://127.0.0.1:${PORT}/"
echo "Logs: docker compose logs -f gateway"
