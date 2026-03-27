"""
LangGraph Multi-Agent Orchestrator — 2026 Production Edition
==============================================================

A standalone LangGraph implementation of the 6-agent autonomous team
using the latest StateGraph API (langgraph>=0.4) with:

  - Streaming support (astream / astream_events)
  - Human-in-the-loop interrupts for approval gates
  - Retry logic with exponential backoff
  - Structured logging via structlog
  - Proper error handling and fallback routing

Architecture:
  User Input
      │
      ▼
  ┌─────────────┐
  │  Orchestrator │ ◄── decides which agents to invoke (Monica)
  │  (Router)     │
  └──┬──┬──┬──┬──┘
     │  │  │  │        ← conditional parallel fan-out
     ▼  ▼  ▼  ▼
  Research  Eng  Social  Writing
     │  │  │  │
     ▼  ▼  ▼  ▼
  ┌─────────────┐
  │  Aggregator  │ ◄── synthesizes results (Monica)
  │  [interrupt] │     optional human-in-the-loop gate
  └──────┬──────┘
         ▼
     Final Response

Requirements:
  pip install -r langgraph/requirements.txt
"""

from __future__ import annotations

import asyncio
import os
from dataclasses import dataclass, field
from typing import Annotated, Any

import structlog
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage, SystemMessage
from langchain_core.runnables import RunnableConfig
from langgraph.graph import END, StateGraph
from langgraph.graph.message import add_messages
from langgraph.types import interrupt

# ---------------------------------------------------------------------------
# Structured Logging
# ---------------------------------------------------------------------------

logger = structlog.get_logger()


# ---------------------------------------------------------------------------
# State Schema
# ---------------------------------------------------------------------------

@dataclass
class AgentState:
    """Shared state flowing through the multi-agent graph."""

    messages: Annotated[list[BaseMessage], add_messages] = field(default_factory=list)
    task: str = ""
    plan: list[str] = field(default_factory=list)

    # Fan-out results (populated by individual agents)
    research_result: str = ""
    engineering_result: str = ""
    social_result: str = ""
    writing_result: str = ""

    # Error tracking per agent
    agent_errors: dict[str, str] = field(default_factory=dict)

    # Final synthesized output
    final_output: str = ""

    # Routing metadata
    agents_needed: list[str] = field(default_factory=list)
    current_step: str = ""

    # Human-in-the-loop
    human_approved: bool = False
    human_feedback: str = ""


# ---------------------------------------------------------------------------
# LLM Factory
# ---------------------------------------------------------------------------

def _get_llm(model_name: str | None = None):
    """Create an LLM instance. Falls back to environment config."""
    from langchain_openai import ChatOpenAI

    model = model_name or os.getenv("LANGGRAPH_MODEL", "gpt-4.1-mini")
    return ChatOpenAI(model=model, temperature=0.3)


# ---------------------------------------------------------------------------
# Retry Helper
# ---------------------------------------------------------------------------

async def _call_with_retry(
    fn,
    *args: Any,
    max_retries: int = 3,
    base_delay: float = 1.0,
    **kwargs: Any,
) -> Any:
    """Call an async function with exponential backoff retry."""
    last_exc: Exception | None = None
    for attempt in range(1, max_retries + 1):
        try:
            return await fn(*args, **kwargs)
        except Exception as exc:
            last_exc = exc
            delay = base_delay * (2 ** (attempt - 1))
            logger.warning(
                "llm_call_retry",
                attempt=attempt,
                max_retries=max_retries,
                delay=delay,
                error=str(exc),
            )
            if attempt < max_retries:
                await asyncio.sleep(delay)
    raise RuntimeError(f"All {max_retries} retries exhausted") from last_exc


# ---------------------------------------------------------------------------
# Agent Nodes
# ---------------------------------------------------------------------------

async def orchestrator_node(
    state: AgentState, config: RunnableConfig | None = None
) -> dict:
    """
    Monica — Chief of Staff.
    Analyzes the incoming task and decides which agents to dispatch.
    """
    llm = _get_llm()
    logger.info("orchestrator.start", task=state.task[:120])

    system_prompt = SystemMessage(content="""You are Monica, the Chief of Staff.
Your job is to analyze the user's request and decide which team members to call.

Available agents:
- research (Dwight): web research, competitive analysis, fact-checking
- engineering (Ross): code, scripts, APIs, technical implementation
- social (Kelly): Twitter/X threads, viral content, social media strategy
- writing (Pam): blog posts, documentation, narratives, hackathon submissions

Respond with ONLY a comma-separated list of agent names needed.
Examples:
  "research,engineering,writing"
  "social"
  "research,writing"
  "research,engineering,social,writing"

If the task is simple enough for just one agent, pick the best fit.
If it's complex, call multiple agents in parallel.""")

    human_msg = HumanMessage(content=f"Task: {state.task}")
    response = await _call_with_retry(llm.ainvoke, [system_prompt, human_msg])

    agents_needed = [a.strip() for a in response.content.split(",") if a.strip()]
    logger.info("orchestrator.routed", agents=agents_needed)

    return {
        "agents_needed": agents_needed,
        "current_step": "routed",
        "messages": [AIMessage(content=f"Routing to: {', '.join(agents_needed)}")],
    }


async def research_node(
    state: AgentState, config: RunnableConfig | None = None
) -> dict:
    """Dwight — Intel & Research agent."""
    logger.info("research.start", task=state.task[:80])
    llm = _get_llm()

    system_prompt = SystemMessage(content="""You are Dwight, the Research & Intel specialist.
You provide thorough, well-sourced research and analysis.
Always cite sources when possible. Be factual and precise.
Structure your findings clearly with key takeaways.""")

    try:
        human_msg = HumanMessage(content=f"Research task: {state.task}")
        response = await _call_with_retry(llm.ainvoke, [system_prompt, human_msg])
        logger.info("research.complete", result_len=len(response.content))
        return {
            "research_result": response.content,
            "messages": [AIMessage(content=f"[Research] {response.content[:200]}...")],
        }
    except Exception as exc:
        logger.error("research.failed", error=str(exc))
        return {
            "research_result": f"[ERROR] Research agent failed: {exc}",
            "agent_errors": {**state.agent_errors, "research": str(exc)},
        }


async def engineering_node(
    state: AgentState, config: RunnableConfig | None = None
) -> dict:
    """Ross — Engineering agent."""
    logger.info("engineering.start", task=state.task[:80])
    llm = _get_llm()

    system_prompt = SystemMessage(content="""You are Ross, the Engineering specialist.
You write production-quality code, design system architectures, and solve
technical problems. Always include:
- Clear technical approach
- Code with comments
- Potential pitfalls and how to handle them
- Testing strategy""")

    try:
        human_msg = HumanMessage(content=f"Engineering task: {state.task}")
        response = await _call_with_retry(llm.ainvoke, [system_prompt, human_msg])
        logger.info("engineering.complete", result_len=len(response.content))
        return {
            "engineering_result": response.content,
            "messages": [AIMessage(content=f"[Engineering] {response.content[:200]}...")],
        }
    except Exception as exc:
        logger.error("engineering.failed", error=str(exc))
        return {
            "engineering_result": f"[ERROR] Engineering agent failed: {exc}",
            "agent_errors": {**state.agent_errors, "engineering": str(exc)},
        }


async def social_node(
    state: AgentState, config: RunnableConfig | None = None
) -> dict:
    """Kelly — Social Media agent."""
    logger.info("social.start", task=state.task[:80])
    llm = _get_llm()

    system_prompt = SystemMessage(content="""You are Kelly, the Social Media specialist.
You craft viral content, Twitter/X threads, and social media strategy.
Be punchy, engaging, and platform-native. Think in hooks, threads, and
call-to-actions. Understand what makes content shareable.""")

    try:
        human_msg = HumanMessage(content=f"Social media task: {state.task}")
        response = await _call_with_retry(llm.ainvoke, [system_prompt, human_msg])
        logger.info("social.complete", result_len=len(response.content))
        return {
            "social_result": response.content,
            "messages": [AIMessage(content=f"[Social] {response.content[:200]}...")],
        }
    except Exception as exc:
        logger.error("social.failed", error=str(exc))
        return {
            "social_result": f"[ERROR] Social agent failed: {exc}",
            "agent_errors": {**state.agent_errors, "social": str(exc)},
        }


async def writing_node(
    state: AgentState, config: RunnableConfig | None = None
) -> dict:
    """Pam — Narrative & Writing agent."""
    logger.info("writing.start", task=state.task[:80])
    llm = _get_llm()

    system_prompt = SystemMessage(content="""You are Pam, the Narrative & Writing specialist.
You write compelling blog posts, documentation, and hackathon narratives.
Your writing is clear, structured, and tells a story. You understand:
- Technical writing for different audiences
- SEO-friendly structure
- Hackathon/devpost narrative arcs
- Documentation best practices""")

    try:
        human_msg = HumanMessage(content=f"Writing task: {state.task}")
        response = await _call_with_retry(llm.ainvoke, [system_prompt, human_msg])
        logger.info("writing.complete", result_len=len(response.content))
        return {
            "writing_result": response.content,
            "messages": [AIMessage(content=f"[Writing] {response.content[:200]}...")],
        }
    except Exception as exc:
        logger.error("writing.failed", error=str(exc))
        return {
            "writing_result": f"[ERROR] Writing agent failed: {exc}",
            "agent_errors": {**state.agent_errors, "writing": str(exc)},
        }


async def human_review_node(
    state: AgentState, config: RunnableConfig | None = None
) -> dict:
    """
    Human-in-the-loop gate.
    Pauses execution and waits for human approval before final aggregation.
    Uses LangGraph's interrupt() for native HITL support.
    """
    logger.info("human_review.gate", agents_used=state.agents_needed)

    review_data = {
        "task": state.task,
        "agents_used": state.agents_needed,
        "research": state.research_result[:500] if state.research_result else "",
        "engineering": state.engineering_result[:500] if state.engineering_result else "",
        "social": state.social_result[:500] if state.social_result else "",
        "writing": state.writing_result[:500] if state.writing_result else "",
        "errors": state.agent_errors,
    }

    # interrupt() pauses the graph and returns data to the caller
    decision = interrupt({
        "message": "Review agent outputs before final synthesis.",
        "agent_outputs": review_data,
        "options": ["approve", "revise", "reject"],
    })

    action = decision.get("action", "approve")
    feedback = decision.get("feedback", "")

    logger.info("human_review.decision", action=action)

    if action == "reject":
        return {
            "final_output": f"Task rejected by human reviewer. Feedback: {feedback}",
            "current_step": "rejected",
            "human_approved": False,
            "human_feedback": feedback,
        }

    return {
        "human_approved": True,
        "human_feedback": feedback,
        "current_step": "human_approved",
    }


async def aggregator_node(
    state: AgentState, config: RunnableConfig | None = None
) -> dict:
    """
    Monica — Synthesizes all agent outputs into a final response.
    """
    logger.info("aggregator.start")
    llm = _get_llm()

    # Collect all results
    results = []
    if state.research_result:
        results.append(f"## 🔍 Research (Dwight)\n{state.research_result}")
    if state.engineering_result:
        results.append(f"## 👩‍💻 Engineering (Ross)\n{state.engineering_result}")
    if state.social_result:
        results.append(f"## 📱 Social Media (Kelly)\n{state.social_result}")
    if state.writing_result:
        results.append(f"## ✍️ Writing (Pam)\n{state.writing_result}")

    combined = "\n\n---\n\n".join(results)

    # Include human feedback if any
    feedback_note = ""
    if state.human_feedback:
        feedback_note = f"\n\nHuman reviewer feedback to incorporate: {state.human_feedback}"

    system_prompt = SystemMessage(content="""You are Monica, the Chief of Staff.
Your team has completed their work. Synthesize everything into a single,
coherent, actionable response for the user.

Structure it as:
1. Executive Summary (2-3 sentences)
2. Key Deliverables (what the team produced)
3. Next Steps / Recommendations

Be concise but thorough. The user should walk away knowing exactly what to do.""")

    human_msg = HumanMessage(
        content=f"Original task: {state.task}\n\nTeam outputs:\n{combined}{feedback_note}"
    )
    response = await _call_with_retry(llm.ainvoke, [system_prompt, human_msg])
    logger.info("aggregator.complete", output_len=len(response.content))

    return {
        "final_output": response.content,
        "current_step": "complete",
        "messages": [response],
    }


# ---------------------------------------------------------------------------
# Routing Logic
# ---------------------------------------------------------------------------

def route_to_agents(state: AgentState) -> list[str]:
    """Conditional edge: determine which agent nodes to execute in parallel."""
    return state.agents_needed


# Map agent names to node functions
AGENT_NODES = {
    "research": research_node,
    "engineering": engineering_node,
    "social": social_node,
    "writing": writing_node,
}


# ---------------------------------------------------------------------------
# Graph Construction
# ---------------------------------------------------------------------------

def build_graph(*, enable_hitl: bool = False) -> StateGraph:
    """
    Build the LangGraph multi-agent orchestration graph.

    Args:
        enable_hitl: If True, adds a human-in-the-loop interrupt node
                     between agent execution and final aggregation.

    Flow:
      START → orchestrator → [research | engineering | social | writing]*
                            → [human_review?] → aggregator → END
    """
    graph = StateGraph(AgentState)

    # Add nodes
    graph.add_node("orchestrator", orchestrator_node)
    graph.add_node("research", research_node)
    graph.add_node("engineering", engineering_node)
    graph.add_node("social", social_node)
    graph.add_node("writing", writing_node)
    graph.add_node("aggregator", aggregator_node)

    if enable_hitl:
        graph.add_node("human_review", human_review_node)

    # Entry point
    graph.set_entry_point("orchestrator")

    # Conditional fan-out: orchestrator routes to needed agents
    graph.add_conditional_edges(
        "orchestrator",
        route_to_agents,
        {
            "research": "research",
            "engineering": "engineering",
            "social": "social",
            "writing": "writing",
        },
    )

    # All agents converge to either human_review or aggregator
    convergence_target = "human_review" if enable_hitl else "aggregator"
    for agent_name in AGENT_NODES:
        graph.add_edge(agent_name, convergence_target)

    # Human review → aggregator (if HITL enabled)
    if enable_hitl:
        graph.add_edge("human_review", "aggregator")

    # Aggregator → END
    graph.add_edge("aggregator", END)

    return graph


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def compile_graph(*, enable_hitl: bool = False):
    """Compile and return the orchestration graph."""
    return build_graph(enable_hitl=enable_hitl).compile()


# Default compiled graph (no HITL)
graph = compile_graph()


async def run_team(
    task: str,
    model: str | None = None,
    enable_hitl: bool = False,
    stream: bool = False,
) -> dict[str, Any]:
    """
    Run the autonomous agent team on a task.

    Args:
        task: The user's request / task description
        model: Optional model override
        enable_hitl: Enable human-in-the-loop interrupt before aggregation
        stream: If True, return an async generator yielding intermediate states

    Returns:
        dict with 'final_output', individual agent results, and routing info.
        If stream=True, returns an async generator of state updates.
    """
    compiled = compile_graph(enable_hitl=enable_hitl)
    initial_state = AgentState(task=task)
    config = {"configurable": {"model": model}} if model else None

    if stream:
        return _stream_team(compiled, initial_state, config)

    result = await compiled.ainvoke(initial_state, config=config)

    return {
        "task": task,
        "agents_used": result.get("agents_needed", []),
        "research": result.get("research_result", ""),
        "engineering": result.get("engineering_result", ""),
        "social": result.get("social_result", ""),
        "writing": result.get("writing_result", ""),
        "errors": result.get("agent_errors", {}),
        "final_output": result.get("final_output", ""),
    }


async def _stream_team(compiled, initial_state: AgentState, config: dict | None):
    """Async generator yielding intermediate state updates during execution."""
    async for event in compiled.astream(initial_state, config=config):
        # Each event is a dict of {node_name: state_update}
        for node_name, update in event.items():
            logger.info("stream.event", node=node_name)
            yield {"node": node_name, "update": update}


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import json
    import sys

    async def main():
        # Parse flags
        args = sys.argv[1:]
        hitl = "--hitl" in args
        stream = "--stream" in args
        args = [a for a in args if not a.startswith("--")]

        task = " ".join(args) or (
            "Research the latest trends in agentic AI and write a Twitter thread about it"
        )

        structlog.configure(
            processors=[
                structlog.dev.ConsoleRenderer(),
            ],
        )

        print(f"🎯 Task: {task}")
        if hitl:
            print("⏸️  Human-in-the-loop: ENABLED")
        if stream:
            print("📡 Streaming mode: ENABLED")
        print()

        if stream:
            async for event in _stream_team(
                compile_graph(enable_hitl=hitl), AgentState(task=task), None
            ):
                print(f"  ⚡ {event['node']}: {str(event['update'])[:100]}...")
            print("\n✅ Streaming complete")
        else:
            result = await run_team(task, enable_hitl=hitl)
            print(f"\n{'='*60}")
            print(f"Agents dispatched: {', '.join(result['agents_used'])}")
            if result.get("errors"):
                print(f"Agent errors: {json.dumps(result['errors'], indent=2)}")
            print(f"{'='*60}")
            print(f"\n{result['final_output']}")

    asyncio.run(main())
