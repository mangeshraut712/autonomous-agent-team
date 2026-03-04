---
name: last-30-days
description: Searches Reddit, X (Twitter), and YouTube for trending content from the past 30 days. Crucial for Radar/Dwight to find trending topics.
---

# Last 30 Days Search Skill

This skill allows you to find recent, trending content to feed into your research and content generation pipelines. It specifically bounds searches to the last 30 days to ensure high relevance.

## Usage

You can run the included Python script to perform the search. The script requires the `gemini-3.1-flash-lite-preview` model via the `GEMINI_API_KEY` to summarize and rank the findings.

### Command Format

```bash
python3 skills/last-30-days/search.py "YOUR_SEARCH_QUERY"
```

### Example
```bash
python3 skills/last-30-days/search.py "AI agents open source framework"
```

## How It Works
1. It simulates scraping recent trending posts from Reddit (r/MachineLearning, r/artificial), X (Twitter), and YouTube.
2. It aggregates mentions from the last 30 days.
3. It uses Gemini 3.1 Flash-Lite to rank them by "velocity" (how fast they are trending).
4. Returns a JSON output that you can easily parse and include in your `DAILY-INTEL.md`.
