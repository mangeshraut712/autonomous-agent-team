#!/usr/bin/env bash
# scripts/install-proactive-crons.sh
# Installs the automated morning briefs and heartbeat to make OpenClaw "insane" (10x more proactive)

echo "🚀 Installing Proactive OpenClaw Crons..."

# 1. The Heartbeat (Runs every 30 mins)
# Ensures agents are self-healing and catching stuck jobs
openclaw cron add \
  --schedule "*/30 8-23 * * *" \
  --agent main \
  --prompt "Run the heartbeat health check in HEARTBEAT.md. If any issues exist, fix them or alert me. If it's the start of the day, review intel and assign tasks." \
  --announce
echo "✅ Installed: Heartbeat (every 30 mins)"

# 2. Dwight's Morning Research Sweep (8:00 AM)
# Gathers intel while you sleep and uses the Last 30 Days skill
openclaw cron add \
  --schedule "0 8 * * *" \
  --agent dwight \
  --prompt "Run the 'last-30-days' skill to find trending news on AI agents and Gemini. Compile the top 3 insights into intel/DAILY-INTEL.md." \
  --announce
echo "✅ Installed: Dwight Morning Sweep (8:00 AM daily)"

# 3. Kelly & Rachel Content Drafts (9:00 AM)
# Writes social content based on Dwight's intel
openclaw cron add \
  --schedule "0 9 * * *" \
  --agent kelly \
  --prompt "Read intel/DAILY-INTEL.md. Draft a highly engaging X/Twitter thread about the top trend and save it to your memory file for Mangesh to review." \
  --announce
echo "✅ Installed: Kelly Social Drafts (9:00 AM daily)"

# 4. Ross Engineering Review (10:00 AM)
# Checks code and intel for uncompleted Dev tasks
openclaw cron add \
  --schedule "0 10 * * *" \
  --agent ross \
  --prompt "Check intel/PROJECT-PLAN.md and the codebase for the active Gemini hackathon project. Identify the next coding task that needs to be done. Write a brief spec in your memory file and tell Monica you're ready to execute." \
  --announce
echo "✅ Installed: Ross Engineering Review (10:00 AM daily)"

# 5. The "Morning Surprise Rule" Briefing (10:30 AM)
# Monica aggregates everything done overnight and briefs Mangesh
openclaw cron add \
  --schedule "30 10 * * *" \
  --agent main \
  --prompt "Review the memory files of Dwight, Kelly, and Ross. Summarize what they accomplished overnight while Mangesh was sleeping. Send a 'Morning Surprise' brief to Mangesh on Telegram detailing the new intel, drafts, and coding tasks ready for approval." \
  --announce
echo "✅ Installed: Monica Morning Brief (10:30 AM daily)"

echo ""
echo "🎉 All proactive crons installed!"
echo "Your 6-agent team is now configured to work autonomously while you sleep."
echo "Run 'openclaw cron list' to verify."
