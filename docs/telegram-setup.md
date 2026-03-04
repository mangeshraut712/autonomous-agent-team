# Telegram Setup & Testing Guide

This guide walks you through connecting your autonomous agent team to Telegram
and testing that everything works end-to-end.

---

## Your Current Setup

From your `openclaw.json`:
- **Bot token**: already configured ✅
- **DM policy**: `pairing` (secure — only paired users can message the bot)
- **Group policy**: `open`
- **Streaming**: `partial` (shows typing indicators)

Your Telegram bot is: the one you created during `openclaw onboard`.

---

## Step 1 — Find your bot on Telegram

1. Open Telegram on your phone or desktop
2. In the search bar, search for your bot by name (whatever you named it during BotFather setup)
3. Tap **Start** or send `/start`

The bot will respond with a pairing request because `dmPolicy: pairing` requires you to authenticate first.

---

## Step 2 — Pair your account

Because `dmPolicy` is set to `pairing`, your Telegram account needs to be
explicitly paired to the gateway.

After you message the bot, Telegram returns a pairing code like `ABCD1234`.

Approve that code in terminal:
```bash
openclaw pairing approve telegram <PAIRING_CODE>
```

Check pending requests:
```bash
openclaw pairing list
```

After pairing, your Telegram ID gets added to the allowlist and future
messages go through directly.

---

## Step 3 — Send your first message

Once paired, message your bot:

```
hey monica, what's your role?
```

Monica should respond within a few seconds explaining her Chief of Staff role.

**Other good first messages:**
```
monica, who's on the team?
```
```
monica, do a heartbeat check
```
```
monica, ask dwight to research what's trending in AI today
```

---

## Step 4 — Test each agent

### Test Monica (coordination)
```
monica, summarize your squad
```

### Test Dwight (research) — manual trigger
```bash
openclaw cron run 64334029-8651-445c-98e8-dd7c45042a28
```

### Test Kelly (tweet drafts) — after Dwight has run
```bash
openclaw cron run b30ef0eb-fbcd-41a3-b7b5-22855ea33fe5
```

### Test Ross (engineering)
```
monica, ask ross to review [paste a code snippet or GitHub PR link]
```

---

## Step 5 — Run the full test suite

```bash
chmod +x scripts/test.sh
./scripts/test.sh
```

This checks:
1. All workspace files exist
2. No secrets are tracked by git  
3. Gateway is reachable
4. Cron jobs are registered
5. Telegram bot token is valid (live API call)

---

## Telegram Commands (built-in OpenClaw)

Once connected, you can use these in Telegram:

| Command | What it does |
|---------|-------------|
| `/start` | Begin session |
| `/new` | Start a fresh session (clears context) |
| `/help` | Show available commands |
| `hey monica` | Wake up Monica |
| `@botname message` | Direct mention (useful in groups) |

---

## Managing Notifications

The agents send you things proactively based on their cron schedules.
By default they message you when their job completes.

**To see all pending messages**: Open Telegram — they queue up while you sleep.

**To pause a job temporarily:**
```bash
openclaw cron disable <jobId>
```

**To resume:**
```bash
openclaw cron enable <jobId>
```

---

## Troubleshooting

### Bot doesn't respond
1. Check gateway is running: `curl http://127.0.0.1:18789/` — should return something
2. Check Telegram token: `curl https://api.telegram.org/bot<YOUR_TOKEN>/getMe`
3. Check pairing status: `openclaw pairing list` (approve new code with `openclaw pairing approve telegram <CODE>`)
4. Restart gateway: `openclaw gateway restart`

### "Device signature invalid" error
This happens when the gateway lock file gets corrupted (e.g. after force-killing the process).
```bash
# Re-onboard (your settings are saved, just say yes to keep existing config)
openclaw onboard
```

### Agent responds but output is wrong
Give feedback directly in Telegram: *"kelly, no emojis and no hashtags, remember that"*
The agent will update its MEMORY.md. Quality improves after a few correction cycles.

### Cron job didn't run at schedule time
Monica's heartbeat catches this. Or run manually:
```bash
openclaw cron run <jobId>
```

---

## Checking Logs

```bash
# Recent gateway logs
openclaw logs

# Cron run history for a specific job
openclaw cron runs <jobId>

# Dashboard (web UI)
open http://127.0.0.1:18789
```

---

## Your Cron Job IDs (for manual testing)

| Agent | Job | ID |
|-------|-----|----|
| Dwight | Morning Research (8:01 AM) | `64334029-8651-445c-98e8-dd7c45042a28` |
| Kelly | Viral Check (9:01 AM, 1:01 PM) | `b30ef0eb-fbcd-41a3-b7b5-22855ea33fe5` |
| Ross | Engineering (10:01 AM) | `8cee5580-04c2-4a93-b620-4bc332b0b279` |

Run any job now with:
```bash
openclaw cron run <ID>
```
