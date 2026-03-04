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

If a job is stale:

```bash
openclaw cron run <jobId> --force
```

## Workspace Path Safety

Always run from canonical workspace path without trailing space:

- Correct: `/Users/mangeshraut/Downloads/AI Agent`
- Wrong: `/Users/mangeshraut/Downloads/AI Agent `

`make ready-strict` checks this and warns if a trailing-space sibling exists.

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

## Suggested Daily Cadence

Morning:

1. `make status`
2. Check Telegram drafts from Dwight/Kelly/Rachel
3. Approve/edit drafts

Evening:

1. `openclaw cron status`
2. `openclaw cron runs --id <jobId> --limit 20` for any missed jobs
3. `make ready-strict` before overnight runs
