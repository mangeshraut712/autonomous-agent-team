---
name: task-decompose
description: Chief-of-Staff orchestration skill for end-to-end SDLC delivery. Use this when a request is project-scale and needs multi-agent execution from requirements to deployment evidence.
---

# Task Decomposition & SDLC Orchestration Skill

When a user asks to build a real project, you must orchestrate full SDLC delivery.
Planning-only output is invalid.

## Required Output Files (Project Root)

Create/update these artifacts for every project cycle:

1. `status/SDLC-BOARD.md` — source of truth for stage status
2. `deliverables/TECH-SPEC.md` — architecture and interfaces
3. `deliverables/IMPLEMENTATION-PLAN.md` — milestones and acceptance tests
4. `deliverables/SUBMISSION-NARRATIVE.md` — judge-ready story and demo flow

## SDLC Phases (Must Run In Order)

### Phase 0: Communication & Scope (Monica)
- Clarify objective, deadline, judging criteria, constraints.
- Write success criteria in `status/SDLC-BOARD.md`.

### Phase 1: Discovery & Research (Dwight)
- Collect source-verified requirements, benchmarks, risks.
- Write findings to `deliverables/RESEARCH-BRIEF.md`.

### Phase 2: Design (Monica + Ross)
- Convert requirements into architecture, interfaces, and acceptance tests.
- Update `deliverables/TECH-SPEC.md`.

### Phase 3: Build (Ross)
- Implement code in project runtime paths.
- Add/upgrade tests for every major change.
- No stage completion without code changes.

### Phase 4: Verification (Ross)
- Run tests/lint/security checks.
- Record evidence in `status/` (commands + outputs).

### Phase 5: Packaging (Pam + Monica)
- Update README, checklist, submission narrative, and reproducible runbook.

### Phase 6: Demo & Deploy Evidence (Ross + Pam)
- Capture deploy proof and demo checklist status.
- Ensure required URLs/placeholders are closed before submission.

## Dispatch Rules (`sessions_send`)

1. Dispatch one phase owner at a time with concrete file paths.
2. Require owner to return exact artifacts changed and test commands run.
3. If a phase fails validation, do not move forward.
4. Route blockers explicitly back to owner with remediation request.

## Completion Criteria

Do not mark complete unless:
- Code exists and is test-validated.
- Security/deploy evidence exists.
- Submission checklist has no unresolved mandatory items.
