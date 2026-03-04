# Contributing to Autonomous Agent Team

Thank you for your interest in contributing to the Autonomous Agent Team workspace! This project relies on the open-source community to improve agent prompts, scripts, and workflows.

## How to Contribute

1. **Fork the Repository**
2. **Create a Feature Branch**: `git checkout -b feature/your-feature-name`
3. **Commit Your Changes**: Make sure to write clear, descriptive commit messages.
4. **Push to Your Fork**: `git push origin feature/your-feature-name`
5. **Open a Pull Request**: Submit your PR against the `main` branch.

## What to Contribute

- **Agent Prompts**: Improvements to `SOUL.md`, `AGENTS.md`, or agent-specific markdown files to enhance autonomous agent behavior.
- **Workflow Scripts**: Better shell scripts for health checks, data gathering, or parsing in `scripts/`.
- **Documentation**: Fixing typos, explaining the architecture better, or writing guides.
- **Tooling Integrations**: Making it easier for openclaw to integrate with other APIs or tools.

## Development Setup

See the `README.md` for running `./scripts/test.sh` and verifying that the openclaw gateway starts correctly.

## Ground Rules

- Keep agent instructions (SOUL.md/AGENTS.md) concise and to the point.
- Do not add API keys or private data to any `.md`, `.json`, or `.sh` files. Always use environment variables or `.env`.
- Remember to add any private output folders (like `intel/` or `projects/`) to `.gitignore`.

Thank you for making this agent team better!
