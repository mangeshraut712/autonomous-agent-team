# Security Policy

## ⚠️ Before You Use This

This repo runs agents that can **read files, execute code, and send messages** via Telegram.
Read this before deploying.

## Golden Rules

1. **Never commit `.env`** — Your `.gitignore` already excludes it. Double-check with `git status`.
2. **Rotate secrets immediately** if you accidentally expose them (push to public repo, paste in chat, etc.).
3. **Scoped credentials only** — Create dedicated API keys for your agents. Never reuse personal account tokens.
4. **Agents get their own world** — They should not have access to your personal accounts, email, or banking. Forward information to them rather than granting direct access.
5. **Least privilege tools** — Only enable the tools each agent actually needs. An agent that writes content doesn't need file system access beyond its workspace.

## What This Repo Contains

- `SOUL.md` files: agent identity and instructions (safe to share)
- `AGENTS.md` files: session startup rules (safe to share)
- `MEMORY.md` files: _templates_ with no personal data (safe to share)
- `.env.example`: template with no real credentials (safe to share)

## What Must Never Be Committed

| File/Pattern                   | Why                                     |
| ------------------------------ | --------------------------------------- |
| `.env`                         | Contains live API keys and bot tokens   |
| `openclaw.json` / `.openclaw/` | Contains gateway token, device identity |
| `agents/*/memory/*.md`         | May contain personal notes and drafts   |
| `intel/data/*.json`            | May contain personal research data      |

## If You Accidentally Expose Secrets

1. **Immediately revoke/rotate** the exposed key at the provider (Telegram, OpenRouter, Gemini, etc.)
2. Remove the secret from git history: `git filter-branch` or use [BFG Repo Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
3. Force-push the cleaned history
4. Check `git log --all -p | grep <secret>` to confirm it's gone

## Telegram Security

- Use `dmPolicy: pairing` (default) — only paired users can message your agent
- For `groupPolicy`: keep it `allowlist` and explicitly list allowed group IDs
- Never set `groupPolicy: open` on a public bot

## Vibe Coding Security Checklist

When building or extending agents, strictly enforce these 3 pillars of security:

### 01 — SECRETS & CONFIG

- [ ] Hardcoded secrets, tokens, or API keys in the codebase
- [ ] Secrets leaking through logs, error messages, or API responses
- [ ] Environment files committed to git
- [ ] API keys exposed client-side that should be server-only
- [ ] CORS too permissive
- [ ] Dependencies with known vulnerabilities
- [ ] Default credentials or example configs still present
- [ ] Debug mode or dev tools enabled in production

### 02 — ACCESS & API

- [ ] Pages or routes accessible without proper auth
- [ ] Users accessing other users' data by changing an ID in the URL
- [ ] Tokens stored insecurely on the client
- [ ] Login or reset flows that reveal whether an account exists
- [ ] Endpoints missing rate limiting
- [ ] Error responses exposing internal details
- [ ] Endpoints returning more data than needed
- [ ] Sensitive actions (delete, change email) with no confirmation step
- [ ] Admin routes protected only by hiding the URL

### 03 — USER INPUT

- [ ] Unsanitized input reaching database queries
- [ ] User-submitted text that can run code in other users' browsers
- [ ] File uploads accepted without type or size checks
- [ ] Payment or billing logic that can be bypassed client-side

## Resources

- [OpenClaw Security Docs](https://docs.openclaw.ai/gateway/security)
- [OpenClaw Security Audit Command](https://docs.openclaw.ai/security): `openclaw security audit --deep`
