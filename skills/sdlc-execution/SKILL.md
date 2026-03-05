---
name: sdlc-execution
description: Execute software delivery end-to-end (communication, planning, implementation, verification, security, deployment, submission). Use for any project where "build" is requested and planning-only output is insufficient.
---

# SDLC Execution Skill

## Core Rule
A project is not "in progress" unless code, tests, and deployment evidence are moving.

## Stage Checklist

1. Communication
- Define objective, scope, constraints, success criteria.
- Output: `status/SDLC-BOARD.md`

2. Planning
- Produce architecture and milestone plan.
- Output: `deliverables/TECH-SPEC.md`, `deliverables/IMPLEMENTATION-PLAN.md`

3. Implementation
- Create/modify production code and tests.
- Output: code diff + test files.

4. Verification
- Run tests and record commands/results.
- Output: validation log in `status/`.

5. Security
- Run security checks and enforce policy files.
- Output: updated security notes/checklist.

6. Deployment
- Verify deploy script/IaC path works and health endpoint proof exists.
- Output: deploy proof reference.

7. Submission Packaging
- Final README, checklist, and narrative aligned to contest rules.
- Output: checklist closure report.

## Agent Responsibilities
- Monica: phase gating and blocker routing
- Dwight: source-backed requirement validation
- Ross: implementation, tests, deployment technical proof
- Kelly/Rachel: launch messaging and positioning
- Pam: submission narrative and final artifact hygiene

## Mandatory Evidence Per Cycle
For each cycle, report:
- Files changed
- Tests run (exact command)
- Deployment/security checks run
- Remaining blocker count

If any of these are missing, cycle is incomplete.
