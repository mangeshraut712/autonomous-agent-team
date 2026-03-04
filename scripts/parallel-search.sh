#!/usr/bin/env bash
# scripts/parallel-search.sh
# Minimal Parallel Search API helper for Dwight fallback research sweeps.
#
# Usage:
#   PARALLEL_API_KEY=... scripts/parallel-search.sh \
#     --objective "latest AI launches and repo trends" \
#     --mode agentic \
#     --max-results 8 \
#     --format markdown

set -euo pipefail

usage() {
  cat <<'EOH'
Usage: scripts/parallel-search.sh [options]

Required:
  --objective <text>      Natural-language search objective

Optional:
  --query <text>          Add a concrete search query (repeatable)
  --mode <mode>           one-shot | fast | agentic (default: agentic)
  --max-results <n>       1-20 (default: 10)
  --format <fmt>          json | markdown (default: json)
  -h, --help              Show help
EOH
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: missing required command '$1'" >&2
    exit 1
  fi
}

require_cmd curl
require_cmd jq

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARALLEL_API_KEY="${PARALLEL_API_KEY:-}"

if [[ -z "$PARALLEL_API_KEY" && -f "$ROOT_DIR/.env" ]]; then
  PARALLEL_API_KEY="$(
    awk -F= '/^PARALLEL_API_KEY=/{print $2}' "$ROOT_DIR/.env" \
      | tail -n1 \
      | tr -d '"' \
      | tr -d "'" \
      | xargs || true
  )"
fi

OBJECTIVE=""
MODE="agentic"
MAX_RESULTS=10
FORMAT="json"
declare -a QUERIES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --objective)
      OBJECTIVE="${2:-}"
      shift 2
      ;;
    --query)
      QUERIES+=("${2:-}")
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --max-results)
      MAX_RESULTS="${2:-10}"
      shift 2
      ;;
    --format)
      FORMAT="${2:-json}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown option '$1'" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$OBJECTIVE" ]]; then
  echo "Error: --objective is required" >&2
  usage
  exit 1
fi

if [[ "$MODE" != "one-shot" && "$MODE" != "fast" && "$MODE" != "agentic" ]]; then
  echo "Error: --mode must be one of: one-shot, fast, agentic" >&2
  exit 1
fi

if ! [[ "$MAX_RESULTS" =~ ^[0-9]+$ ]] || (( MAX_RESULTS < 1 || MAX_RESULTS > 20 )); then
  echo "Error: --max-results must be an integer between 1 and 20" >&2
  exit 1
fi

if [[ "$FORMAT" != "json" && "$FORMAT" != "markdown" ]]; then
  echo "Error: --format must be 'json' or 'markdown'" >&2
  exit 1
fi

if [[ -z "$PARALLEL_API_KEY" ]]; then
  cat >&2 <<'EOH'
Error: PARALLEL_API_KEY is missing.
Set it in either:
  1) Environment: export PARALLEL_API_KEY=...
  2) Workspace .env: PARALLEL_API_KEY=...
EOH
  exit 1
fi

QUERIES_JSON="[]"
if (( ${#QUERIES[@]} > 0 )); then
  QUERIES_JSON="$(printf '%s\n' "${QUERIES[@]}" | jq -R . | jq -s .)"
fi

PAYLOAD="$(
  jq -n \
    --arg objective "$OBJECTIVE" \
    --arg mode "$MODE" \
    --argjson max_results "$MAX_RESULTS" \
    --argjson search_queries "$QUERIES_JSON" \
    '{
      objective: $objective,
      mode: $mode,
      max_results: $max_results,
      search_queries: (if ($search_queries | length) > 0 then $search_queries else null end),
      excerpts: {
        max_chars_per_result: 2000,
        max_chars_total: 20000
      },
      fetch_policy: {
        max_age_seconds: 21600
      }
    }'
)"

RESPONSE="$(
  curl --silent --show-error --fail \
    --request POST \
    --url "https://api.parallel.ai/v1beta/search" \
    --header "content-type: application/json" \
    --header "parallel-beta: search-api=v2" \
    --header "x-api-key: $PARALLEL_API_KEY" \
    --data "$PAYLOAD"
)"

if [[ "$FORMAT" == "json" ]]; then
  echo "$RESPONSE" | jq '{
    search_id,
    objective,
    results: (
      (.results // []) | map({
        title: (.title // ""),
        url: (.url // ""),
        publish_date: (.publish_date // ""),
        source: (.source // ""),
        excerpt: ((.excerpts // [])[0] // "")
      })
    )
  }'
else
  echo "$RESPONSE" | jq -r '
    ["# Parallel Search Results", "", "Objective: " + (.objective // "")] +
    ((.results // []) | to_entries | map(
      ((.key + 1 | tostring) + ". [" + (.value.title // "Untitled") + "](" + (.value.url // "") + ")") +
      (if ((.value.publish_date // "") != "") then " — " + (.value.publish_date // "") else "" end) +
      "\n   " + (((.value.excerpts // [])[0] // "No excerpt."))
    )) | .[]'
fi
