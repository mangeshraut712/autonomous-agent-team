# Telegram Settings and Setup

Use this guide to configure Telegram correctly for OpenClaw in a public-safe way.

## Required Settings

Set these values in `.env`:

```env
TELEGRAM_BOT_TOKEN=<token from @BotFather>
TELEGRAM_CHAT_TARGET=<your numeric Telegram user/chat id>
```

## Recommended Telegram Policy

Set strict DM/group policies and allowlists:

```bash
openclaw config set channels.telegram.dmPolicy allowlist
openclaw config set channels.telegram.allowFrom '["<YOUR_TELEGRAM_USER_ID>"]'
openclaw config set channels.telegram.groupPolicy allowlist
openclaw config set channels.telegram.groupAllowFrom '["<YOUR_TELEGRAM_USER_ID>"]'
openclaw gateway restart
```

If you prefer pairing flow (safer for first setup):

```bash
openclaw config set channels.telegram.dmPolicy pairing
openclaw gateway restart
```

Then approve each pairing request:

```bash
openclaw pairing approve telegram <PAIRING_CODE>
```

## How to Get Your Telegram User ID

1. Message your bot with `/start` while `dmPolicy=pairing`, then read the user id from the pairing message.
2. Or use a Telegram utility bot like `@userinfobot`.

## Basic Validation

```bash
# Check bot token
curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe"

# Send test message
openclaw message send --channel telegram --target <YOUR_CHAT_ID> --message "OpenClaw Telegram test"

# Probe channel health
openclaw channels status --probe
```

## Troubleshooting

### Bot not responding

```bash
openclaw health
openclaw gateway status
openclaw logs --limit 200
```

### Pairing keeps failing

```bash
openclaw pairing list
openclaw pairing approve telegram <PAIRING_CODE>
```

### Gateway/channel stale state

```bash
openclaw gateway restart
```
