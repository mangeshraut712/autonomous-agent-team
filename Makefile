SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help workspace-setup env-sync cron-install status test ready-strict notify notifier-install drift-audit reset-workspace boundary-fix

help:
	@echo "autonomous-agent-team commands"
	@echo "  make workspace-setup   - Apply OpenClaw workspace config"
	@echo "  make env-sync          - Sync project .env keys into ~/.openclaw/.env"
	@echo "  make cron-install      - Register 7 default cron jobs (incl. heartbeat)"
	@echo "  make status            - Show OpenClaw status snapshot"
	@echo "  make test              - Run workspace health checks"
	@echo "  make boundary-fix      - Repair/validate root workspace boundary"
	@echo "  make ready-strict      - Run strict production readiness checks"
	@echo "  make notify            - Send Telegram test notification"
	@echo "  make notifier-install  - Install recurring status notifier cron"
	@echo "  make drift-audit       - Run cron sprawl/drift audit"
	@echo "  make reset-workspace   - Clear daily intel/memory runtime files"

workspace-setup:
	@bash scripts/workspace-setup.sh

env-sync:
	@bash scripts/sync-openclaw-env.sh

cron-install:
	@bash scripts/add-cron-jobs.sh

status:
	@bash scripts/status.sh

test:
	@bash scripts/test.sh

ready-strict:
	@bash scripts/ready-strict.sh

notify:
	@bash scripts/notify.sh "OpenClaw test: Telegram delivery is working from autonomous-agent-team."

notifier-install:
	@bash scripts/notifier-install.sh

drift-audit:
	@bash scripts/drift-audit.sh

reset-workspace:
	@bash scripts/reset-workspace.sh

boundary-fix:
	@bash scripts/enforce-root-boundary.sh --fix
