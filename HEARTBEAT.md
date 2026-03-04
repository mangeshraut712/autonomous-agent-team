## Cron Health Check (run on each heartbeat)

Check if any daily cron jobs have stale lastRunAtMs (>26 hours
since last run). If stale, trigger them via CLI:
`openclaw cron run <jobId>`

## Jobs to Monitor

| Time | Agent | Job | ID |
|------|-------|-----|----|
| 8:01 AM | Dwight | Morning research sweep | 64334029-8651-445c-98e8-dd7c45042a28 |
| 9:01 AM & 1:01 PM | Kelly | First/midday viral content check | b30ef0eb-fbcd-41a3-b7b5-22855ea33fe5 |
| 10:01 AM | Ross | Engineering tasks | 8cee5580-04c2-4a93-b620-4bc332b0b279 |

## Self-Healing Protocol

On every heartbeat:
1. Run `openclaw cron list` to check `lastRunAtMs` for each job above.
2. If any job hasn't run in >26 hours, run:
   `openclaw cron run <jobId>`
3. Log the forced re-run in `memory/YYYY-MM-DD.md` under a "Heartbeat" section.

## Order Matters

Always check **Dwight first** — every other agent (Kelly, Rachel, Pam)
depends on his intel output. If Dwight is stale, all content agents are blocked.

## Force-Run All Stale Jobs

```bash
openclaw cron run 64334029-8651-445c-98e8-dd7c45042a28  # Dwight Morning
openclaw cron run b30ef0eb-fbcd-41a3-b7b5-22855ea33fe5  # Kelly Viral
openclaw cron run 8cee5580-04c2-4a93-b620-4bc332b0b279  # Ross Engineering
```
