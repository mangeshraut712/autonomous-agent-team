# SDLC Lifecycle Playbook (Agents)

Use this playbook to prevent planning-only drift and force execution.

## Lifecycle Stages

1. Communication
- Capture objective, constraints, deadline, judging criteria.

2. Planning
- Produce architecture and implementation plan with acceptance tests.

3. Build
- Implement real code and tests.

4. Verify
- Run test suite and quality gates.

5. Secure
- Enforce policy/security rules and document risks.

6. Deploy
- Validate deployment path and health proof.

7. Package
- Final README/checklist/demo script/submission links.

## Required Evidence per Stage

- Communication: `MISSION.md`, `AGENT-TASKS.md`
- Planning: `PLAN.md`, `deliverables/TECH-SPEC.md`, `deliverables/IMPLEMENTATION-PLAN.md`
- Build: source files changed under runtime directories
- Verify: test command output captured
- Secure: `SECURITY_RULES.md` compliance notes
- Deploy: deploy script/IaC + health proof
- Package: checklist open items trend to zero

## Operator Commands

```bash
# Cross-contest status
make contest-status

# SDLC gate for a project
make sdlc-guard PROJECT=projects/gitlab-ai-hackathon-2026

# Run project validation
cd projects/gitlab-ai-hackathon-2026
./scripts/validate.sh
./scripts/submission-readiness.sh
```

## Anti-Drift Rule

If two consecutive cycles produce no code/test/deploy evidence, treat the cycle as failed and re-route work to execution owner (Ross).
