# data-dev-tools

> **Platform: macOS only** (Apple Silicon and Intel)

One-command setup for a data engineering Mac. Installs CLI tools, desktop applications, cloud platform CLIs, MCP servers, and configures macOS preferences — everything a data developer needs on a fresh Mac.

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
| Terraform | `terraform` | Define and provision cloud infrastructure as code |
| Oracle Cloud CLI | `oci` | Manage Oracle Cloud Infrastructure resources |
| Azure DevOps extension | `az devops` | Azure CLI extension for managing DevOps pipelines, repos, and boards |

### Data Tools

| Tool | Command | Description |
|------|---------|-------------|
| libpq | `psql` | PostgreSQL native client library and CLI |
| mysql-client | `mysql` | MySQL native client library and CLI |
| Oracle Instant Client | — | Oracle database driver — required by DBeaver for Oracle connections (manual download) |
| unixODBC | `odbcinst` | ODBC driver manager — required for Dataverse and SQL Server connections |
| Microsoft ODBC Driver 18 | — | ODBC driver for SQL Server and Dataverse TDS endpoint |
| mssql-tools18 | `sqlcmd`, `bcp` | SQL Server command-line tools for queries and bulk data operations |
| DuckDB | `duckdb` | In-process analytical SQL database for fast local querying |
| dbt Cloud CLI | `dbt` | Build, test, and manage dbt data transformation projects |
| jq | `jq` | Lightweight command-line JSON processor |
| yq | `yq` | Command-line YAML/JSON/XML processor |
| parquet-tools | `parquet-tools` | Inspect and explore Parquet files without loading into a database |
| pgcli | `pgcli` | Postgres CLI with autocomplete and syntax highlighting |
| rclone | `rclone` | Sync files to and from S3, Azure Blob, GCS, and 40+ cloud storage providers |
| SQLFluff | `sqlfluff` | SQL linter and formatter with dbt integration |

### Terminal & Productivity

| Tool | Command | Description |
|------|---------|-------------|
| gh | `gh` | GitHub CLI for managing PRs, issues, and Actions from the terminal |
| lazygit | `lazygit` | Terminal UI for Git — stage, commit, branch, and merge visually |
| eza | `eza` | Modern `ls` replacement with Git status integration and color output |
| Starship | `starship` | Customizable shell prompt with context for Git, Python, cloud, and more |
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
| JetBrains Mono | Monospaced font designed for code — ligatures, clear distinction between similar characters |
| Docker Desktop | Run containers locally for databases, dbt, pipelines, and development environments |
| Anaconda | Python 3 distribution with pre-installed data science packages (NumPy, pandas, scikit-learn, Jupyter, etc.) |
| SketchyBar | Highly customizable macOS menu bar replacement |
| AeroSpace | i3-like tiling window manager for macOS |
| Ghostty | Fast, native terminal emulator |
| cmux | Ghostty-based terminal multiplexer app |
| Visual Studio Code | Code editor with extensions and integrated terminal |
| DBeaver Community | Universal database tool — connect to Snowflake, Databricks, Postgres, and more |
| Sublime Text | Lightweight, fast text editor |
| LM Studio | Run local LLMs on your Mac |
| GitHub Desktop | Visual Git client for managing repositories, branches, and pull requests |
| Azure Storage Explorer | Browse and manage Azure Blob, Queue, Table, and File storage |
| Tad | Desktop viewer for Parquet, CSV, and SQLite files |
| JSON Crack | Visual graph-based JSON viewer and explorer |
| qlstephen | Quicklook plugin — preview any plain text file in Finder with spacebar |
| quicklook-json | Quicklook plugin — formatted JSON preview in Finder with spacebar |
| Slack | Team messaging and communication |
| Microsoft Teams | Microsoft collaboration and video conferencing |
| Raycast | Spotlight replacement — launcher, snippets, clipboard history, and extensions |
| Microsoft OneDrive | Cloud file storage and sync for Microsoft 365 |
| Google Drive | Cloud file storage and sync for Google Workspace |
| Logitech G Hub | Configuration software for Logitech peripherals |
| Claude Desktop | Anthropic's Claude AI assistant |

### Mac App Store

| App | Description |
|-----|-------------|
| Amphetamine | Keep your Mac awake during long-running jobs |
| WhatsApp Messenger | WhatsApp messaging client |

### VS Code Extensions

**AI Assistants:**

| Extension | Description |
|-----------|-------------|
| Snowflake Cortex Code | Snowflake AI coding assistant |
| Cline (claude-dev) | Autonomous AI coding agent in VS Code |
| GitHub Copilot | AI code completion and suggestions |
| GitHub Copilot Chat | Conversational AI assistant in VS Code |
| Continue | Open-source AI assistant — works with local LLMs from LM Studio |

**Python / Data Science:**

| Extension | Description |
|-----------|-------------|
| Python | Language support, IntelliSense, and debugging |
| Pylance | Fast Python language server |
| Black Formatter | Python code formatter |
| Debugpy | Python debugger |
| Python Environments | Manage Python environments |
| Jupyter | Jupyter notebook support |
| Jupyter Keymap | Jupyter keyboard shortcuts |
| Jupyter Renderers | Additional Jupyter output renderers |
| Jupyter Cell Tags | Cell tag support for notebooks |
| Jupyter Slideshow | Slideshow support for notebooks |

**SQL / Data:**

| Extension | Description |
|-----------|-------------|
| SQLTools | Database management and query runner |
| DuckDB SQL Tools | DuckDB support for SQLTools |
| SQLFluff | SQL linter and formatter |
| Rainbow CSV | Colorize CSV/TSV columns |
| Prettify JSON | JSON formatting |
| YAML | YAML language support |
| dbt Power User | dbt navigation, lineage, and autocomplete |

**Cloud / Containers:**

| Extension | Description |
|-----------|-------------|
| Docker | Docker container management |
| Azure Containers | Azure container tools |
| Remote - Containers | Develop inside containers |
| Kubernetes Tools | Kubernetes cluster management |
| Azure Account | Azure account management |
| AWS Toolkit | AWS resource management |

**SQL Server / MSSQL:**

| Extension | Description |
|-----------|-------------|
| MSSQL | SQL Server connection and query |
| Data Workspace | SQL data workspace |
| SQL Bindings | Azure SQL bindings |
| SQL Database Projects | SQL project management |

**Git:**

| Extension | Description |
|-----------|-------------|
| GitHub Pull Requests | Manage PRs and issues from VS Code |
| GitLens | Git blame, history, and annotations |

**General Development:**

| Extension | Description |
|-----------|-------------|
| Prettier | Code formatter for JS, TS, CSS, HTML, JSON, and more |
| Indent Rainbow | Colorize indentation levels |
| PowerShell | PowerShell language support |
| IntelliCode | AI-assisted code completions |

**Qlik:**

| Extension | Description |
|-----------|-------------|
| Qlik | Qlik Sense extension development |
| Qlik (Q-Masters) | Qlik development tools |
| Qlik Answers | Qlik Answers integration |

**Themes:**

| Extension | Description |
|-----------|-------------|
| GitHub Theme | Official GitHub color themes |
| GitHub Light Theme | Light theme inspired by GitHub |
| Darcula Theme | JetBrains Darcula theme |
| Solarized Light | Solarized Light color theme |
| Light VS Mac | Light theme for macOS |
| Better Material Theme Darker | Material darker high-contrast theme |
| Material Icon Theme | Material Design file icons |
| Catppuccin | Soothing pastel color theme |

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

# Terminal tools (add these lines to ~/.zshrc)
atuin login                 # Sync shell history
eval "$(zoxide init zsh)"   # Smart cd
eval "$(starship init zsh)" # Shell prompt

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
