#!/usr/bin/env bash
# scripts/sync-openclaw-env.sh
# Sync selected keys from workspace .env to ~/.openclaw/.env for gateway service use.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_ENV="$ROOT/.env"
DST_DIR="$HOME/.openclaw"
DST_ENV="$DST_DIR/.env"

if [[ ! -f "$SRC_ENV" ]]; then
  echo "Error: $SRC_ENV not found"
  exit 1
fi

mkdir -p "$DST_DIR"
touch "$DST_ENV"

read_value() {
  local key="$1"
  local file="$2"
  awk -F= -v k="$key" '
    $1==k {
      v=$0
      sub(/^[^=]*=/, "", v)
      print v
      exit
    }
  ' "$file"
}

upsert_key() {
  local key="$1"
  local raw="$2"
  local escaped
  escaped="$(printf '%s' "$raw" | sed 's/[&/\\]/\\&/g')"

  if grep -q "^${key}=" "$DST_ENV"; then
    sed -i.bak "s|^${key}=.*|${key}=${escaped}|" "$DST_ENV"
  else
    printf '%s=%s\n' "$key" "$raw" >> "$DST_ENV"
  fi
}

keys=(
  TELEGRAM_BOT_TOKEN
  TELEGRAM_CHAT_TARGET
  BRAVE_API_KEY
  GEMINI_API_KEY
  KIMI_API_KEY
  MOONSHOT_API_KEY
  PERPLEXITY_API_KEY
  XAI_API_KEY
  PARALLEL_API_KEY
)

updated=0
for key in "${keys[@]}"; do
  val="${!key:-}"
  if [[ -z "$val" ]]; then
    val="$(read_value "$key" "$SRC_ENV" || true)"
  fi
  if [[ -n "$val" ]]; then
    upsert_key "$key" "$val"
    echo "Synced: $key"
    updated=$((updated + 1))
  fi
done

rm -f "$DST_ENV.bak"

if (( updated == 0 )); then
  echo "No matching keys found to sync."
  exit 1
fi

echo "Synced $updated key(s) to $DST_ENV"
echo "Restart gateway to apply env: openclaw gateway restart"
