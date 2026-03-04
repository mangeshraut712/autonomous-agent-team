# MEMORY.md — Long-Term Semantic Memory
*Last updated: 2026-03-05 IST — 6-agent autonomous team for Mangesh Raut*

---

## About the User
Mangesh Raut (IST UTC+5:30). Senior developer building two hackathon projects autonomously.
Works late-night IST. Direct communication style. Commits after every significant task.
Primary interface: Telegram via Monica. All agents route through Monica (Chief of Staff).

## Active Contests & Deadlines

### 1. Gemini Live Agent Challenge (PRIORITY #1 — 12 days left)
- **Devpost:** https://geminiliveagentchallenge.devpost.com/
- **Deadline:** ~March 17, 2026
- **Prize:** $25,000 Grand Prize + Google Cloud Next 2026 tickets
- **Project:** Always-On Memory Agent (AOMA) using Google ADK + Gemini 3.1 Flash-Lite
- **Category:** Live Agents 🗣️ (must use Gemini Live API or ADK, hosted on Google Cloud)
- **Key file:** `intel/AOMA-INTEL-BRIEF.md` — full architecture and execution plan
- **Local folder:** `/Users/mangeshraut/Downloads/Gemini Live Agent Challenge/`
- **Previous status:** Project previously built as "Gemini Rubik's Tutor". NEW project is AOMA.
- **Bonus needed:** Blog post with #GeminiLiveAgentChallenge + Terraform IaC + GDG membership

### 2. GitLab AI Hackathon (21 days left)
- **Devpost:** https://gitlab.devpost.com/
- **Deadline:** ~March 26, 2026
- **Project:** MergeGate — autonomous GitLab MR reviewer using Duo Agent platform
- **Status:** MVP COMPLETED by Ross. FastAPI + LLM reasoning + GitLab webhook integration.
- **Local folder:** `projects/gitlab-ai-hackathon-2026/`
- **Remaining:** Deploy to production, record demo video, submit on Devpost

## Model Stack
- **Default model:** anthropic/claude-3-5-sonnet-20241022 (200k context) — Monica, complex tasks
- **Cron model:** openai-codex/gpt-5.3-codex — all scheduled jobs
- **Gemini 3.1 Flash-Lite:** `gemini-3.1-flash-lite-preview` — for AOMA background processing
- **Gemini Live API:** for AOMA voice query interface
- **Embeddings:** text-embedding-3-small (OpenAI) — memory vector search

## Infrastructure
- **OpenClaw gateway:** port 18789, loopback only, `TMPDIR=/tmp bash scripts/start-gateway.sh`
- **Workspace:** `/Users/mangeshraut/Downloads/AI Agent`
- **Sandbox mode:** `non-main` (sub-agents sandboxed, Monica unrestricted)
- **Session isolation:** `dmScope: per-channel-peer`
- **Web search:** Kimi provider active

## Agent Team Directory
| Agent | Role | Session Key |
|-------|------|-------------|
| Monica | Chief of Staff — orchestrates, routes, delegates | agent:main:main |
| Dwight | Research & Intel — web research, writes to intel/ | agent:dwight:main |
| Ross | Engineering — code, APIs, deployment, testing | agent:ross:main |
| Kelly | Twitter/X content — threads, viral content | agent:kelly:main |
| Rachel | LinkedIn — professional posts, networking | agent:rachel:main |
| Pam | Narrative & Submissions — blog, Devpost, README | agent:pam:main |

## Critical Technical Decisions
- Always respond HTTP 200 immediately to GitLab webhooks, then process async (avoids timeout)
- Never hardcode API keys — use ~/.openclaw/.env or project .env
- Claude 3.5 Sonnet for complex reasoning; Flash-Lite for high-frequency/background tasks
- ChromaDB for local vector store; GCS bucket for persistent memory in Cloud Run
- Terraform for Cloud Run deployment (contest bonus points)

## Gemini 3.1 Flash-Lite Facts
- Model ID: `gemini-3.1-flash-lite-preview`
- 1432 Elo, 86.9% GPQA Diamond (scientific)
- Ultra-low latency, ultra-low cost → 24/7 background operation is practical
- Adaptive thinking (Vertex AI): control reasoning budget per request
- 27+ file types multimodal (text, images, audio, video, PDFs, DOCX, etc.)
- API key: already in ~/.openclaw/.env as GEMINI_API_KEY

## Rules
- One writer per intel file: only Dwight writes to intel/DAILY-INTEL.md
- All social content is draft-only until Mangesh approves
- Commit to git after every significant coding session (Ross)
- Never expose gateway port 18789 publicly
- Before compaction: flush to memory/YYYY-MM-DD.md first
