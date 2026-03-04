# Telegram Setup

This guide follows official OpenClaw Telegram policy behavior.

## 1. Create/Rotate Bot Token

1. Open `@BotFather`
2. Run `/newbot` (or `/revoke` + `/token` to rotate)
3. Copy token
4. Update `.env` and run:

```bash
make env-sync
openclaw gateway restart
```

If any token was exposed in terminal/screenshots, rotate immediately.

## 2. Configure DM Policy

Start with pairing (safer first run):

```bash
openclaw config set channels.telegram.dmPolicy pairing
openclaw gateway restart
```

From Telegram, message your bot and approve pairing:

```bash
openclaw pairing list telegram
openclaw pairing approve telegram <PAIRING_CODE>
```

## 3. Move To Allowlist (Recommended for Production)

Use numeric Telegram user ID (not bot username):

```bash
openclaw config set channels.telegram.dmPolicy allowlist
openclaw config set channels.telegram.allowFrom '["<YOUR_TELEGRAM_USER_ID>"]'
openclaw config set channels.telegram.groupPolicy allowlist
openclaw config set channels.telegram.groupAllowFrom '["<YOUR_TELEGRAM_USER_ID>"]'
openclaw gateway restart
```

## 4. Validate Telegram End-To-End

```bash
# Token validity
curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe"

# OpenClaw transport probe
openclaw channels status --probe

# Direct send
make notify
```

## 5. Troubleshooting

No replies:

```bash
openclaw status
openclaw gateway status
openclaw channels status --probe
openclaw logs --follow
```

Pairing code appears but approve fails:

- Ensure gateway is running from same profile/config
- Re-run `openclaw pairing list telegram`
- Use exact code shown in Telegram

`dmPolicy=allowlist` but bot ignores messages:

- Check `channels.telegram.allowFrom` has your numeric user ID
- Do not use `@username` here

Gateway connected but Telegram still blocked:

```bash
openclaw doctor --non-interactive
openclaw gateway restart
```
