# HEARTBEAT.md — Automated Health Check Checklist

_This file is read on every heartbeat cron (default: every 30 minutes)._
_Monica goes through each item in order and reports issues to Telegram._

---

## What Is the Heartbeat?

The heartbeat turns your agents from **reactive chatbots** (only respond when you message them) into **proactive workers** (check on things without you asking).

It's powered by a cron job:

```bash
# Install the heartbeat cron
openclaw cron add \
  --schedule "*/30 8-23 * * *" \
  --agent main \
  --prompt "Run the heartbeat checklist in HEARTBEAT.md." \
  --announce
```

---

## Checklist Template

Copy this section and customize for your setup:

---

### 1. Gateway Health

- Run `curl -s http://127.0.0.1:18789/health` to verify the gateway is responding.
- If it returns an error: alert user on Telegram with restart instructions.

### 2. Cron Job Status

Check these jobs haven't gone stale (more than 26 hours since last run):

| Time     | Agent  | Job Description         | Job ID                |
| -------- | ------ | ----------------------- | --------------------- |
| 8:00 AM  | Dwight | Morning research sweep  | `[paste job ID here]` |
| 9:00 AM  | Kelly  | Content ideas check     | `[paste job ID here]` |
| 10:00 AM | Ross   | Engineering task review | `[paste job ID here]` |

Run `openclaw cron list --json` to check `lastRunAtMs`. If stale → trigger manually:

```bash
openclaw cron run <jobId>
```

### 3. Active Project Blockers

- Check `intel/BLOCKERS.md` — if it exists and has unresolved entries, notify user.
- Check `intel/PROJECT-PLAN.md` — are any phases stuck `[IN PROGRESS]` for over 48 hours?

### 4. Memory Health

- Run `openclaw memory status` to check the vector index.
- If it shows 0 indexed chunks, run `openclaw memory index --force`.

### 5. Self-Healing Protocol

If any check fails:

1. Attempt auto-fix (e.g. restart a stuck cron)
2. Log the incident in `memory/YYYY-MM-DD.md` under a `## Heartbeat` section
3. If unfixable, alert user on Telegram: "🚨 [Issue] needs your attention."

---

## Example: Production Heartbeat Log Entry

```markdown
## Heartbeat — 2026-03-05 09:30 IST

✅ Gateway: online
✅ Cron: Dwight ran 1h ago (ok)
⚠️ Cron: Kelly hasn't run in 28h — triggered manually (job b30ef0eb)
✅ Memory: 95 chunks indexed
```

---

> 💡 **Tip:** The heartbeat is what separates agents that work while you sleep from glorified chatbots. Even a simple checklist with 2-3 items delivers huge value — you'll catch problems before they become crises.
