#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
info()  { printf "\n\033[1;34m==> %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m    %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m    %s\033[0m\n" "$1"; }
fail()  { printf "\033[1;31m    %s\033[0m\n" "$1"; }

command_exists() { command -v "$1" &>/dev/null; }

# ------------------------------------------------------------
# Pre-flight: Xcode Command Line Tools
# ------------------------------------------------------------
info "Checking Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    ok "Already installed"
else
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key once the installation has completed..."
    read -r -n 1
fi

# ------------------------------------------------------------
# Pre-flight: Homebrew
# ------------------------------------------------------------
info "Checking Homebrew"
if command_exists brew; then
    ok "Already installed"
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ------------------------------------------------------------
# Homebrew Bundle (Brewfile)
# ------------------------------------------------------------
info "Installing Homebrew packages (Brewfile)"
brew bundle --file="$SCRIPT_DIR/Brewfile" --no-lock

# ------------------------------------------------------------
# Oracle Cloud CLI (oci-cli via pip)
# ------------------------------------------------------------
info "Checking Oracle Cloud CLI (oci)"
if command_exists oci; then
    ok "Already installed"
else
    info "Installing oci-cli via pip..."
    if command_exists pipx; then
        pipx install oci-cli
    elif command_exists pip3; then
        pip3 install --user oci-cli
    else
        fail "pip3/pipx not found - install Python first, then run: pip3 install oci-cli"
    fi
fi

# ------------------------------------------------------------
# dbt Cloud CLI
# ------------------------------------------------------------
info "Checking dbt Cloud CLI"
if command_exists dbt; then
    ok "Already installed"
else
    info "Installing dbt Cloud CLI..."
    brew install dbt-labs/dbt-cli/dbt-cloud-cli 2>/dev/null || \
        warn "dbt Cloud CLI brew install failed - try: pip3 install dbt-core"
fi

# ------------------------------------------------------------
# Azure DevOps CLI extension
# ------------------------------------------------------------
info "Checking Azure DevOps CLI extension"
if az extension show --name azure-devops &>/dev/null 2>&1; then
    ok "Already installed"
else
    info "Installing Azure DevOps extension for az CLI..."
    az extension add --name azure-devops
fi

# ------------------------------------------------------------
# Snowflake Cortex Code (VS Code extension)
# ------------------------------------------------------------
info "Checking Snowflake Cortex Code (VS Code extension)"
if command_exists code; then
    if code --list-extensions 2>/dev/null | grep -qi "snowflake.cortex-code"; then
        ok "Already installed"
    else
        info "Installing Snowflake Cortex Code extension..."
        code --install-extension snowflake.cortex-code || \
            warn "Could not install Cortex Code extension - install manually from VS Code marketplace"
    fi
else
    warn "VS Code CLI not found - install Cortex Code extension manually from VS Code marketplace"
fi

# ------------------------------------------------------------
# Claude Code (npm)
# ------------------------------------------------------------
info "Checking Claude Code"
if command_exists claude; then
    ok "Already installed"
else
    info "Installing Claude Code via npm..."
    if command_exists npm; then
        npm install -g @anthropic-ai/claude-code
    else
        fail "npm not found - install Node.js first, then run: npm install -g @anthropic-ai/claude-code"
    fi
fi

# ------------------------------------------------------------
# SQLFluff (pipx)
# ------------------------------------------------------------
info "Checking SQLFluff"
if command_exists sqlfluff; then
    ok "Already installed"
else
    info "Installing SQLFluff via pipx..."
    if command_exists pipx; then
        pipx install sqlfluff
    elif command_exists pip3; then
        pip3 install --user sqlfluff
    else
        fail "pipx/pip3 not found - install Python first, then run: pipx install sqlfluff"
    fi
fi

# ------------------------------------------------------------
# MCP Servers (npm)
# ------------------------------------------------------------
MCP_SERVERS=(
    "@modelcontextprotocol/server-github"
    "@modelcontextprotocol/server-slack"
    "@modelcontextprotocol/server-filesystem"
    "@anthropic-ai/mcp-server-duckdb"
    "@modelcontextprotocol/server-snowflake"
    "@databricks/mcp-server-databricks"
    "@anthropic-ai/mcp-server-aws"
    "@dbt-labs/mcp-server-dbt"
)

info "Checking MCP servers"
if command_exists npm; then
    for server in "${MCP_SERVERS[@]}"; do
        if npm list -g "$server" &>/dev/null; then
            ok "$server already installed"
        else
            info "Installing $server..."
            npm install -g "$server" || warn "Failed to install $server"
        fi
    done
else
    fail "npm not found - install Node.js first, then re-run to install MCP servers"
fi

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
info "Installation complete! Review any warnings above."
echo ""
echo "  Post-install steps:"
echo "    - Sign in to Azure CLI:       az login"
echo "    - Sign in to AWS CLI:         aws configure"
echo "    - Sign in to Snowflake CLI:   snow connection add"
echo "    - Sign in to Databricks CLI:  databricks configure"
echo "    - Sign in to OCI CLI:         oci setup config"
echo "    - Sign in to dbt Cloud:       dbt cloud login"
echo "    - Configure Atuin:            atuin login"
echo "    - Initialize zoxide:          Add 'eval \"\$(zoxide init zsh)\"' to ~/.zshrc"
echo "    - Sign in to Claude Desktop"
echo "    - Sign in to LM Studio"
echo ""
