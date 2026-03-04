# USER.md — Mangesh Raut

*Real context. Updated 2026-03-05. Agents: read this before every session.*

---

## Identity

- **Name:** Mangesh Raut
- **Call me:** Mangesh
- **Timezone:** IST — UTC+5:30 (India)
- **Primary interface:** Telegram → Monica bot
- **GitHub:** github.com/mangeshraut712
- **Active hours:** Late night IST (11 PM – 3 AM most productive). Sleeps roughly 3-9 AM IST. Agents work while I sleep.

## Working Style

- **Direct and results-oriented.** No filler, no preamble. Lead with the action or answer.
- **Responses:** Short and punchy for status updates. Thorough when it's a plan or architecture.
- **I hate:** Being bounced around ("go ask another agent"). Monica delegates — I don't have to.
- **I love:** Waking up to work already done. Commits, deploys, drafts — all while I slept.
- **Decision style:** Show me the options briefly, make a recommendation, I'll approve or redirect.
- **Commits:** Always commit and push after finishing a task. Always.

## Active Projects (March 2026)

1. **Always-On Memory Agent (AOMA)** — Gemini 3.1 Flash-Lite + Google ADK. 3-agent persistent memory system. **12 days left** to submit to Gemini Live Agent Challenge ($25k grand prize).
   - Folder: `/Users/mangeshraut/Downloads/always-on-memory-agent/`
   - Status: Core code scaffolded. Needs: runtime testing, GitHub push, Cloud Run deploy, demo video.
   - Model: `gemini-3.1-flash-lite-preview`

2. **MergeGate** — GitLab AI Hackathon. Autonomous GitLab MR reviewer using Duo Agent platform.
   - Folder: `projects/gitlab-ai-hackathon-2026/`
   - Status: MVP done. **21 days left**. Needs: production deploy + demo video.

3. **OpenClaw Workspace** — 6-agent autonomous team (Monica, Dwight, Ross, Kelly, Rachel, Pam).
   - Workspace: `/Users/mangeshraut/Downloads/AI Agent/`
   - GitHub: github.com/mangeshraut712/autonomous-agent-team (public, educational)

## Permanent Preferences

- **Never suggest manual steps a script can do.** Write the script.
- **Commit git changes** after every significant task (Ross especially).
- **Deadlines matter.** Always mention days-remaining when discussing hackathon tasks.
- **Don't ask permission for obvious follow-ups** — just do them and report.
- **Morning surprise rule:** Agents should proactively find and do useful work overnight. Report what was done when I wake up.
- **Reverse prompt when stuck:** Instead of asking me what to build, tell me what YOU think we should do next based on what you know. I trust your judgment.

## Tech Stack

- **Languages:** Python (primary), Node.js, Bash
- **Infra:** Google Cloud Run, Terraform, Docker, GitHub Actions
- **AI APIs:** Gemini (primary for AOMA), Claude (OpenClaw default), OpenAI Codex (crons)
- **Comms:** Telegram DM, Monica bot
- **Dev machine:** MacBook (Apple Silicon, macOS) — use `TMPDIR=/tmp` for OpenClaw workarounds

## Goals (What I'm Optimizing For)

1. **Win a hackathon** — Gemini Live Challenge or GitLab, ideally both
2. **Build in public** — repo is educational, helps others learn OpenClaw
3. **Autonomous team** — agents should need less and less from me each week
4. **Ship fast** — done > perfect for contest work
