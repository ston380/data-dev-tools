# data-dev-tools

macOS setup automation for data engineering. A single script that installs CLI tools, desktop applications, cloud platform CLIs, and MCP servers — everything a data developer needs on a fresh Mac.

## Quick Start

```bash
git clone https://github.com/ston380/data-dev-tools.git
cd data-dev-tools
./install.sh
```

The script is idempotent — it skips anything already installed, so it's safe to re-run.

## What Gets Installed

### Prerequisites

Installed automatically if missing:

| Tool | Description |
|------|-------------|
| Xcode Command Line Tools | Apple developer tools required by Homebrew and other build tools |
| Homebrew | The macOS package manager used to install everything else |

### Cloud Platform CLIs

| Tool | Command | Description |
|------|---------|-------------|
| Snowflake CLI | `snow` | Manage Snowflake resources, run queries, and deploy applications |
| Databricks CLI | `databricks` | Interact with Databricks workspaces, jobs, clusters, and notebooks |
| Azure CLI | `az` | Manage Azure cloud resources and services |
| AWS CLI | `aws` | Manage Amazon Web Services resources and services |
| Oracle Cloud CLI | `oci` | Manage Oracle Cloud Infrastructure resources |
| Azure DevOps extension | `az devops` | Azure CLI extension for managing DevOps pipelines, repos, and boards |

### Data Tools

| Tool | Command | Description |
|------|---------|-------------|
| DuckDB | `duckdb` | In-process analytical SQL database for fast local querying |
| dbt Cloud CLI | `dbt` | Build, test, and manage dbt data transformation projects |

### Terminal & Productivity

| Tool | Command | Description |
|------|---------|-------------|
| lazygit | `lazygit` | Terminal UI for Git — stage, commit, branch, and merge visually |
| Atuin | `atuin` | Searchable, synced shell history with context (directory, exit code, duration) |
| zoxide | `z` | Smarter `cd` that learns your most-used directories |
| mactop | `mactop` | Real-time macOS system monitor for CPU, GPU, memory, and power |
| llmfit | `llmfit` | Find LLM models that fit your hardware specs |

### Package Managers

| Tool | Command | Description |
|------|---------|-------------|
| nvm | `nvm` | Node.js version manager — install and switch between Node versions |
| pipx | `pipx` | Install Python CLI tools in isolated environments |
| yarn | `yarn` | Fast, reliable JavaScript package manager |
| mas | `mas` | Install Mac App Store apps from the command line |

### Desktop Applications

| App | Description |
|-----|-------------|
| Anaconda | Python 3 distribution with pre-installed data science packages (NumPy, pandas, scikit-learn, Jupyter, etc.) |
| Ghostty | Fast, native terminal emulator |
| cmux | Ghostty-based terminal multiplexer app |
| Visual Studio Code | Code editor with extensions and integrated terminal |
| DBeaver Community | Universal database tool — connect to Snowflake, Databricks, Postgres, and more |
| Sublime Text | Lightweight, fast text editor |
| LM Studio | Run local LLMs on your Mac |
| Logitech G Hub | Configuration software for Logitech peripherals |
| Claude Desktop | Anthropic's Claude AI assistant |

### Mac App Store

| App | Description |
|-----|-------------|
| Amphetamine | Keep your Mac awake during long-running jobs |

### VS Code Extensions

| Extension | Description |
|-----------|-------------|
| Snowflake Cortex Code | Snowflake AI coding assistant for VS Code |

### AI Tools

| Tool | Command | Description |
|------|---------|-------------|
| Claude Code | `claude` | Anthropic's AI coding assistant for the terminal |

### MCP Servers

[Model Context Protocol](https://modelcontextprotocol.io/) servers installed globally via npm. These enable AI tools like Claude to interact with external services.

| Server | Description |
|--------|-------------|
| server-github | Read and manage GitHub repositories, issues, and pull requests |
| server-slack | Read and send Slack messages and search channels |
| server-filesystem | Securely access and manage local files |
| mcp-server-duckdb | Query DuckDB databases directly from AI tools |
| server-snowflake | Query and manage Snowflake data from AI tools |
| mcp-server-databricks | Interact with Databricks workspaces from AI tools |
| mcp-server-aws | Access and manage AWS resources from AI tools |
| mcp-server-dbt | Run and manage dbt projects from AI tools |

## Post-Install Setup

After running the script, complete these configuration steps:

```bash
# Cloud platforms
az login                    # Azure
aws configure               # AWS
snow connection add         # Snowflake
databricks configure        # Databricks
oci setup config            # Oracle Cloud
dbt cloud login             # dbt Cloud

# Terminal tools
atuin login                 # Sync shell history
eval "$(zoxide init zsh)"   # Add this line to ~/.zshrc

# Desktop apps
# Sign in to Claude Desktop, LM Studio
```

## Project Structure

```
data-dev-tools/
├── install.sh    # Main install script (entry point)
├── Brewfile      # Homebrew formulae, casks, and Mac App Store apps
├── CLAUDE.md     # Project context for Claude Code
└── README.md     # This file
```

## How It Works

1. Installs **Xcode Command Line Tools** (macOS build prerequisite)
2. Installs **Homebrew** if missing
3. Runs `brew bundle` with the Brewfile (CLI tools, desktop apps, App Store apps)
4. Installs tools not available via Homebrew (OCI CLI, dbt Cloud CLI, Azure DevOps extension, Cortex Code VS Code extension, Claude Code)
5. Installs **MCP servers** globally via npm
6. Prints post-install login and configuration steps

## Requirements

- macOS (Apple Silicon or Intel)
- Internet connection
- Apple ID (for Mac App Store apps)
