# OpenClaw Under The Hood

This guide explains how OpenClaw actually works in production, so you can run agents intentionally instead of as a black box.

It is written for this repository (`autonomous-agent-team`) and aligned with official OpenClaw concepts.

- OpenClaw docs: https://docs.openclaw.ai
- OpenClaw core repo: https://github.com/openclaw/openclaw

## 1) Architecture: 6 Core Parts

OpenClaw is easiest to reason about as six independent components:

1. Gateway: long-running runtime that receives channel events, routes sessions, executes tools, and returns outputs.
2. Agent: model-driven reasoning loop that decides between plain response vs tool execution.
3. Tools: capabilities (`exec`, `file`, `browser`, `message`, `memory`, etc.) the agent can call.
4. Workspace: text files that define behavior, memory, and operating constraints.
5. Sessions: per-conversation state/history (`jsonl`) used to continue dialogue coherently.
6. Nodes: optional connected devices/services that extend what tools can do.

## 2) Workspace Is the Leverage Point

If workspace is weak, quality and consistency drop. A practical baseline:

- `AGENTS.md`: operating rules and guardrails.
- `SOUL.md`: identity, tone, decision style.
- `USER.md`: user preferences and context.
- `MEMORY.md`: curated durable facts.
- `memory/YYYY-MM-DD.md`: daily operational log.
- `IDENTITY.md`: short identity file.
- `HEARTBEAT.md`: recurring checks and recovery rules.
- `TOOLS.md`: local tooling hints and command locations.

These files are plain text and versionable. Most quality gains come from improving these files, not prompt gymnastics.

## 3) Two Memory Layers (Critical)

OpenClaw workflows usually combine:

1. Bootstrap memory: selected workspace files are loaded at session start (always-on context).
2. Semantic memory: memory/search plugin retrieves relevant facts on demand (meaning-based recall).

Use both:

- Put always-needed constraints in bootstrap files.
- Put volatile/project facts in `MEMORY.md` and daily logs for retrieval.

If everything is shoved into bootstrap, token usage rises quickly. If bootstrap is empty, the agent feels stateless.

## 4) Gateway Message Lifecycle

When a Telegram message arrives:

1. Gateway receives channel event.
2. Gateway resolves target agent + session key.
3. Gateway assembles context (session history + workspace bootstrap + tool schema).
4. Model returns text or tool calls.
5. Gateway executes tools, loops model/tool/model until final response.
6. Response is delivered to channel and persisted in session logs.

Operational checks:

```bash
openclaw status
openclaw gateway status
openclaw channels status --probe
openclaw logs --follow
```

## 5) Tools and Automation

Tools are where risk and ROI both live.

- `exec`: highest impact, highest risk; prefer restricted modes.
- `browser`: web actions/scraping when APIs are unavailable.
- `file`: deterministic state transfer across agents via filesystem.
- `message`: channel output (Telegram, etc.).
- `memory`: long-term recall.

Cron and heartbeat convert agent from chat-only to autonomous worker:

```bash
openclaw cron add --name "Daily Sweep" --cron "0 9 * * *" --agent dwight --message "Run research sweep." --announce
openclaw cron status
openclaw cron list
openclaw cron runs --id <jobId> --limit 20
```

Note: OpenClaw cron uses `--cron` / `--every` / `--at` (not `--schedule`).

## 6) Multi-Agent on One Gateway

One gateway can run many agents safely if you isolate sessions and routing:

- Keep separate workspaces per agent under `agents/<name>/`.
- Use explicit channel routing and session keys.
- For multi-user/shared channels, set:
  - `session.dmScope: "per-channel-peer"` (or stricter per-account variant)

Without proper `dmScope`, users can leak context into each other’s sessions.

## 7) High-Impact Mistakes to Avoid

1. Shared session scope in multi-user DM setups.
2. Unrestricted `exec` on production hosts.
3. Empty workspace (agent re-learns everything every run).
4. No memory discipline before context compaction.
5. Exposing gateway port directly to internet.

Safer remote access patterns:

- Tailscale/private network
- SSH tunnel (`ssh -L 18789:127.0.0.1:18789 user@host`)

Keep gateway loopback-bound unless you have strong auth and network controls.

## 8) Cost and Quality Optimization Checklist

1. Keep `SOUL.md` and `AGENTS.md` concise and explicit.
2. Move long-lived facts into `MEMORY.md`, not giant bootstrap files.
3. Use one-writer-many-readers file flow for handoffs (`intel/` pattern).
4. Use cron for deterministic schedules; use heartbeat for stale-job recovery.
5. Run strict checks before overnight runs:

```bash
make env-sync
openclaw gateway restart
make ready-strict
make test
```

## 9) Operational Defaults Used In This Repo

1. Heartbeat: every 30 minutes, 08:00-23:00 IST; quiet outside the window.
2. Memory flush: before compaction/reset, write key learnings to daily memory and durable facts to `MEMORY.md`.
3. Heavy scanning: runs in isolated cron sessions, not the main heartbeat loop.
4. Fallback alerts: stale or failed cron runs trigger forced recovery and Telegram alerts.
5. Drift audit: when cron count grows (threshold default 50), run `make drift-audit`.

## 10) Canonical Runbook for This Repo

```bash
make workspace-setup
make env-sync
openclaw gateway restart
make ready-strict
make cron-install
make notify
```

If Telegram pairing prompts appear:

```bash
openclaw pairing approve telegram <PAIRING_CODE>
```

Then verify:

```bash
openclaw channels status --probe
openclaw cron status
```

---

If you run OpenClaw with clear workspace files, layered memory, strict session isolation, and observable operations, it stops being a black box and starts behaving like reliable infrastructure.
