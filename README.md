# autonomous-agent-team

Production-ready OpenClaw workspace for a 6-agent AI team: research, content drafting, engineering support, and newsletter prep with Telegram delivery and cron automation.

## What You Get

- One OpenClaw instance with six specialized agents.
- File-based coordination (`intel/` handoff) instead of fragile cross-service orchestration.
- Daily/long-term memory workflow for each agent.
- Cron scheduling for unattended runs.
- Telegram bot interface for approvals and status.
- Portable scripts for setup, health checks, and web-search fallback.

## Agent Roster

| Agent | Role | Primary Output |
|---|---|---|
| Monica | Chief of Staff | Planning, delegation, heartbeat checks |
| Dwight | Research | `intel/DAILY-INTEL.md`, `intel/data/YYYY-MM-DD.json` |
| Kelly | X/Twitter | Draft tweet threads |
| Rachel | LinkedIn | Draft professional posts |
| Ross | Engineering | Task plans, reviews, implementation notes |
| Pam | Newsletter | Newsletter and long-form drafts |

## Repository Layout

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
│   └── data/
└── scripts/
    ├── add-cron-jobs.sh
    ├── reset-workspace.sh
    ├── test.sh
    ├── status.sh
    └── parallel-search.sh
```

## Quick Start

1. Install OpenClaw:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

2. Clone and configure:

```bash
git clone https://github.com/mangeshraut712/autonomous-agent-team.git
cd autonomous-agent-team
cp .env.example .env
```

3. Fill `.env`:

```env
TELEGRAM_BOT_TOKEN=...
TELEGRAM_CHAT_TARGET=...
# Optional fallback web search
PARALLEL_API_KEY=...
```

4. Run onboarding:

```bash
openclaw onboard
```

5. Register cron jobs:

```bash
chmod +x scripts/add-cron-jobs.sh
./scripts/add-cron-jobs.sh
```

6. Verify health:

```bash
./scripts/test.sh
./scripts/status.sh
```

## Telegram Settings

Recommended secure policy:

```bash
openclaw config set channels.telegram.dmPolicy allowlist
openclaw config set channels.telegram.allowFrom '["<YOUR_TELEGRAM_USER_ID>"]'
openclaw config set channels.telegram.groupPolicy allowlist
openclaw config set channels.telegram.groupAllowFrom '["<YOUR_TELEGRAM_USER_ID>"]'
openclaw gateway restart
```

Pairing alternative:

```bash
openclaw config set channels.telegram.dmPolicy pairing
openclaw gateway restart
openclaw pairing approve telegram <PAIRING_CODE>
```

## Telegram Workflow

- Send direct test message:

```bash
openclaw message send --channel telegram --target <YOUR_CHAT_ID> --message "OpenClaw test"
```

- Probe Telegram channel health:

```bash
openclaw channels status --probe
```

## Web Search Fallback (Parallel)

If Brave API is unavailable, Dwight can use:

```bash
scripts/parallel-search.sh \
  --objective "latest AI/devtools launches relevant to software teams" \
  --mode agentic \
  --max-results 8 \
  --format markdown
```

## Keep Private Work Out of GitHub

This repository is public-ready. Keep project-specific client/submission work out of tracking.

Recommended:

- Store private project files under `projects/`.
- Ensure private subfolders are added to `.gitignore` before commit.
- Verify before push:

```bash
git status
git ls-files | rg '^projects/'
```

## Security Notes

- Do not commit `.env` or `.openclaw/`.
- Revoke and rotate any token exposed in logs.
- Keep runtime intel/memory artifacts out of Git commits.
- Run periodic checks:

```bash
openclaw security audit --deep
```

## Documentation

See `docs/README.md` and `docs/telegram-setup.md` for setup and command references.

## License

MIT — see `LICENSE`.
