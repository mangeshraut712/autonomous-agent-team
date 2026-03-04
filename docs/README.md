# Documentation Index

## Core Guides

- [operations.md](operations.md): where to start (Telegram, dashboard, terminal), background flow, status checks.
- [telegram-setup.md](telegram-setup.md): secure Telegram configuration, pairing/allowlist, validation.
- [web-search-providers.md](web-search-providers.md): official OpenClaw web providers + Parallel fallback.
- [openclaw-under-the-hood.md](openclaw-under-the-hood.md): architecture, memory model, routing, tool safety, and cost/performance runbook.

## Operator Commands

### Readiness + Status

```bash
make test
make ready-strict
make status
openclaw status
openclaw status --all
openclaw gateway probe
openclaw gateway status
openclaw channels status --probe
make drift-audit
```

### Cron

```bash
make cron-install
openclaw cron status
openclaw cron list
openclaw cron runs --id <jobId> --limit 20
openclaw cron run <jobId> --force
```

### Telegram

```bash
make notify
openclaw pairing list telegram
openclaw pairing approve telegram <PAIRING_CODE>
```

### Security + Repair

```bash
openclaw doctor --non-interactive
openclaw security audit --deep
openclaw security audit --fix
openclaw gateway restart
```
