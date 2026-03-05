# 🤖 Autonomous Agent Team — OpenClaw Workspace Template

> A **production-ready, 6-agent AI workspace** built on [OpenClaw](https://github.com/openclaw/openclaw). Clone it, fill in your keys, and have an enterprise-quality autonomous agent team running on Telegram in under 15 minutes.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/powered%20by-OpenClaw-blueviolet)](https://openclaw.ai)
[![Model](https://img.shields.io/badge/default%20model-Configurable%20(via%20.env)-orange)](.env.example)

---

## 🧠 What This Is

Most people who install OpenClaw run it **blind** — empty workspace files, full sandbox off, no memory strategy, wasting 3× more tokens than they need to.

This repo is the **fully configured, battle-tested version**. It implements every best practice from the OpenClaw architecture playbook:

- ✅ **Bootstrap memory** — AGENTS.md, SOUL.md, USER.md, IDENTITY.md preloaded into every agent turn
- ✅ **Semantic search memory** — MEMORY.md + daily logs indexed via OpenAI embeddings
- ✅ **Proper sandbox** — sub-agents sandboxed (`non-main`), main agent unrestricted
- ✅ **Isolated sessions** — `dmScope: per-channel-peer` so no conversation leaks between users
- ✅ **Agent-to-agent comms** — uses native `sessions_send` / `sessions_list` / `sessions_history` tools, not file hacks
- ✅ **Automated heartbeat** — cron-driven health checks every 30 minutes
- ✅ **Web search** — Kimi provider enabled out of the box
- ✅ **Security rules** — SECURITY_RULES.md with anti-prompt-injection policies

---

## 👥 The 6-Agent Team

| Agent | Role | Speciality |
|-------|------|-----------|
| 🎯 **Monica** | Chief of Staff | Orchestrates the team, routes tasks, manages cross-agent comms |
| 🔍 **Dwight** | Intel & Research | Web research, competitive analysis, writing to `intel/` |
| 👩‍💻 **Ross** | Engineering | Code, scripts, APIs, technical implementation |
| 📱 **Kelly** | Social Media | Twitter/X threads, viral content, trend analysis |
| 💼 **Rachel** | LinkedIn & PR | Professional content, networking posts |
| ✍️ **Pam** | Narrative & Submissions | Blog posts, Devpost/hackathon narratives, documentation |

**How they talk to each other:** Monica receives your Telegram message → decomposes the task → calls each agent directly using `sessions_send` → collects results → reports back. No manual switching, no copy-pasting between chats.

---

## ⚡ Quick Start

### 1. Prerequisites

```bash
# Install OpenClaw
npm install -g openclaw

# Verify
openclaw --version
```

### 2. Clone + Configure

```bash
git clone https://github.com/mangeshraut712/autonomous-agent-team.git
cd autonomous-agent-team
cp .env.example .env
```

Edit `.env` with your keys:
```bash
# Required
TELEGRAM_BOT_TOKEN=your_bot_token    # From @BotFather
TELEGRAM_CHAT_TARGET=your_user_id    # Your Telegram numeric user ID

# Model provider (set at least one)
OPENAI_API_KEY=sk-proj-...
ANTHROPIC_API_KEY=sk-ant-...

# Web search providers (pick one or more)
KIMI_API_KEY=sk-...
# OR: BRAVE_API_KEY / PERPLEXITY_API_KEY / XAI_API_KEY / GEMINI_API_KEY

# Optional: force cron model to avoid credit/budget issues
OPENCLAW_CRON_MODEL=openai-codex/gpt-5.1-codex-mini
```

### 3. Configure OpenClaw

```bash
openclaw configure
```
Select your model provider, set workspace to this repo's directory.

### 4. Personalize Your Workspace

Edit 3 files to make the agents yours:

```bash
# Who are you?
nano USER.md

# What's your agent's name and vibe?
nano IDENTITY.md

# What should agents always remember?
nano MEMORY.md
```

### 5. Start the Gateway

```bash
# Standard (Linux/WSL)
openclaw gateway start

# macOS (TMPDIR fix for Sequoia+)
TMPDIR=/tmp bash scripts/start-gateway.sh
```

### 6. Send Monica a Message on Telegram!

Message your bot. Monica will introduce herself and the team is live. 🎉

### 7. Workspace Boundary Check (Important)

This repo expects the canonical workspace path:

```bash
/Users/mangeshraut/Downloads/AI Agent
```

`always-on-memory-agent` is a sibling repository in `Downloads/`, not part of this repo runtime. Keep it separate unless you intentionally copy files.

Run this anytime to verify boundary + runtime:

```bash
make boundary-fix
make ready-strict
```


## 🚀 Deployment Paths

- Native local gateway: `bash scripts/start-gateway.sh`
- Docker compose: `make deploy-docker`
- Full deployment runbook: [docs/deployment.md](docs/deployment.md)

## 🖥️ Dashboards

Use these interfaces to monitor and operate the system:

- **OpenClaw Control UI (live gateway):** [http://127.0.0.1:18789/](http://127.0.0.1:18789/)
- **Mission Control dashboard (local static UI):** [dashboard/index.html](dashboard/index.html)
- **Token usage dashboard (local static UI):** [scripts/token-dashboard.html](scripts/token-dashboard.html)

Open quickly from terminal:

```bash
open http://127.0.0.1:18789/
open dashboard/index.html
open scripts/token-dashboard.html
```

---

## 🧠 Understanding the Two-Level Memory System

This is the #1 thing most OpenClaw users get wrong.

### Level 1: Bootstrap Memory (Every Request)
These files are **injected into context before every single LLM call**:

```
AGENTS.md     → Global rules for all agents (roles, tools, safety)
SOUL.md       → Personality, tone, limits
USER.md       → Who you are — the agent reads this every message
IDENTITY.md   → The agent's name, role, and team structure
memory/YYYY-MM-DD.md → Today's running log
```

**Cost:** Tokens per request. Keep these concise.  
**Value:** The agent "knows you" from message #1, zero re-explaining.

### Level 2: Semantic Search Memory (On Demand)
These files are **vector-indexed** and only retrieved when relevant:

```
MEMORY.md     → Permanent facts, decisions, project details
memory/*.md   → Daily logs (hundreds of them, searchable)
```

**Cost:** Zero tokens until you query for something.  
**Value:** "Where do we usually deploy?" → Agent finds it from 3 months ago.

**Strategy:**
- Bootstrap = critical things needed every message (identity, rules, today's context)
- Semantic = everything that should survive and be findable but not loaded every time

---

## 📁 Repository Structure

```
autonomous-agent-team/
│
├── 📋 Core Workspace Files (bootstrap memory)
│   ├── AGENTS.md          → Global session rules for all 6 agents
│   ├── SOUL.md            → Monica's personality & collaboration style
│   ├── IDENTITY.md        → Template: agent name, role, team
│   ├── USER.md            → Template: fill with your profile
│   ├── MEMORY.md          → Template: your long-term semantic memory
│   ├── HEARTBEAT.md       → Automated health check checklist
│   ├── TOOLS.md           → Local tools & script catalog
│   └── SECURITY_RULES.md  → Anti-prompt-injection policies
│
├── 👥 agents/             → Sub-agent workspaces
│   ├── dwight/            → SOUL.md (research identity + rules)
│   ├── kelly/             → SOUL.md (social media identity)
│   ├── rachel/            → SOUL.md (LinkedIn identity)
│   ├── ross/              → SOUL.md (engineering identity)
│   └── pam/               → SOUL.md (writing identity)
│
├── 🎓 skills/             → Custom reusable OpenClaw skills
│   ├── parallel-search/   → Multi-source parallel web search
│   ├── task-decompose/    → Break complex tasks into phased execution
│   └── sdlc-execution/    → Enforce communication→deployment delivery loop
│
├── 📚 docs/               → Operator guides
│   ├── operations.md      → Day-to-day runbook
│   ├── telegram-setup.md  → Telegram security configuration
│   ├── web-search-providers.md → Provider comparison & setup
│   ├── openclaw-under-the-hood.md → Architecture deep-dive
│   └── contest-command-center.md   → Gemini + GitLab contest control board
│
├── 🛠️ scripts/            → Shell utilities
│   ├── start-gateway.sh         → Reliable gateway starter (macOS TMPDIR fix)
│   ├── add-cron-jobs.sh         → Install default agent cron schedules
│   ├── notifier-install.sh      → Install/update recurring status notifier cron
│   ├── enforce-root-boundary.sh → Hard boundary check/fix for workspace drift
│   ├── status.sh                → Runtime snapshot (gateway, cron, provider)
│   ├── contest-status.sh        → Gemini + GitLab readiness and deadline snapshot
│   ├── sdlc-guard.sh           → Full SDLC gate (planning/build/test/deploy)
│   ├── cleanup-root.sh         → Archive local noise and clean root metadata
│   ├── deploy-docker.sh        → Launch OpenClaw via docker-compose
│   ├── ready-strict.sh          → Strict production readiness checks
│   ├── test.sh                  → Health checks before production/demo
│   └── token-dashboard.html     → Local token usage dashboard
│
├── 🖥️ dashboard/          → Local mission-control style UI
│   └── index.html
│
├── 🧠 memory/             → Daily logs (.gitignored, stays local)
│   └── YYYY-MM-DD.md      → Created fresh each day by agents
│
├── intel/                 → Research output (.gitignored, stays local)
│   ├── DAILY-INTEL.md     → Dwight writes here, Kelly/Rachel/Pam read
│   └── BLOCKERS.md        → Shared runtime blockers + recovery log
│
├── .env.example           → API key template
├── docker-compose.yml     → One-command deploy with Docker
└── Makefile               → Convenience targets
```

---

## 🏗️ Architecture: How a Message Becomes a Response

```
You → Telegram → Gateway → Monica (main agent)
                    ↓
             Assembles context:
             AGENTS.md + SOUL.md + USER.md + today's log
                    ↓
             Decides routing strategy
                    ↓
        ┌───────────────────────┐
        │  sessions_send →      │
        │  Dwight (research)    │
        │  Ross (engineering)   │
        │  Kelly (social)       │
        │  Rachel (LinkedIn)    │
        │  Pam (writing)        │
        └───────────────────────┘
                    ↓
             Collects results
                    ↓
You ← Telegram ← Gateway ← Final response
```

Everything is text files. Sessions are `.jsonl`. Config is `.json`. You can read, edit, and debug everything.

---

## ⚙️ Configuration Reference

### OpenClaw Config (`~/.openclaw/openclaw.json`)

Key settings this template sets up:

```json
{
  "agents": {
    "defaults": {
      "model": { "primary": "provider/model-id" },
      "compaction": { "mode": "safeguard" },
      "sandbox": { "mode": "non-main" },
      "maxConcurrent": 6
    }
  },
  "session": { "dmScope": "per-channel-peer" },
  "tools": {
    "web": { "search": { "enabled": true, "provider": "kimi" } },
    "agentToAgent": { "enabled": true }
  }
}
```

### The 5 Critical Settings (From the OpenClaw Architecture Article)

| Setting | ❌ Wrong Default | ✅ This Template | Why It Matters |
|---------|-----------------|-----------------|----------------|
| `session.dmScope` | `main` | `per-channel-peer` | Prevents conversation bleeding between users |
| `agents.defaults.sandbox.mode` | `off` | `non-main` | Sandboxes sub-agents, prevents shell access |
| Workspace files | Empty | Fully filled | Agents wake up with context, not blank slate |
| Compaction strategy | None | `safeguard` | Prevents losing decisions during long sessions |
| Gateway bind | Could be exposed | `loopback` | Never exposes port 18789 to internet |

---

## 🔄 Make Targets

```bash
make help             # Show all targets
make workspace-setup  # Register workspace + skills
make env-sync         # Sync .env into gateway service
make status           # Runtime snapshot
make test             # Full health check
make boundary-fix     # Repair/validate root workspace boundary
make ready-strict     # Strict production readiness check
make cron-install     # Install default agent cron schedules
make notifier-install # Install/update recurring status notifier cron
make notify           # Send test Telegram notification
make drift-audit      # Detect config drift
make reset-workspace  # Clear daily memory for fresh test
```

---

## 🔁 Cron Automation (Agents That Work While You Sleep)

```bash
# Install all scheduled jobs
make cron-install

# Default schedule:
# 08:01 IST → Dwight: morning research sweep
# 09:01 IST → Kelly: viral content check
# 10:01 IST → Ross: review pending engineering tasks
# Every 30m → Monica: heartbeat health check
```

Agents run their jobs completely autonomously. Results delivered to Telegram.

---

## 🔒 Security Best Practices

- **API keys:** Always in `.env` (gitignored) or `~/.openclaw/.env`
- **Gateway:** Bound to `loopback` only — never expose port 18789
- **Prompt injection:** `SECURITY_RULES.md` enforces zero-trust on all inputs
- **Sandbox:** Sub-agents isolated with `non-main` sandbox mode
- **Allowlist:** Telegram configured with `dmPolicy: allowlist` — only YOUR user ID

---

## 🔧 Troubleshooting

```bash
# Gateway offline?
TMPDIR=/tmp bash scripts/start-gateway.sh

# Memory not indexing?
openclaw memory status
openclaw memory index --force

# Agents not responding on Telegram?
openclaw channels status --probe

# Boundary drift / wrong folder writes?
make boundary-fix
bash scripts/enforce-root-boundary.sh

# Full diagnostic:
openclaw doctor --non-interactive
openclaw status --all
```

**macOS Sequoia note:** If the gateway fails to start with "failed to acquire gateway lock", always use `TMPDIR=/tmp` prefix. This is caused by a `com.apple.provenance` extended attribute on the macOS temp directory that blocks file creation from non-quarantined processes.

---

## 📚 Documentation

| Guide | What It Covers |
|-------|---------------|
| [docs/operations.md](docs/operations.md) | Day-to-day operator runbook |
| [docs/telegram-setup.md](docs/telegram-setup.md) | Telegram pairing, allowlists, security |
| [docs/web-search-providers.md](docs/web-search-providers.md) | Kimi, Brave, Perplexity, Grok setup |
| [docs/openclaw-under-the-hood.md](docs/openclaw-under-the-hood.md) | Full architecture deep-dive |

---

## 🤝 Contributing

PRs welcome! This template should stay generic and educational. Please:
- Keep all agent workspace files as templates (no personal info)
- Add any new skills to `skills/` with a proper `SKILL.md`
- Document new scripts in `TOOLS.md` template

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 📄 License

MIT — See [LICENSE](LICENSE)

---

*Built with [OpenClaw](https://openclaw.ai) — the open-source autonomous agent framework.*
