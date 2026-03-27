"""
CrewAI Multi-Agent Orchestrator — 2026 Production Edition
===========================================================

A CrewAI implementation of the same 6-agent autonomous team.
Demonstrates multi-agent orchestration using CrewAI's crew-based
approach — an alternative to LangGraph's graph-based pattern.

Architecture:
  User Input
      │
      ▼
  ┌─────────────────┐
  │     Crew          │
  │  ┌─────────────┐ │
  │  │   Agents      │ │  ← 5 specialized agents
  │  │   Tasks       │ │  ← task-per-agent with context sharing
  │  │   Process     │ │  ← sequential or hierarchical
  │  └─────────────┘ │
  └────────┬────────┘
           ▼
      Final Output

Requirements:
  pip install -r crewai/requirements.txt
"""

from __future__ import annotations

import os
from typing import Any

from crewai import Agent, Crew, Process, Task


# ---------------------------------------------------------------------------
# Agent Definitions
# ---------------------------------------------------------------------------

def create_research_agent() -> Agent:
    """Dwight — Intel & Research specialist."""
    return Agent(
        role="Research & Intel Specialist",
        goal="Provide thorough, well-sourced research and competitive analysis",
        backstory=(
            "You are Dwight, a meticulous researcher who leaves no stone unturned. "
            "You cite sources, validate claims, and present findings in clear, "
            "structured formats. You're the team's fact-checker and knowledge base."
        ),
        verbose=True,
        allow_delegation=False,
    )


def create_engineering_agent() -> Agent:
    """Ross — Engineering specialist."""
    return Agent(
        role="Engineering Specialist",
        goal="Write production-quality code and design robust technical architectures",
        backstory=(
            "You are Ross, a seasoned engineer who thinks in systems. You write "
            "clean, well-tested code with clear documentation. You consider edge "
            "cases, performance, and security from the start."
        ),
        verbose=True,
        allow_delegation=False,
    )


def create_social_agent() -> Agent:
    """Kelly — Social Media specialist."""
    return Agent(
        role="Social Media Strategist",
        goal="Create viral content, engaging Twitter/X threads, and social media strategies",
        backstory=(
            "You are Kelly, a social media native who understands what makes content "
            "go viral. You craft hooks, threads, and calls-to-action that resonate "
            "with audiences. You think in engagement metrics and shareability."
        ),
        verbose=True,
        allow_delegation=False,
    )


def create_writing_agent() -> Agent:
    """Pam — Narrative & Writing specialist."""
    return Agent(
        role="Narrative & Writing Specialist",
        goal="Write compelling blog posts, documentation, and hackathon narratives",
        backstory=(
            "You are Pam, a storyteller who turns technical concepts into compelling "
            "narratives. You write clear, SEO-friendly content that tells a story. "
            "From hackathon devpost writeups to product documentation, you do it all."
        ),
        verbose=True,
        allow_delegation=False,
    )


def create_manager_agent() -> Agent:
    """Monica — Chief of Staff / Crew Manager."""
    return Agent(
        role="Chief of Staff",
        goal="Orchestrate the team, synthesize outputs, and deliver actionable results",
        backstory=(
            "You are Monica, the team's orchestrator. You decompose complex requests "
            "into tasks for your specialists, then synthesize their outputs into "
            "coherent, actionable responses. You think strategically and communicate clearly."
        ),
        verbose=True,
        allow_delegation=True,
    )


# ---------------------------------------------------------------------------
# Task Definitions
# ---------------------------------------------------------------------------

def create_research_task(agent: Agent, task_description: str) -> Task:
    return Task(
        description=f"Research the following topic thoroughly: {task_description}",
        expected_output=(
            "A structured research brief with key findings, sources cited, "
            "and actionable takeaways. Use bullet points and headers."
        ),
        agent=agent,
    )


def create_engineering_task(agent: Agent, task_description: str) -> Task:
    return Task(
        description=f"Provide technical implementation for: {task_description}",
        expected_output=(
            "Technical approach with pseudocode or actual code, architecture "
            "diagrams (text-based), potential pitfalls, and testing strategy."
        ),
        agent=agent,
    )


def create_social_task(agent: Agent, task_description: str) -> Task:
    return Task(
        description=f"Create social media content for: {task_description}",
        expected_output=(
            "Ready-to-post social media content including Twitter/X thread "
            "(numbered), key hooks, hashtags, and engagement strategy."
        ),
        agent=agent,
    )


def create_writing_task(agent: Agent, task_description: str) -> Task:
    return Task(
        description=f"Write a narrative/documentation piece for: {task_description}",
        expected_output=(
            "A well-structured written piece with clear sections, compelling "
            "intro, detailed body, and strong conclusion. SEO-friendly headers."
        ),
        agent=agent,
    )


# ---------------------------------------------------------------------------
# Crew Construction
# ---------------------------------------------------------------------------

def build_crew(
    task_description: str,
    agents_to_use: list[str] | None = None,
    process: Process = Process.sequential,
) -> Crew:
    """
    Build a CrewAI crew for the given task.

    Args:
        task_description: The user's request / task description
        agents_to_use: List of agent names to include. None = all agents.
                       Options: "research", "engineering", "social", "writing"
        process: Process.sequential (default) or Process.hierarchical

    Returns:
        Configured Crew instance ready to kickoff()
    """
    all_agents = {
        "research": create_research_agent,
        "engineering": create_engineering_agent,
        "social": create_social_agent,
        "writing": create_writing_agent,
    }

    task_factories = {
        "research": create_research_task,
        "engineering": create_engineering_task,
        "social": create_social_task,
        "writing": create_writing_task,
    }

    if agents_to_use is None:
        agents_to_use = list(all_agents.keys())

    # Create agents
    agents = []
    tasks = []
    for name in agents_to_use:
        if name in all_agents:
            agent = all_agents[name]()
            agents.append(agent)
            task = task_factories[name](agent, task_description)
            tasks.append(task)

    # Add manager for hierarchical process
    manager = create_manager_agent() if process == Process.hierarchical else None

    crew = Crew(
        agents=agents,
        tasks=tasks,
        process=process,
        manager_agent=manager,
        verbose=True,
    )

    return crew


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def run_team(
    task: str,
    agents: list[str] | None = None,
    process: str = "sequential",
) -> dict[str, Any]:
    """
    Run the autonomous agent team on a task using CrewAI.

    Args:
        task: The user's request / task description
        agents: List of agent names to use (None = all)
        process: "sequential" or "hierarchical"

    Returns:
        dict with task, agents_used, result, and process type
    """
    proc = Process.hierarchical if process == "hierarchical" else Process.sequential
    crew = build_crew(task, agents_to_use=agents, process=proc)

    result = crew.kickoff()

    return {
        "task": task,
        "agents_used": agents or ["research", "engineering", "social", "writing"],
        "process": process,
        "result": str(result),
        "raw": result,
    }


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import sys

    args = sys.argv[1:]
    hierarchical = "--hierarchical" in args
    args = [a for a in args if not a.startswith("--")]

    task = " ".join(args) or (
        "Research the latest trends in agentic AI and write a Twitter thread about it"
    )

    proc = "hierarchical" if hierarchical else "sequential"
    print(f"🎯 Task: {task}")
    print(f"⚙️  Process: {proc}")
    print()

    result = run_team(task, process=proc)

    print(f"\n{'='*60}")
    print(f"Agents used: {', '.join(result['agents_used'])}")
    print(f"Process: {result['process']}")
    print(f"{'='*60}")
    print(f"\n{result['result']}")
