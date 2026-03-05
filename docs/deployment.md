# Deployment Guide

This repository supports three deployment paths.

## 1) Local Native (recommended for development)

```bash
make workspace-setup
make env-sync
bash scripts/start-gateway.sh
```

## 2) Docker Compose (single-host)

```bash
cp .env.example .env
# fill required keys in .env
make deploy-docker
```

Then open:
- `http://127.0.0.1:${OPENCLAW_GATEWAY_PORT:-18789}/`

## 3) Contest Project Deploy Paths

### GitLab Contest Project
Path: `projects/gitlab-ai-hackathon-2026/`

```bash
cd projects/gitlab-ai-hackathon-2026
./deploy.sh YOUR_GCP_PROJECT_ID
```

Proof endpoint after deployment:
- `GET /healthz`

### Gemini Live Challenge Project
Path: `/Users/mangeshraut/Downloads/Gemini Live Agent Challenge`

Use project scripts and checklist there:
- `./deploy.sh <PROJECT_ID>`
- `DEVPOST_SUBMISSION_CHECKLIST.md`

## Root Cleanup (workspace hygiene)

To archive noisy local folders and keep root tidy:

```bash
make cleanup-root
```

This archives `_trash/` and `always-on-memory-agent/` into:
- `~/Downloads/AI-Agent-archive/<timestamp>/`
