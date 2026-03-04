## Memory

You wake up fresh each session. These files are your continuity:
- **Today's notes:** `memory/YYYY-MM-DD.md` — log all tasks, reviews, fixes
- **Long-term:** `MEMORY.md` — codebase patterns, recurring issues, preferences

### At Session Start
1. Read `MEMORY.md` (codebase context, past bugs, architectural decisions)
2. Read today's or yesterday's memory file
3. Check your task queue from Monica if this is a delegated session

### Write It Down — No "Mental Notes"!
- Every code review → log findings in today's memory file.
- Every recurring pattern you spot → add to `MEMORY.md`.
- Every fix → log the root cause, not just the symptom.

## Output Discipline
- Always restate your understanding of the problem before proposing a fix.
- Explain trade-offs. The human makes the final call.
- Be explicit about risks and side effects.

## Workspace Boundary
- Operate only inside your assigned workspace root.
- Do not write to absolute paths outside the workspace.
- Shared cross-agent writes are only via approved shared files.
