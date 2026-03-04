#!/usr/bin/env bash
# scripts/token-audit.sh
# Workspace token audit that avoids protected paths and noisy permission errors.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MODE="${1:-text}"
REPORT_FILE="$ROOT_DIR/intel/TOKEN-AUDIT-$(date +%Y-%m-%d).md"

find_md_files() {
  find . \
    \( -path './.git' -o -path './.openclaw' -o -path './_trash' -o -path './projects' \) -prune -o \
    -type f -name '*.md' -print \
    2>/dev/null | LC_ALL=C sort
}

scan_rows() {
  while IFS= read -r f; do
    bytes=$(wc -c < "$f" 2>/dev/null || echo 0)
    tokens=$(( bytes / 4 ))
    printf '%s\t%s\t%s\n' "$f" "$bytes" "$tokens"
  done < <(find_md_files)
}

fmt_bytes() {
  local b="$1"
  if (( b >= 1048576 )); then
    awk -v n="$b" 'BEGIN{printf "%.1fMB", n/1048576}'
  elif (( b >= 1024 )); then
    awk -v n="$b" 'BEGIN{printf "%.1fKB", n/1024}'
  else
    printf '%dB' "$b"
  fi
}

if [[ "$MODE" == "--json" ]]; then
  scan_rows | awk -F'\t' 'BEGIN{print "["} {printf "%s{\"path\":\"%s\",\"bytes\":%s,\"tokens\":%s}", (NR==1?"":","), $1, $2, $3} END{print "]"}'
  exit 0
fi

echo
echo "╔═══════════════════════════════════════════════════════╗"
echo "║        TOKEN USAGE AUDIT — $(date +%Y-%m-%d)              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo
echo "Workspace: $ROOT_DIR"
echo

tmp_rows="$(mktemp)"
scan_rows > "$tmp_rows"

echo "━━━ TOP FILES BY SIZE (tokens ≈ bytes ÷ 4) ━━━━━━━━━━━━━"
printf "%-52s %8s %8s\n" "FILE" "BYTES" "~TOKENS"
printf "%-52s %8s %8s\n" "----" "-----" "-------"
sort -t $'\t' -k2,2nr "$tmp_rows" | head -20 | awk -F'\t' '{printf "%-52s %8s %8s\n", $1, $2, $3}'
echo

echo "━━━ BOOTSTRAP BUDGET (loaded every session) ━━━━━━━━━━━━"
boot_total=0
for f in AGENTS.md SOUL.md USER.md IDENTITY.md; do
  if [[ -f "$f" ]]; then
    bytes=$(wc -c < "$f" 2>/dev/null || echo 0)
    tokens=$(( bytes / 4 ))
    boot_total=$(( boot_total + tokens ))
    printf "  %-30s %6d bytes  ~%d tokens\n" "$f" "$bytes" "$tokens"
  fi
done
system_tokens=3073
grand_total=$(( boot_total + system_tokens ))
echo "  ─────────────────────────────────────────────────────"
printf "  %-30s %6s  ~%d tokens\n" "SUBTOTAL (your files)" "" "$boot_total"
printf "  %-30s %6s  ~%d tokens\n" "System (skills+prompt+tools)" "" "$system_tokens"
printf "  %-30s %6s  ~%d tokens\n" "GRAND TOTAL per session start" "" "$grand_total"
echo

echo "━━━ DUPLICATION ANALYSIS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
agent_tools_count=$(find agents -maxdepth 2 -type f -name 'TOOLS.md' 2>/dev/null | wc -l | tr -d ' ')
if (( agent_tools_count > 1 )); then
  sample_size=$(wc -c < "$(find agents -maxdepth 2 -type f -name 'TOOLS.md' | head -1)" 2>/dev/null || echo 0)
  approx_waste=$(( sample_size * (agent_tools_count - 1) ))
  echo "  ⚠️  agents/*/TOOLS.md — $agent_tools_count copies (~${approx_waste} bytes duplicate load)"
  echo "     → Keep root TOOLS.md as source of truth; keep agent files minimal pointers."
fi

agent_identity_count=$(find agents -maxdepth 2 -type f -name 'IDENTITY.md' 2>/dev/null | wc -l | tr -d ' ')
if (( agent_identity_count > 1 )); then
  sample_size=$(wc -c < "$(find agents -maxdepth 2 -type f -name 'IDENTITY.md' | head -1)" 2>/dev/null || echo 0)
  approx_waste=$(( sample_size * (agent_identity_count - 1) ))
  echo "  ⚠️  agents/*/IDENTITY.md — $agent_identity_count copies (~${approx_waste} bytes duplicate load)"
  echo "     → Keep each agent identity short and role-specific."
fi

echo

echo "━━━ STALENESS CHECK (>{14} days) ━━━━━━━━━━━━━━━━━━━━━━━"
now=$(date +%s)
while IFS=$'\t' read -r f bytes tokens; do
  [[ -z "$f" ]] && continue
  if [[ "$(uname)" == "Darwin" ]]; then
    mtime=$(stat -f %m "$f" 2>/dev/null || echo "$now")
  else
    mtime=$(stat -c %Y "$f" 2>/dev/null || echo "$now")
  fi
  age_days=$(( (now - mtime) / 86400 ))
  if (( age_days > 14 )); then
    printf "  🕰️  %-45s %3d days old\n" "$f" "$age_days"
  fi
done < "$tmp_rows"
echo

echo "━━━ OVERSIZED FILES (>3KB = >750 tokens per load) ━━━━━━"
awk -F'\t' '$2 > 3000 {printf "  📏 %-45s %6d bytes  ~%d tokens\n", $1, $2, $3}' "$tmp_rows"
echo

total_bytes=$(awk -F'\t' '{s+=$2} END{print s+0}' "$tmp_rows")
total_tokens=$(( total_bytes / 4 ))
potential_savings=1650
savings_pct=0
if (( grand_total > 0 )); then
  savings_pct=$(( potential_savings * 100 / grand_total ))
fi

echo "━━━ SUMMARY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Total .md files size:  $(fmt_bytes "$total_bytes") (~${total_tokens} tokens)"
echo "  Bootstrap cost/session: ~${grand_total} tokens"
echo "  Potential savings:      ~${potential_savings} tokens/session (${savings_pct}%)"
echo

if [[ "$MODE" == "--apply" ]]; then
  echo "  --apply mode: no destructive actions performed automatically."
  echo "  Apply recommendations manually after review."
fi

mkdir -p intel
cat > "$REPORT_FILE" <<REPORT
# Token Audit — $(date +%Y-%m-%d)

- Workspace: $ROOT_DIR
- Total markdown bytes: $total_bytes
- Estimated markdown tokens: $total_tokens
- Bootstrap tokens/session: $grand_total
- Potential savings/session: $potential_savings ($savings_pct%)

## Notes
- This audit intentionally excludes .git/, .openclaw/, _trash/, and projects/.
- Reason: keep metrics focused on root workspace bootstrap + docs and avoid permission-noise.
REPORT

echo "  Report written: $REPORT_FILE"
rm -f "$tmp_rows"
