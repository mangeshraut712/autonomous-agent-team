# TOOLS.md — Local Environment Cheat Sheet

*This file gives the agent a map of your specific setup — paths, scripts, services.*
*It's read at session start so the agent knows your environment without guessing.*

---

## How to Fill This In

Replace each section below with real values for your machine/project.

---

## Workspace Paths

```markdown
- **Project root:** `/path/to/your/workspace`
- **Secondary project:** `/path/to/other/project`
- **Agent sub-workspaces:** `agents/dwight/`, `agents/kelly/`, etc.
- **Intel output folder:** `intel/`
- **Daily logs:** `memory/YYYY-MM-DD.md`
```

## Scripts Available

| Script | Purpose |
|--------|---------|
| `scripts/start-gateway.sh` | Start OpenClaw gateway (includes macOS TMPDIR fix) |
| `scripts/add-cron-jobs.sh` | Install scheduled cron jobs for all agents |
| `scripts/workspace-setup.sh` | Register workspace path and custom skills |
| `scripts/reset-workspace.sh` | Clear daily memory for a fresh test run |
| `scripts/test.sh` | Full workspace health check — run before demos |
| `scripts/status.sh` | Print agent and cron status summary |

## Key CLI Commands

```bash
# Gateway management
TMPDIR=/tmp bash scripts/start-gateway.sh   # Start gateway (macOS)
openclaw gateway start                       # Start gateway (Linux)
openclaw health                              # Check gateway health
openclaw status                              # Full status all agents

# Agent comms
openclaw agent --to main --message "..."    # Send message to Monica

# Memory
openclaw memory status                       # Check indexing status
openclaw memory index --force               # Force re-index MEMORY.md

# Cron
openclaw cron list                          # List all scheduled jobs
openclaw cron run <jobId>                   # Run a specific job now
```

## External Services

```markdown
# Fill in your actual API endpoints and services:
- **Telegram Bot:** [Your bot username]
- **Primary AI Model:** [e.g. anthropic/claude-3-5-sonnet-20241022]
- **Web Search Provider:** [e.g. Kimi, Brave, Perplexity]
- **Memory Embeddings:** [e.g. OpenAI text-embedding-3-small]
```

## Platform-Specific Notes

### macOS (Sequoia+)
- **Gateway startup quirk:** Prefix with `TMPDIR=/tmp` — macOS blocks default temp dir via `com.apple.provenance` extended attribute.
- **Keep Mac awake overnight:** Run `caffeinate -d &` before leaving agents to work.
- **Permission fix:** If OpenClaw can't write to `~/.openclaw`, run: `sudo chown -R $USER ~/.openclaw`

### Linux / Server
- **Gateway as service:** `openclaw gateway install && openclaw gateway start`
- **Docker deployment:** See `docker-compose.yml` for one-command deploy

---

> 💡 **Tip:** This file exists so agents don't guess. A well-filled TOOLS.md means "run the parallel-search script" maps to the correct path instantly — no hallucinated paths, no wasted tool calls.
