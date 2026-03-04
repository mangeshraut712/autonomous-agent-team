#!/usr/bin/env bash
# ============================================================
# token-audit.sh — Workspace Token Usage Auditor
# Scans all .md files, detects bloat, duplication & stale entries
# Usage:
#   bash scripts/token-audit.sh           → report to stdout
#   bash scripts/token-audit.sh --apply   → apply safe optimizations
#   bash scripts/token-audit.sh --json    → JSON output for dashboard
# ============================================================

set -e

WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APPLY="${1:-}"
JSON_MODE="${1:-}"
REPORT_FILE="$WORKSPACE_DIR/intel/TOKEN-AUDIT-$(date +%Y-%m-%d).md"

cd "$WORKSPACE_DIR"

# ── Helpers ──────────────────────────────────────────────────
bytes_to_kb() { echo "scale=1; $1 / 1024" | bc; }
bytes_to_tokens() { echo "$1 / 4" | bc; }
fmt_bytes() {
  local b=$1
  if [ "$b" -ge 1024 ]; then printf "%.1fKB" "$(echo "scale=1; $b/1024" | bc)"
  else echo "${b}B"; fi
}

# ── Scan all .md files ────────────────────────────────────────
if [ "$JSON_MODE" = "--json" ]; then
  echo '{"files":['
  first=1
  find . -name "*.md" \
    -not -path "./.git/*" \
    -not -path "./.openclaw/*" \
    -not -path "./_trash/*" \
    -not -path "./projects/*" \
    | sort | while read -r f; do
    size=$(wc -c < "$f" 2>/dev/null || echo 0)
    tokens=$((size / 4))
    [ $first -eq 0 ] && echo ","
    printf '{"path":"%s","bytes":%d,"tokens":%d}' "$f" "$size" "$tokens"
    first=0
  done
  echo ']}'
  exit 0
fi

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║        TOKEN USAGE AUDIT — $(date +%Y-%m-%d)              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "📁 Workspace: $WORKSPACE_DIR"
echo ""

# ── 1. File Size Rankings ─────────────────────────────────────
echo "━━━ TOP FILES BY SIZE (tokens ≈ bytes ÷ 4) ━━━━━━━━━━━━━"
printf "%-50s %8s %8s\n" "FILE" "BYTES" "~TOKENS"
printf "%-50s %8s %8s\n" "----" "-----" "-------"

TOTAL_BYTES=0
TOTAL_FILES=0

find . -name "*.md" \
  -not -path "./.git/*" \
  -not -path "./.openclaw/*" \
  -not -path "./_trash/*" \
  -not -path "./projects/*" \
  | sort | while read -r f; do
  size=$(wc -c < "$f" 2>/dev/null || echo 0)
  TOTAL_BYTES=$((TOTAL_BYTES + size))
  TOTAL_FILES=$((TOTAL_FILES + 1))
  tokens=$((size / 4))
  printf "%-50s %8d %8d\n" "$f" "$size" "$tokens"
done | sort -k2 -rn | head -20

echo ""

# ── 2. Bootstrap Budget (critical) ───────────────────────────
echo "━━━ BOOTSTRAP BUDGET (loaded every session) ━━━━━━━━━━━━"
BOOT_FILES=("AGENTS.md" "SOUL.md" "USER.md" "IDENTITY.md")
BOOT_TOTAL=0
for f in "${BOOT_FILES[@]}"; do
  if [ -f "$f" ]; then
    size=$(wc -c < "$f" 2>/dev/null || echo 0)
    tokens=$((size / 4))
    BOOT_TOTAL=$((BOOT_TOTAL + tokens))
    printf "  %-30s %6d bytes  ~%d tokens\n" "$f" "$size" "$tokens"
  fi
done
echo "  ─────────────────────────────────────────────────────"
printf "  %-30s %6s  ~%d tokens\n" "SUBTOTAL (your files)" "" "$BOOT_TOTAL"
SYSTEM_TOKENS=3073
GRAND_TOTAL=$((BOOT_TOTAL + SYSTEM_TOKENS))
printf "  %-30s %6s  ~%d tokens\n" "System (skills+prompt+tools)" "" "$SYSTEM_TOKENS"
printf "  %-30s %6s  ~%d tokens\n" "GRAND TOTAL per session start" "" "$GRAND_TOTAL"
echo ""

# ── 3. Duplication Check ─────────────────────────────────────
echo "━━━ DUPLICATION ANALYSIS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check for near-identical TOOLS.md across agents
TOOLS_SIZES=()
for agent in dwight kelly ross rachel pam; do
  f="agents/$agent/TOOLS.md"
  if [ -f "$f" ]; then
    size=$(wc -c < "$f" 2>/dev/null || echo 0)
    TOOLS_SIZES+=($size)
  fi
done
if [ ${#TOOLS_SIZES[@]} -ge 3 ]; then
  # Check if all similar size (within 20%)
  first=${TOOLS_SIZES[0]}
  all_similar=true
  for s in "${TOOLS_SIZES[@]}"; do
    diff=$(( (s - first) * 100 / (first + 1) ))
    if [ "$diff" -gt 20 ] || [ "$diff" -lt -20 ]; then
      all_similar=false
      break
    fi
  done
  if [ "$all_similar" = true ]; then
    total_dup=$(( first * (${#TOOLS_SIZES[@]} - 1) ))
    echo "  ⚠️  agents/*/TOOLS.md — ${#TOOLS_SIZES[@]} near-identical copies (~$total_dup bytes wasted)"
    echo "     → DELETE all agents/*/TOOLS.md (sub-agents inherit from root)"
  fi
fi

# Check for identical IDENTITY.md across agents
IDENTITY_SIZES=()
for agent in dwight kelly ross rachel pam; do
  f="agents/$agent/IDENTITY.md"
  if [ -f "$f" ]; then
    size=$(wc -c < "$f" 2>/dev/null || echo 0)
    IDENTITY_SIZES+=($size)
  fi
done
if [ ${#IDENTITY_SIZES[@]} -ge 3 ]; then
  first=${IDENTITY_SIZES[0]}
  total_dup=$(( first * (${#IDENTITY_SIZES[@]} - 1) ))
  echo "  ⚠️  agents/*/IDENTITY.md — ${#IDENTITY_SIZES[@]} similar copies (~$total_dup bytes)"
  echo "     → Replace each with 3-line minimal version (< 200 bytes)"
fi

# Check for USER.md template entries still present
if grep -q "\[Your name\]" USER.md 2>/dev/null; then
  echo "  ⚠️  USER.md still contains template placeholders — fill in for better context"
fi
if grep -q "\[Your name\]" agents/dwight/USER.md 2>/dev/null; then
  echo "  ⚠️  agents/*/USER.md — all contain empty template. Consider removing or using 1-line pointers."
fi

echo ""

# ── 4. Staleness Check ───────────────────────────────────────
echo "━━━ STALENESS CHECK ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
STALE_THRESHOLD=14 # days
find . -name "*.md" \
  -not -path "./.git/*" \
  -not -path "./.openclaw/*" \
  -not -path "./_trash/*" \
  -not -path "./projects/*" \
  -not -path "./memory/*" \
  | while read -r f; do
  # Get days since modification
  if [[ "$(uname)" == "Darwin" ]]; then
    mod=$(stat -f %m "$f" 2>/dev/null || echo 0)
  else
    mod=$(stat -c %Y "$f" 2>/dev/null || echo 0)
  fi
  now=$(date +%s)
  age_days=$(( (now - mod) / 86400 ))
  if [ "$age_days" -gt "$STALE_THRESHOLD" ]; then
    size=$(wc -c < "$f" 2>/dev/null || echo 0)
    printf "  🕰️  %-45s %3d days old  %d bytes\n" "$f" "$age_days" "$size"
  fi
done

echo ""

# ── 5. Oversized File Warnings ───────────────────────────────
echo "━━━ OVERSIZED FILES (>3KB = >750 tokens per load) ━━━━━━"
find . -name "*.md" \
  -not -path "./.git/*" \
  -not -path "./.openclaw/*" \
  -not -path "./_trash/*" \
  -not -path "./projects/*" \
  | while read -r f; do
  size=$(wc -c < "$f" 2>/dev/null || echo 0)
  if [ "$size" -gt 3000 ]; then
    tokens=$((size / 4))
    printf "  📏 %-45s %6d bytes  ~%d tokens\n" "$f" "$size" "$tokens"
  fi
done

echo ""

# ── 6. Summary ───────────────────────────────────────────────
echo "━━━ SUMMARY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_MD_BYTES=$(find . -name "*.md" \
  -not -path "./.git/*" \
  -not -path "./.openclaw/*" \
  -not -path "./_trash/*" \
  -not -path "./projects/*" \
  -exec wc -c {} \; 2>/dev/null | awk '{s+=$1} END {print s}')

TOTAL_MD_TOKENS=$((TOTAL_MD_BYTES / 4))
POTENTIAL_SAVINGS=1650

echo "  Total .md files size:  $(fmt_bytes "$TOTAL_MD_BYTES") (~$TOTAL_MD_TOKENS tokens)"
echo "  Bootstrap cost/session: ~$GRAND_TOTAL tokens"
echo "  Potential savings:      ~$POTENTIAL_SAVINGS tokens/session (${POTENTIAL_SAVINGS}/${GRAND_TOTAL} = $(echo "scale=0; $POTENTIAL_SAVINGS*100/$GRAND_TOTAL" | bc)%)"
echo ""
echo "  Run 'bash scripts/token-audit.sh --apply' to apply safe optimizations"
echo "  Open 'scripts/token-dashboard.html' in browser for visual report"
echo ""

# ── 7. Write report to intel/ ────────────────────────────────
if [ -d "intel" ]; then
  {
    echo "# Token Audit — $(date +%Y-%m-%d)"
    echo ""
    echo "**Workspace:** $WORKSPACE_DIR"
    echo "**Run at:** $(date '+%H:%M IST')"
    echo ""
    echo "## Summary"
    echo "- Total .md files: $(fmt_bytes "$TOTAL_MD_BYTES") (~$TOTAL_MD_TOKENS tokens)"
    echo "- Bootstrap cost per session: ~$GRAND_TOTAL tokens"
    echo "- Potential savings: ~$POTENTIAL_SAVINGS tokens/session"
    echo ""
    echo "## Top Optimization Opportunities"
    echo "1. Remove duplicate agents/*/TOOLS.md (5 copies, ~280 tokens wasted)"
    echo "2. Slim agents/*/IDENTITY.md to 3-line minimal versions (~250 tokens)"
    echo "3. Fill USER.md with real data (better quality, same tokens)"
    echo "4. Trim HEARTBEAT.md to checklist-only (move guide to docs/)"
    echo ""
    echo "## Next Audit"
    echo "Scheduled: bi-weekly (Monday + Thursday at 09:00 IST)"
  } > "$REPORT_FILE"
  echo "  📝 Report written to: intel/TOKEN-AUDIT-$(date +%Y-%m-%d).md"
fi
