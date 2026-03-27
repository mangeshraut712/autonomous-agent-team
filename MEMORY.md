# MEMORY.md — Long-Term Memory (Workspace Scoped)

_Last updated: 2026-03-05 IST_

---

## Scope Guardrail

- This memory file applies only to `/Users/mangeshraut/Downloads/AI Agent`.
- Do not assume authority outside this root.
- If external path work is requested, treat it as a separate scope.

## Operator Profile

- User: Mangesh Raut
- Timezone: IST
- Primary interface: Telegram via Monica
- Communication: direct and concise

## Active Workspace Priorities

1. Keep gateway + cron + Telegram reliable with zero silent failures.
2. Keep all six agents writing inside workspace-relative paths only.
3. Maintain clean, reproducible repo structure for public GitHub users.
4. Progress `projects/gitlab-ai-hackathon-2026/` with production discipline.

## Reliability Rules

- One writer for shared intel files (Dwight writes `intel/DAILY-INTEL.md`).
- Fallback when memory embeddings quota is exhausted:
  - Read `MEMORY.md` + `memory/YYYY-MM-DD.md` directly.
  - Continue work; do not block the task.
- Before compaction/reset: flush key learnings to daily memory first.

## Security Rules

- Never expose gateway port publicly.
- Keep `.env` and `.openclaw` untracked.
- Do not write secrets into tracked markdown files.
