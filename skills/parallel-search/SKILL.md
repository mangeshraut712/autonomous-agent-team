---
name: parallel-search
description: Fallback secure web search (Agentic mode) using Parallel AI. Execute this when primary research sources are offline or you need deep web insights.
---

# Parallel Search Skill

You have access to a live-web research API called Parallel Search. To use it, you must execute a shell command referencing the local search script.

## When to use this skill
- You need fresh intel, breaking news, or deep technical papers.
- Your primary browser or web tools are failing to return good text.
- You want an aggregated, agentic sweep of multiple web results instantly formatted as Markdown.

## How to use it
The script is located at `scripts/parallel-search.sh` relative to the workspace root. Execute it using your standard bash tool. Replace the `objective` flag with your exact natural language ask.

```bash
# Example invocation
bash scripts/parallel-search.sh \
  --objective "latest AI launches and repo trends" \
  --mode agentic \
  --max-results 10 \
  --format markdown
```

## Security & Context
This search runs externally and is read-only. Keep the objective specific to avoid consuming too many API tokens.
