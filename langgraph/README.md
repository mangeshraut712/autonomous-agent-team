# 🕸️ LangGraph Multi-Agent Orchestrator — 2026 Production Edition

A standalone [LangGraph](https://github.com/langchain-ai/langgraph) implementation of the 6-agent autonomous team. This module demonstrates **multi-agent orchestration** patterns using LangGraph's `StateGraph` API — a core 2026 portfolio skill.

## What's New in the 2026 Edition

| Feature                      | Details                                                                     |
| ---------------------------- | --------------------------------------------------------------------------- |
| **Streaming**                | `astream` yields intermediate state updates as agents complete              |
| **Human-in-the-Loop**        | `interrupt()` gates pause execution for human review before final synthesis |
| **Retry with Backoff**       | All LLM calls use `_call_with_retry()` — 3 attempts, exponential backoff    |
| **Per-Agent Error Handling** | Failed agents log errors and return gracefully, not crash the graph         |
| **Structured Logging**       | `structlog` throughout — JSON logs in production, pretty in dev             |
| **Pinned Dependencies**      | Semver ranges with upper bounds for reproducible builds                     |

## Architecture

```
User Input
    │
    ▼
┌─────────────────┐
│  Orchestrator     │  ← Monica decides which agents to call
│  (Router Node)    │
└──┬───┬───┬───┬───┘
   │   │   │   │        ← conditional edges (parallel fan-out)
   ▼   ▼   ▼   ▼
  Res Eng Soc Wri       ← parallel agent execution
   │   │   │   │        ← each has retry + error handling
   └───┴───┴───┘
        │
        ▼
┌─────────────────┐
│  Human Review     │  ← optional: human-in-the-loop interrupt
│  [──interrupt──]  │
└────────┬────────┘
         ▼
┌─────────────────┐
│  Aggregator       │  ← Monica synthesizes final response
└────────┬────────┘
         ▼
    Final Output
```

## Key Concepts Demonstrated

| Concept                  | How It's Used                                                      |
| ------------------------ | ------------------------------------------------------------------ |
| **StateGraph**           | Shared `AgentState` dataclass flows through all nodes              |
| **Conditional Edges**    | Orchestrator routes to specific agents based on task analysis      |
| **Parallel Fan-out**     | Multiple agents execute simultaneously via `add_conditional_edges` |
| **Aggregation**          | Results converge into a single coherent output                     |
| **Agent Specialization** | Each agent has a distinct system prompt and role                   |
| **HITL Interrupts**      | `langgraph.interrupt()` for human approval gates                   |
| **Streaming**            | `astream()` yields per-node updates in real-time                   |
| **Retry Logic**          | Exponential backoff on all LLM calls                               |

## Agents

| Agent     | Node                          | Speciality                |
| --------- | ----------------------------- | ------------------------- |
| 🎯 Monica | `orchestrator` / `aggregator` | Routing + synthesis       |
| 🔍 Dwight | `research`                    | Web research, analysis    |
| 👩‍💻 Ross   | `engineering`                 | Code, APIs, architecture  |
| 📱 Kelly  | `social`                      | Twitter/X, viral content  |
| ✍️ Pam    | `writing`                     | Blog posts, documentation |

## Quick Start

```bash
pip install -r langgraph/requirements.txt

# Basic run
python -m langgraph.orchestrator "Research agentic AI trends and draft a Twitter thread"

# Streaming mode — see agents complete in real-time
python -m langgraph.orchestrator --stream "Build a competitive analysis of AI coding assistants"

# Human-in-the-loop — pauses before final synthesis for your approval
python -m langgraph.orchestrator --hitl "Write a blog post about our product launch"
```

## Programmatic Usage

```python
import asyncio
from langgraph.orchestrator import run_team

async def main():
    # Basic usage
    result = await run_team("Build a competitive analysis of AI coding assistants")
    print(result["final_output"])

    # With human-in-the-loop
    result = await run_team("Write a blog post", enable_hitl=True)
    print(result["final_output"])

    # Streaming
    async for event in await run_team("Research trends", stream=True):
        print(f"{event['node']}: {event['update']}")

asyncio.run(main())
```

## Configuration

| Environment Variable | Default        | Description                      |
| -------------------- | -------------- | -------------------------------- |
| `LANGGRAPH_MODEL`    | `gpt-4.1-mini` | Model to use for all agent nodes |
| `OPENAI_API_KEY`     | —              | Required: OpenAI API key         |

## How It Works

1. **Orchestrator** receives the task, calls the LLM to decide which agents are needed
2. **Conditional edges** route the state to the selected agent nodes
3. **Agent nodes** execute in parallel — each with a specialized system prompt and retry logic
4. **Human Review** (optional) — `interrupt()` pauses the graph for human approval
5. **Aggregator** collects all outputs and synthesizes a final response
6. The graph terminates and returns the complete result

## Why LangGraph (not just LangChain)?

LangChain gives you chains. LangGraph gives you **graphs with cycles, conditional routing, persistent state, and interrupt support**. For multi-agent systems, that's the difference between:

- ❌ Sequential chain: agent1 → agent2 → agent3 (slow, rigid)
- ✅ StateGraph: router → [agent1, agent2, agent3] → aggregator (parallel, flexible)
- ✅ With HITL: router → agents → [human gate] → aggregator (safe, auditable)

This is the pattern every production multi-agent system uses in 2026.

## Files

| File               | Purpose                                                |
| ------------------ | ------------------------------------------------------ |
| `orchestrator.py`  | Main graph definition, agent nodes, routing logic, CLI |
| `requirements.txt` | Pinned dependencies                                    |
| `__init__.py`      | Package marker                                         |
