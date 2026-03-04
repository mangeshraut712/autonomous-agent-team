# Web Search Providers

OpenClaw supports multiple official providers for `web_search`.

Official docs reference: https://docs.openclaw.ai/tools/web

## Supported Providers

- Brave (`BRAVE_API_KEY`)
- Gemini (`GEMINI_API_KEY`)
- Kimi / Moonshot (`KIMI_API_KEY` or `MOONSHOT_API_KEY`)
- Perplexity (`PERPLEXITY_API_KEY`)
- Grok (`XAI_API_KEY`)

Auto-detection order in OpenClaw:

1. Brave
2. Gemini
3. Kimi
4. Perplexity
5. Grok

## Configure Provider

Interactive (recommended):

```bash
openclaw configure --section web
```

Or set explicitly:

```bash
openclaw config set tools.web.search.provider kimi
```

## Ensure Gateway Service Sees Keys

OpenClaw gateway service does not automatically read this project’s `.env`.
Sync keys into `~/.openclaw/.env`:

```bash
make env-sync
openclaw gateway restart
```

## Validate Search Capability

```bash
make ready-strict
```

or manual checks:

```bash
openclaw status --all
openclaw doctor --non-interactive
```

## Parallel Search Fallback (Custom)

This repository includes a custom fallback script:

```bash
scripts/parallel-search.sh \
  --objective "latest AI/devtools launches with source links" \
  --mode agentic \
  --max-results 8 \
  --format markdown
```

Requirements:

- `PARALLEL_API_KEY` in `.env` or shell env

Use this only when official `web_search` is unavailable or blocked.
