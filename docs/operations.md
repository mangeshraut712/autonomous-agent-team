# Operations Guide

This workspace can be operated from four surfaces:

1. Telegram (best daily driver)
2. OpenClaw Control UI (`http://127.0.0.1:18789`)
3. Terminal (`openclaw ...` commands)
4. Cron/heartbeat background runs

## Where To Start (Recommended)

1. Run `make ready-strict` to verify runtime and policy.
2. Open Telegram and send `/start` to your bot.
3. If pairing appears, approve from terminal:
   `openclaw pairing approve telegram <PAIRING_CODE>`
4. Send a test ping with `make notify`.

## Heartbeat Policy (Token-Safe)

- Heartbeat schedule: every 30 minutes, **08:00–23:00 IST**.
- Outside this window: quiet mode (`HEARTBEAT_QUIET`).
- Heavy scanning does **not** run in heartbeat; it runs in isolated cron sessions.
- Before any compaction/reset, agent must flush learnings to daily memory + `MEMORY.md`.

Install/update default cron set (includes Monica heartbeat):

```bash
make cron-install
```

Override heartbeat window via env if needed:

```bash
# Example: every 20 minutes, 07:00-22:00
OPENCLAW_HEARTBEAT_CRON="*/20 7-22 * * *" make cron-install
```

## Understand Runtime State

Use this sequence:

```bash
openclaw status
openclaw status --all
openclaw gateway probe
openclaw gateway status
openclaw doctor --non-interactive
openclaw channels status --probe
openclaw logs --follow
```

Health endpoint note:

- `curl http://127.0.0.1:18789/health` returns the Control UI HTML shell in this OpenClaw build.
- Use `openclaw gateway probe` as the authoritative health check.

Interpretation:

- `gateway status`: service/runtime and RPC health.
- `channels status --probe`: channel auth and delivery probes.
- `doctor`: config and safety repairs.
- `logs --follow`: real-time failures.

## Background Work Visibility

Cron checks:

```bash
openclaw cron status
openclaw cron list
openclaw cron runs --id <jobId> --limit 20
```

If a job is stale/failed:

```bash
openclaw cron run <jobId> --force
```

## Drift Audit (Cron Sprawl Guardrail)

When cron count grows, agents can over-optimize infrastructure tasks.

Run manual audit:

```bash
make drift-audit
```

- Report output: `intel/DRIFT-AUDIT.md`
- Default threshold: 50 jobs (`DRIFT_CRON_THRESHOLD` to override)
- Sends Telegram alert automatically when risk is flagged

## Workspace Path Safety

Always run from canonical workspace path without trailing space:

- Correct: `/Users/mangeshraut/Downloads/AI Agent`
- Wrong: `/Users/mangeshraut/Downloads/AI Agent `

`make ready-strict` checks this and warns if a trailing-space sibling exists.

Sibling repository note:

- `/Users/mangeshraut/Downloads/always-on-memory-agent` is a separate project with its own git history.
- It is intentionally outside this workspace and is not required for OpenClaw runtime here.
- Keep private contest code in external repos or in `projects/` (gitignored) to avoid accidental public commits.

## Common Recovery Actions

Gateway unhealthy:

```bash
openclaw doctor --non-interactive
openclaw gateway restart
```

Keys present in project `.env` but not used by gateway service:

```bash
make env-sync
openclaw gateway restart
```

Cron exists but no results in intel:

1. Run `openclaw cron runs --id <jobId> --limit 20`
2. Check logs: `openclaw logs --follow`
3. Re-run manually: `openclaw cron run <jobId> --force`

Memory search fails with `insufficient_quota`:

1. Confirm with `openclaw memory index --force --verbose`
2. Keep agents running with file-based fallback (`MEMORY.md` + `memory/YYYY-MM-DD.md`)
3. Record temporary degradation in `intel/BLOCKERS.md` and clear once embeddings quota is restored

## Suggested Daily Cadence

Morning:

1. `make status`
2. Check Telegram drafts from Dwight/Kelly/Rachel
3. Approve/edit drafts

Evening:

1. `openclaw cron status`
2. `openclaw cron runs --id <jobId> --limit 20` for any missed jobs
3. `make ready-strict` before overnight runs
