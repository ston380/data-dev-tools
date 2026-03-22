# CLAUDE.md

## Project: data-dev-tools

macOS setup automation for data engineering tools. Installs CLI tools, desktop apps, and cloud platform CLIs via a single script.

## Setup

```bash
./install.sh
```

## Project Structure

- `install.sh` - Main install script (entry point)
- `Brewfile` - Homebrew formulae, casks, and Mac App Store apps
- `CLAUDE.md` - Project context for Claude Code

## How it works

1. Installs Xcode Command Line Tools (prerequisite)
2. Installs Homebrew if missing
3. Runs `brew bundle` with the Brewfile (CLI tools + desktop apps + App Store)
4. Installs tools not available via Homebrew (OCI CLI, dbt Cloud CLI, Azure DevOps extension, Cortex Code VS Code extension, Claude Code)
5. Prints post-install login/config steps

## Conventions

- Homebrew-installable tools go in `Brewfile`
- Everything else gets a dedicated section in `install.sh`
- Each section checks if already installed before attempting install
- Script uses `set -euo pipefail` for safety
