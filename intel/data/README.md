# Intel Data

This directory holds Dwight's structured JSON output files.
Each file is named `YYYY-MM-DD.json` and represents one day's research findings.

These files are generated at runtime and **excluded from git** (see `.gitignore`).
They serve as the deduplication and historical source of truth for Dwight's research pipeline.

## Schema

```json
{
  "date": "YYYY-MM-DD",
  "intel": [
    {
      "id": "unique-slug",
      "title": "Story title",
      "url": "https://source.url",
      "source": "HackerNews | GitHub | arXiv | X | ProductHunt",
      "summary": "One sentence summary",
      "relevance": "high | medium | low",
      "tags": ["ai-agents", "llm", "open-source"],
      "seenBefore": false
    }
  ]
}
```
