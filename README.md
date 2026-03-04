# 🦞 autonomous-agent-team

> A production-ready OpenClaw workspace template for running a 6-agent autonomous AI team that works 24/7 — researching, writing, coding, and delivering — while you sleep.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/Powered%20by-OpenClaw-red)](https://openclaw.ai)
[![Telegram](https://img.shields.io/badge/Interface-Telegram-blue)](https://telegram.org)

---

## What This Is

This is the actual workspace structure used to run six autonomous AI agents as a coordinated team. Not a demo. Not a tutorial. A working template you can fork, customize, and deploy.

Each agent has exactly **one job**. They coordinate through shared files on disk — no APIs between them, no message queues, no orchestration framework. Just markdown files and a scheduled runtime.

---

## The Squad

| Agent | Personality | Job | Schedule |
|-------|-------------|-----|----------|
| **Monica** | Chief of Staff (Monica Geller) | Coordinates the team, handles strategy, runs heartbeat health checks | On-demand + heartbeat |
| **Dwight** | Research (Dwight Schrute) | Sweeps HN, GitHub, arXiv, X — writes structured intel reports | 8:01 AM, 4:01 PM |
| **Kelly** | X/Twitter (Kelly Kapoor) | Reads Dwight's intel, drafts tweets in your voice | 9:01 AM, 1:01 PM, 5:01 PM |
| **Rachel** | LinkedIn (Rachel Green) | Reads Dwight's intel, drafts thought leadership posts | 5:01 PM |
| **Ross** | Engineering (Ross Geller) | Code reviews, bug triage, technical tasks | 10:01 AM |
| **Pam** | Newsletter (Pam Beesly) | Turns intel into a clean weekly digest | On-demand |

---

## How It Works

```
Dwight (Research)
    │
    └─ writes ──► intel/DAILY-INTEL.md
                        │
              ┌─────────┼─────────┐
              ▼         ▼         ▼
           Kelly      Rachel      Pam
          (tweets)  (LinkedIn) (newsletter)

Monica (Chief of Staff)
    │
    ├─ delegates ──► Ross (engineering tasks)
    └─ monitors ──► HEARTBEAT.md (cron health)
```

**The coordination layer is the filesystem.** Dwight writes. Everyone else reads. No middleware. Files don't crash, don't need auth, don't have rate limits.

---

## Project Structure

```
autonomous-agent-team/
│
├── SOUL.md              # Monica — main agent identity & delegation rules
├── AGENTS.md            # Global session rules for all agents
├── MEMORY.md            # Monica's long-term memory (grows over time)
├── HEARTBEAT.md         # Cron job health monitor & self-healing config
│
├── agents/
│   ├── dwight/
│   │   ├── SOUL.md      # Research identity, sources, output format
│   │   ├── AGENTS.md    # Session startup rules
│   │   ├── MEMORY.md    # Research filters, tracked signals
│   │   └── memory/      # Daily runtime logs (gitignored)
│   ├── kelly/
│   │   ├── SOUL.md      # X/Twitter voice, draft rules
│   │   ├── AGENTS.md
│   │   ├── MEMORY.md    # Voice calibration, what worked
│   │   └── memory/
│   ├── rachel/
│   │   ├── SOUL.md      # LinkedIn voice, thought leadership rules
│   │   ├── AGENTS.md
│   │   ├── MEMORY.md
│   │   └── memory/
│   ├── ross/
│   │   ├── SOUL.md      # Engineering principles, task intake protocol
│   │   ├── AGENTS.md
│   │   └── memory/
│   └── pam/
│       ├── SOUL.md      # Newsletter format, editorial rules
│       ├── AGENTS.md
│       └── memory/
│
└── intel/
    ├── DAILY-INTEL.md   # Dwight's generated research (runtime, gitignored)
    └── data/            # Structured JSON per day (runtime, gitignored)
        └── README.md    # JSON schema documentation
```

---

## Quick Start

### Prerequisites
- macOS, Linux, or Windows (WSL)
- Node.js 18+
- A Telegram bot token ([create one here](https://t.me/BotFather))
- An AI model API key (OpenRouter, Anthropic, or Google Gemini)

### 1. Install OpenClaw

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

### 2. Clone & Configure

```bash
git clone https://github.com/YOUR_USERNAME/autonomous-agent-team
cd autonomous-agent-team

cp .env.example .env
# Edit .env and add your Telegram credentials
```

### 3. Onboard

```bash
npx openclaw@latest onboard
```

During onboarding:
- Accept the security acknowledgment
- Paste your Telegram bot token when prompted
- Set your workspace path to this directory
- Choose your AI model (Claude Sonnet recommended)

### 4. Schedule Your Agents

```bash
chmod +x scripts/add-cron-jobs.sh
./scripts/add-cron-jobs.sh
```

This registers all 6 cron jobs in OpenClaw and outputs their IDs.
Update `HEARTBEAT.md` with the printed IDs.

### 5. Verify

Open your browser at `http://127.0.0.1:18789` — you should see the OpenClaw dashboard with **Health: OK**.

Message your Telegram bot: `hey monica` — she should respond.

---

## Customizing the Agents

### Rename the agents to fit your context

The TV character names are a prompt engineering trick — the model already knows these personalities from training data. But you can rename them. Just update `SOUL.md` for each agent.

### Change what Dwight researches

Edit `agents/dwight/SOUL.md` → **Research Sources** section. Add or remove sources. Add topic filters in `agents/dwight/MEMORY.md`.

### Calibrate voice for Kelly and Rachel

The fastest way: chat with them, give feedback, tell them to remember it. They'll write it to their `MEMORY.md`. After a week of feedback loops, the output quality jumps significantly.

### Add a new agent

1. Create `agents/YOUR_AGENT/SOUL.md`
2. Create `agents/YOUR_AGENT/AGENTS.md` (copy from an existing agent)
3. Create `agents/YOUR_AGENT/MEMORY.md`
4. Add a cron job via `npx openclaw@latest cron add ...`
5. Update `HEARTBEAT.md` with the new job ID

---

## The Memory System

Agents have no memory between sessions by default. These files are their continuity:

| File | Purpose | Updated by |
|------|---------|------------|
| `MEMORY.md` | Long-term curated knowledge | Agent (on important lessons) |
| `memory/YYYY-MM-DD.md` | Today's running log | Agent (throughout session) |

**The compounding effect:** Agents get better over time not because the model improves, but because the context they load gets richer. Kelly's MEMORY.md knows your voice after 30 days of feedback. Dwight's MEMORY.md has your topic filters and tracked signals. This is the moat.

---

## The Heartbeat (Self-Healing)

`HEARTBEAT.md` contains a list of cron job IDs and instructions for Monica to check them on every heartbeat. If a job hasn't run in >26 hours, Monica force-triggers it.

```bash
# Force-run a stale job manually
npx openclaw@latest cron run <jobId> --force
```

---

## Security

> **Read [SECURITY.md](SECURITY.md) before pushing to a public repo.**

Key rules:
- **Never commit `.env`** — it's gitignored, but double-check with `git status`
- **Never commit `.openclaw/`** — contains gateway token and device identity
- Agents run with **scoped credentials only** — dedicated API keys, not personal accounts
- Use `openclaw security audit --deep` regularly

---

## Costs (Real Numbers)

| Service | Cost |
|---------|------|
| Claude (Anthropic Max plan) | ~$200/month |
| Gemini API | ~$50–70/month |
| OpenRouter (alternative) | Pay-per-token |
| Telegram | Free |
| OpenClaw | Open source, free |
| **Total** | **~$200–400/month** |

Local models via [Ollama](https://ollama.ai) can bring this down significantly. Dwight and Pam work well on smaller models.

---

## FAQ

**Do I need a Mac Mini?**
No. Any always-on machine works — a laptop, an old PC, a $5/month VPS. The Mac Mini is convenient because it's silent and sips power.

**Can I start with just one agent?**
Yes. Start with Monica only. Add Dwight when you want automated research. Add Kelly when you want drafts from that research. Build sequentially.

**What AI models does this use?**
Whatever you configure. Claude Sonnet is recommended for general agents. Gemini Flash is good for Dwight's high-frequency research sweeps.

**Why TV character names?**
Prompt engineering efficiency. `"You have Dwight Schrute energy"` loads 10 seasons of character development into the model instantly. You get thorough, intense, no-fluff behavior without writing it out. That said, rename them to whatever you want.

---

## Contributing

PRs welcome. This is a living template — improvements to SOUL.md files, memory systems, or cron patterns are especially useful.

Please don't commit:
- Personal API keys or tokens
- Personal agent memory files
- Generated intel data

---

## License

MIT — see [LICENSE](LICENSE).

---

## Acknowledgements

Inspired by the original setup described in [this post](https://www.linkedin.com/in/shubhamsaboo/) by Shubham Saboo. Built on [OpenClaw](https://openclaw.ai).
