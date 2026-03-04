# autonomous-agent-team

Production-ready OpenClaw workspace template for a 6-agent team (Monica, Dwight, Kelly, Rachel, Ross, Pam) with Telegram delivery, cron automation, and source-controlled agent behavior files.

This repository is **not** the OpenClaw core project. It is a workspace on top of OpenClaw.

- OpenClaw core: https://github.com/openclaw/openclaw
- OpenClaw docs: https://docs.openclaw.ai
- OpenClaw site: https://openclaw.ai

## What Was Fixed/Upgraded

- Added stable operator targets: `make ready-strict`, `make notify`, `make notifier-install`.
- Added strict diagnostics aligned to official runbooks (`status`, `gateway probe`, `doctor`, `channels status --probe`).
- Hardened cron installer (`scripts/add-cron-jobs.sh`) to avoid model lock-in and gateway mismatch issues.
- Added environment sync (`scripts/sync-openclaw-env.sh`) so gateway service sees your API keys.
- Expanded provider support docs/env examples for official `web_search` providers (Brave, Gemini, Kimi, Perplexity, Grok) plus Parallel fallback.
- Cleaned repo flow for public GitHub use while keeping private work excluded.

## Quick Start

1. Clone and enter repository.

```bash
git clone https://github.com/mangeshraut712/autonomous-agent-team.git
cd autonomous-agent-team
cp .env.example .env
```

2. Fill `.env` with Telegram + provider keys.

3. If OpenClaw is not installed yet:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
openclaw onboard
```

4. Apply workspace settings and sync env into gateway service environment:

```bash
make workspace-setup
make env-sync
```

5. Restart gateway and run strict checks:

```bash
openclaw gateway restart
make ready-strict
```

6. Install default cron schedule and optional status notifier:

```bash
make cron-install
make notifier-install
```

7. Send Telegram test notification:

```bash
make notify
```

## Canonical Workspace Path

Use one canonical path only:

- ✅ `/Users/mangeshraut/Downloads/AI Agent`
- ❌ `.../AI Agent ` (trailing-space variant)

`make ready-strict` checks for trailing-space path collisions.

## Telegram Setup (Recommended)

If you prefer pairing-first security:

```bash
openclaw config set channels.telegram.dmPolicy pairing
openclaw gateway restart
openclaw pairing approve telegram <PAIRING_CODE>
```

Then harden to allowlist:

```bash
openclaw config set channels.telegram.dmPolicy allowlist
openclaw config set channels.telegram.allowFrom '["<YOUR_TELEGRAM_USER_ID>"]'
openclaw config set channels.telegram.groupPolicy allowlist
openclaw config set channels.telegram.groupAllowFrom '["<YOUR_TELEGRAM_USER_ID>"]'
openclaw gateway restart
```

Detailed guide: [docs/telegram-setup.md](docs/telegram-setup.md)

## Web Search Providers

OpenClaw official `web_search` providers:

- Brave (`BRAVE_API_KEY`)
- Gemini (`GEMINI_API_KEY`)
- Kimi / Moonshot (`KIMI_API_KEY` or `MOONSHOT_API_KEY`)
- Perplexity (`PERPLEXITY_API_KEY`)
- Grok (`XAI_API_KEY`)

Custom fallback in this repo:

- Parallel Search (`PARALLEL_API_KEY`) via `scripts/parallel-search.sh`

Provider setup guide: [docs/web-search-providers.md](docs/web-search-providers.md)

## Make Targets

```bash
make help
make workspace-setup
make env-sync
make status
make test
make ready-strict
make cron-install
make notify
make notifier-install
make reset-workspace
```

## Project Structure

```text
.
├── SOUL.md
├── AGENTS.md
├── MEMORY.md
├── HEARTBEAT.md
├── agents/
│   ├── dwight/
│   ├── kelly/
│   ├── rachel/
│   ├── ross/
│   └── pam/
├── docs/
├── intel/
├── scripts/
└── skills/
```

## Daily Operations

- System snapshot: `make status`
- Strict readiness: `make ready-strict`
- Health checks: `make test`
- Cron list: `openclaw cron list`
- Cron runs: `openclaw cron runs --id <JOB_ID> --limit 20`
- Channel probe: `openclaw channels status --probe`

## Keep Private Work Out Of Public Repo

Private challenge work is excluded from Git tracking:

- `projects/gitlab-ai-hackathon-2026/`

Before pushing:

```bash
git status
git ls-files | rg '^projects/'
```

## Troubleshooting Ladder (Official-Aligned)

Run in order:

```bash
openclaw status
openclaw status --all
openclaw gateway probe
openclaw gateway status
openclaw doctor --non-interactive
openclaw channels status --probe
openclaw logs --follow
```

## Documentation

- [docs/README.md](docs/README.md)
- [docs/operations.md](docs/operations.md)
- [docs/telegram-setup.md](docs/telegram-setup.md)
- [docs/web-search-providers.md](docs/web-search-providers.md)

## License

MIT — see [LICENSE](LICENSE)
