# 🚢 CrewAI Multi-Agent Orchestrator — 2026 Production Edition

A [CrewAI](https://github.com/crewAIInc/crewAI) implementation of the same 6-agent autonomous team. This module provides an **alternative orchestration pattern** to the LangGraph version in `langgraph/`, demonstrating versatility in multi-agent frameworks.

## Architecture

```
User Input
    │
    ▼
┌───────────────────────────┐
│          Crew               │
│  ┌─────────────────────┐   │
│  │  Agents               │  │
│  │  ├── Dwight (Research)│  │
│  │  ├── Ross (Engineer)  │  │
│  │  ├── Kelly (Social)   │  │
│  │  └── Pam (Writing)    │  │
│  ├─────────────────────┤   │
│  │  Tasks                │  │
│  │  ├── Research Task    │  │
│  │  ├── Engineering Task │  │
│  │  ├── Social Task      │  │
│  │  └── Writing Task     │  │
│  ├─────────────────────┤   │
│  │  Process              │  │
│  │  Sequential │ Hierarchical │
│  └─────────────────────┘   │
└─────────────┬─────────────┘
              ▼
        Final Output
```

## Quick Start

```bash
pip install -r crewai/requirements.txt

# Sequential process (default)
python -m crewai.crew "Research agentic AI trends and draft a Twitter thread"

# Hierarchical process (Monica manages delegation)
python -m crewai.crew --hierarchical "Build a competitive analysis of AI coding assistants"
```

## Programmatic Usage

```python
from crewai.crew import run_team

# Basic
result = run_team("Build a competitive analysis of AI coding assistants")
print(result["result"])

# Specific agents only
result = run_team(
    "Write a blog post about our product",
    agents=["research", "writing"],
)
print(result["result"])

# Hierarchical process (manager-led)
result = run_team("Full product launch strategy", process="hierarchical")
print(result["result"])
```

## Agents

| Agent | Role | Speciality |
|-------|------|-----------|
| 🔍 Dwight | Research & Intel | Web research, competitive analysis |
| 👩‍💻 Ross | Engineering | Code, APIs, architecture |
| 📱 Kelly | Social Media | Twitter/X, viral content |
| ✍️ Pam | Writing | Blog posts, documentation |
| 🎯 Monica | Chief of Staff | Orchestration (hierarchical mode only) |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `OPENAI_API_KEY` | — | Required: OpenAI API key |
| `OPENAI_MODEL_NAME` | `gpt-4.1-mini` | Model for all agents |

## Process Modes

### Sequential (default)
Tasks execute in order: Research → Engineering → Social → Writing.
Each agent sees the output of previous agents via context sharing.

Best for: straightforward tasks where order matters.

### Hierarchical
Monica (manager agent) delegates tasks to specialists, monitors progress,
and re-delegates if quality isn't met.

Best for: complex tasks requiring dynamic routing and quality control.

---

## LangGraph vs CrewAI: When to Use Which

| Dimension | LangGraph (`langgraph/`) | CrewAI (`crewai/`) |
|-----------|-------------------------|-------------------|
| **Paradigm** | Graph-based (nodes + edges) | Crew-based (agents + tasks) |
| **Control Flow** | Explicit conditional edges | Process modes (sequential/hierarchical) |
| **Parallelism** | Native parallel fan-out | Sequential by default (hierarchical has delegation) |
| **State** | Custom `AgentState` dataclass | Built-in context sharing between tasks |
| **Human-in-the-Loop** | Native `interrupt()` support | Callbacks / guardrails |
| **Streaming** | `astream()` per-node | Event-based callbacks |
| **Best For** | Complex routing, HITL, custom flows | Quick setup, role-based teams |
| **Learning Curve** | Steeper (graph concepts) | Gentler (agents + tasks mental model) |
| **Production Maturity** | Very high (LangChain ecosystem) | Growing rapidly (2025-2026 breakout) |

### Recommendation

- **Use LangGraph** when you need fine-grained control over routing, streaming, or human approval gates
- **Use CrewAI** when you want a team up and running fast with minimal boilerplate
- **Show both** in your portfolio to demonstrate framework versatility 🎯
