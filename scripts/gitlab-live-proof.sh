#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$ROOT/projects/gitlab-ai-hackathon-2026"
MVP_DIR="$PROJECT_ROOT/mvp"
STATUS_FILE="$PROJECT_ROOT/status/PROJECT-STATUS-$(date +%F).md"

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

need_keys=(
  GITLAB_DUO_ENDPOINT
  GITLAB_DUO_TOKEN
  GITLAB_BASE_URL
  GITLAB_TOKEN
  GITLAB_PROJECT_ID
  GITLAB_MR_IID
)

for k in "${need_keys[@]}"; do
  if [[ -z "${!k:-}" ]]; then
    v="$(read_env_value "$k" "$ROOT/.env" || true)"
    if [[ -n "$v" ]]; then
      export "$k=$v"
    fi
  fi
  if [[ -z "${!k:-}" ]]; then
    echo "Missing required key: $k"
    echo "Add it to $ROOT/.env or export it in shell, then rerun."
    exit 2
  fi
done

export MERGEGATE_USE_DUO=1

cd "$MVP_DIR"
echo "Running Duo credentialed proof..."
npm run proof:duo -- --duo

LATEST_PROOF="$(ls -1t proof/gitlab-proof-*.json 2>/dev/null | head -n1 || true)"
if [[ -z "$LATEST_PROOF" ]]; then
  echo "Proof run completed but no proof artifact found."
  exit 1
fi

mkdir -p "$(dirname "$STATUS_FILE")"
{
  echo
  echo "## Live Duo Proof Run — $(date '+%Y-%m-%d %H:%M %Z')"
  echo "- Ran: \\`npm run proof:duo -- --duo\\`"
  echo "- Artifact: \\`$LATEST_PROOF\\`"
  echo "- Credentials used: Duo + GitLab env present"
} >> "$STATUS_FILE"

cd "$ROOT"
MSG="GitLab live Duo proof run complete. Artifact: $LATEST_PROOF. Status log updated."
bash scripts/notify.sh "$MSG" || true

echo "Done. Logged to $STATUS_FILE"
