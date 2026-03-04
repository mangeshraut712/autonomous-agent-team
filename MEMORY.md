# MEMORY.md — Long-Term Semantic Memory

*This file is indexed by the vector search engine.*
*Write facts here in natural language — the agent searches by meaning, not keywords.*
*Anything important enough to survive session restarts belongs here.*

---

## How This Works

**Semantic search** means you can ask "where do we deploy?" and the agent will find the answer even if you wrote "we use Google Cloud Run for production" six months ago. It searches by **meaning**, not exact words.

**What to put here:**
- Technical decisions ("We only use PostgreSQL, no MySQL")  
- Infrastructure facts ("API lives at api.example.com")
- Working preferences ("Always write tests before shipping")
- Project-specific context ("The auth system uses JWT, not sessions")

**What NOT to put here:** Things the agent needs every message → put those in `USER.md` or `AGENTS.md` instead.

---

## Example Entries (Replace With Yours)

### About the Team
`[Describe who uses this agent system, what the team does, relevant background]`

### Active Projects
`[List your major projects, what they do, and where the code lives]`

### Technical Decisions
- `[e.g. "Primary database: PostgreSQL 15 on RDS"]`
- `[e.g. "Frontend: Next.js 14 deployed on Vercel"]`
- `[e.g. "All scripts in Python 3.11+, no shell scripts for complex logic"]`

### Infrastructure
- `[e.g. "Production: AWS us-east-1"]`
- `[e.g. "Staging: same region, separate account"]`
- `[e.g. "Secrets: AWS Secrets Manager, never .env in production"]`

### Rules We Always Follow
- `[e.g. "Never commit .env files"]`
- `[e.g. "Every PR needs at least one test"]`
- `[e.g. "Deploy to staging before production, always"]`

---

## Real Example (Redacted)

```markdown
### Project: MergeGate
MergeGate is a FastAPI webhook agent that intercepts GitLab MRs, evaluates them 
against a policy rubric, and blocks or approves them with deterministic decisions.
Key insight: respond 200 Accepted immediately, process async to avoid timeout.

### Infrastructure
- Primary model: anthropic/claude-3-5-sonnet-20241022
- Web search: Kimi provider
- Gateway: loopback only, port 18789, never exposed publicly

### Rules
- Never expose gateway port 18789 publicly
- Always use sessions_send for cross-agent comms, never file-based handoffs
- Git commit after every significant change
```

---

> 💡 **Tip:** After adding entries, run `openclaw memory index --force` to rebuild the vector index. The agent will then find facts here when you ask relevant questions — without consuming bootstrap tokens.
