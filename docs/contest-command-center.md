# Contest Command Center

Last updated: 2026-03-05 (IST)

This document converts contest rules into execution gates for the two active projects.

## Active Contests

### 1) Gemini Live Agent Challenge

- Deadline: **2026-03-16 20:00 EDT**
- Project path: `/Users/mangeshraut/Downloads/Gemini Live Agent Challenge`
- Checklist source: `DEVPOST_SUBMISSION_CHECKLIST.md`
- Category target: **Live Agents**
- Mandatory stack: Gemini model + Google GenAI SDK/ADK + Google Cloud hosting
- Critical missing artifacts: final demo URL, Cloud Run URL/proof, published article URL

### 2) GitLab AI Hackathon

- Deadline: **2026-03-25 14:00 EDT**
- Project path: `/Users/mangeshraut/Downloads/AI Agent/projects/gitlab-ai-hackathon-2026`
- Checklist source: `CHECKLIST.md`
- Core requirement: at least one public custom agent/flow that takes triggered action (not chat-only)
- Critical missing artifacts: live Duo evidence, real GitLab write-back proof, cloud proof, <=3m demo

## Fast Commands

```bash
# GitLab project validation
cd "/Users/mangeshraut/Downloads/AI Agent/projects/gitlab-ai-hackathon-2026"
./scripts/validate.sh
./scripts/submission-readiness.sh

# Gemini project validation
cd "/Users/mangeshraut/Downloads/Gemini Live Agent Challenge"
./scripts/security-check.sh --scope deploy
```

## Agent Routing

- Monica: drive checklist closure and deadline management
- Dwight: source fidelity and rule compliance checks
- Ross: implementation + tests + deploy proof
- Kelly/Rachel: public narrative aligned to judging criteria
- Pam: final submission copy + demo script + asset pack

## Definition of Done

Both projects are DONE only when all checklist items are checked and link placeholders are replaced with live URLs.
