# BLOCKERS

Last updated: 2026-03-05 (IST)

## Open Blockers
- Cron: Monica Heartbeat (agent:main:heartbeat) keeps hitting `cron: job execution timed out`. First seen 2026-03-05 11:05 IST. Attempted manual run via `openclaw cron run f6863775-7c4c-4013-9d1e-cf1036fc7167`, but it also timed out after ~420 s; status still `error` with `consecutiveErrors=5`.
- Cron: Agent Status Notify keeps hitting `cron: job execution timed out`. First seen 2026-03-05 11:09 IST. Attempted manual run via `openclaw cron run 6d330974-d7a1-4e0c-aa99-a0370caf2f04`, but it timed out again; still `error` with `consecutiveErrors=2`.
- Cron: Ross Engineering (agent:ross:main) last succeeded 2026-03-05 10:14 IST but then timed out (`cron: job execution timed out`). Manual rerun via `openclaw cron run 8cee5580-04c2-4a93-b620-4bc332b0b279` was started but produced no output before I had to terminate the helper session; status still `error` and the job is marked running, so it needs attention.
- Cron: Dwight Morning (agent:dwight:main) failed at 2026-03-05 08:16 IST with `cron: job execution timed out`. Manual rerun via `openclaw cron run 64334029-8651-445c-98e8-dd7c45042a28` is currently running but still not completing; will need debugging if it keeps hanging.

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
