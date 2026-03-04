# Documentation Index

## Setup Guides

| File | Purpose |
|---|---|
| `telegram-setup.md` | Telegram settings, pairing policy, allowlist config, testing, troubleshooting |

## Operational Commands

### Health + Status

```bash
./scripts/test.sh
./scripts/status.sh
openclaw health
openclaw status --probe
```

### Cron

```bash
openclaw cron list
openclaw cron status
openclaw cron run <jobId>
openclaw cron runs <jobId>
```

### Telegram

```bash
openclaw pairing approve telegram <PAIRING_CODE>
openclaw message send --channel telegram --target <CHAT_ID> --message "test"
```

### Security

```bash
openclaw security audit --deep
openclaw security audit --fix
```
