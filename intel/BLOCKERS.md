# BLOCKERS

Last updated: 2026-03-05 (IST)

## Open Blockers
- None currently.

## Monitoring Rules
- If any cron job has `consecutiveErrors > 0`, add one bullet with:
  - job name
  - error summary
  - first seen timestamp (IST)
  - recovery action taken
- Remove blocker only after one clean run.

## Known Temporary Constraints
- Semantic memory search is degraded when OpenAI embeddings quota is exhausted (`insufficient_quota`).
- Fallback behavior: read `MEMORY.md` + today's `memory/YYYY-MM-DD.md` directly, do not halt core task execution.

## Resolved
- Agent Status Notify model pinned to `openai-codex/gpt-5.1-codex-mini` to avoid Anthropic credit interruptions.
