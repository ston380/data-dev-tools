#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AVAILABLE_GROUPS=(cloud data terminal apps ai vscode config)

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
info()  { printf "\n\033[1;34m  %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m   %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m   %s\033[0m\n" "$1"; }
fail()  { printf "\033[1;31m   %s\033[0m\n" "$1"; }

command_exists() { command -v "$1" &>/dev/null; }

usage() {
    echo "  Usage: ./install.sh [groups...] [--install|--config] [--list] [--help]"
    echo ""
    echo "Options:"
    echo "  (no args)     Install and configure everything"
    echo "  --install     Only install (skip configuration)"
    echo "  --config      Only configure (skip installation)"
    echo "  --list        Show available groups"
    echo "  --help        Show this help message"
    echo ""
    echo "Groups: ${AVAILABLE_GROUPS[*]}"
    echo ""
    echo "Examples:"
    echo "  ./install.sh                      # Install + config everything"
    echo "  ./install.sh cloud data           # Install + config specific groups"
    echo "  ./install.sh cloud --install      # Only install cloud tools"
    echo "  ./install.sh cloud --config       # Only run config for cloud"
}

# ------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------
DO_INSTALL=true
DO_CONFIG=true
SELECTED_GROUPS=()
MODE_SET=false

for arg in "$@"; do
    case "$arg" in
        --install)
            DO_INSTALL=true
            DO_CONFIG=false
            MODE_SET=true
            ;;
        --config)
            DO_INSTALL=false
            DO_CONFIG=true
            MODE_SET=true
            ;;
        --list)
            echo "Available groups:"
            for g in "${AVAILABLE_GROUPS[@]}"; do
                case "$g" in
                    cloud)    icon="󰅟" ;;
                    data)     icon="󰆼" ;;
                    terminal) icon="" ;;
                    apps)     icon="" ;;
                    ai)       icon="󰧑" ;;
                    vscode)   icon="󰨞" ;;
                    config)   icon="" ;;
                    *)        icon=" " ;;
                esac
                echo "  $icon  $g"
            done
            exit 0
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            fail "Unknown option: $arg"
            usage
            exit 1
            ;;
        *)
            # Validate group name
            valid=false
            for g in "${AVAILABLE_GROUPS[@]}"; do
                if [[ "$arg" == "$g" ]]; then
                    valid=true
                    break
                fi
            done
            if $valid; then
                SELECTED_GROUPS+=("$arg")
            else
                fail "Unknown group: $arg"
                echo "Available groups: ${AVAILABLE_GROUPS[*]}"
                exit 1
            fi
            ;;
    esac
done

# No groups specified = all groups
if [[ ${#SELECTED_GROUPS[@]} -eq 0 ]]; then
    SELECTED_GROUPS=("${AVAILABLE_GROUPS[@]}")
fi

group_selected() {
    local target="$1"
    for g in "${SELECTED_GROUPS[@]}"; do
        [[ "$g" == "$target" ]] && return 0
    done
    return 1
}

# ------------------------------------------------------------
# Pre-flight: sudo credentials
# ------------------------------------------------------------
info " Requesting administrator access (one-time password prompt)"
sudo -v
# Keep sudo alive in the background until the script exits
while true; do sudo -n true; sleep 50; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

# ------------------------------------------------------------
# Pre-flight: Xcode Command Line Tools
# ------------------------------------------------------------
info " Checking Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    ok "Already installed"
else
    info " Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key once the installation has completed..."
    read -r -n 1
fi

# ------------------------------------------------------------
# Pre-flight: Homebrew
# ------------------------------------------------------------
info "󱄖 Checking Homebrew"
if command_exists brew; then
    ok "Already installed"
else
    info "󱄖 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================
# Install functions
# ============================================================

install_cloud() {
    info "󰅟 Installing cloud tools"
    brew bundle --file="$SCRIPT_DIR/brewfiles/Brewfile.cloud"

    # Oracle Cloud CLI (oci-cli via pip)
    info "󰅟 Checking Oracle Cloud CLI (oci)"
    if command_exists oci; then
        ok "Already installed"
    else
        info " Installing oci-cli via pip..."
        if command_exists pipx; then
            pipx install oci-cli
        elif command_exists pip3; then
            pip3 install --user oci-cli
        else
            fail "pip3/pipx not found - install Python first, then run: pip3 install oci-cli"
        fi
    fi

    # dbt Cloud CLI
    info "󰅟 Checking dbt Cloud CLI"
    if command_exists dbt; then
        ok "Already installed"
    else
        info " Installing dbt Cloud CLI..."
        brew install dbt-labs/dbt-cli/dbt-cloud-cli 2>/dev/null || \
            warn "dbt Cloud CLI brew install failed - try: pip3 install dbt-core"
    fi

    # Azure DevOps CLI extension
    info "󰅟 Checking Azure DevOps CLI extension"
    if az extension show --name azure-devops &>/dev/null 2>&1; then
        ok "Already installed"
    else
        info " Installing Azure DevOps extension for az CLI..."
        az extension add --name azure-devops
    fi
}

config_cloud() {
    info "󰅟 Cloud tools post-install steps"
    echo "    - Sign in to Azure CLI:       az login"
    echo "    - Sign in to AWS CLI:         aws configure"
    echo "    - Sign in to Snowflake CLI:   snow connection add"
    echo "    - Sign in to Databricks CLI:  databricks configure"
    echo "    - Sign in to OCI CLI:         oci setup config"
    echo "    - Sign in to dbt Cloud:       dbt cloud login"
}

install_data() {
    info "󰆼 Installing data tools"
    brew bundle --file="$SCRIPT_DIR/brewfiles/Brewfile.data"

    # SQLFluff
    info "󰆼 Checking SQLFluff"
    if command_exists sqlfluff; then
        ok "Already installed"
    else
        info " Installing SQLFluff via pipx..."
        if command_exists pipx; then
            pipx install sqlfluff
        elif command_exists pip3; then
            pip3 install --user sqlfluff
        else
            fail "pipx/pip3 not found - install Python first, then run: pipx install sqlfluff"
        fi
    fi

    # Playwright
    info "󰆼 Checking Playwright"
    if command_exists playwright; then
        ok "Already installed"
    else
        info " Installing Playwright via pipx..."
        if command_exists pipx; then
            pipx install playwright
        elif command_exists pip3; then
            pip3 install --user playwright
        else
            fail "pipx/pip3 not found - install Python first, then run: pipx install playwright"
        fi
    fi

    # Install Playwright browsers
    if command_exists playwright; then
        info "󰆼 Installing Playwright browsers"
        playwright install
        ok "Playwright browsers installed"
    fi

    # Oracle Instant Client
    info "󰆼 Checking Oracle Instant Client"
    if [ -d "/opt/oracle/instantclient" ] || [ -d "$HOME/instantclient" ] || ls /usr/local/lib/libclntsh* &>/dev/null 2>&1; then
        ok "Already installed"
    else
        warn "Oracle Instant Client not found"
        echo "    Download from: https://www.oracle.com/database/technologies/instant-client/macos-arm64-downloads.html"
        echo "    Install the Basic and SQL*Plus packages, then configure DBeaver:"
        echo "      DBeaver → Database → Driver Manager → Oracle → Libraries → Add Folder → select instantclient path"
    fi
}

config_data() {
    :
}

install_terminal() {
    info " Installing terminal tools"
    brew bundle --file="$SCRIPT_DIR/brewfiles/Brewfile.terminal"
}

config_terminal() {
    :
}

install_apps() {
    info " Installing desktop applications"
    local brewfile="$SCRIPT_DIR/brewfiles/Brewfile.apps"

    # Parse Brewfile into sections
    local fonts=() casks=() brews=() mas_items=()
    while IFS= read -r line; do
        # Skip comments and blank lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        # Strip inline comments
        local entry="${line%%#*}"
        entry="${entry%"${entry##*[![:space:]]}"}"  # trim trailing whitespace
        if [[ "$entry" =~ ^cask\ \"font- ]]; then
            fonts+=("$entry")
        elif [[ "$entry" =~ ^cask\  ]]; then
            casks+=("$entry")
        elif [[ "$entry" =~ ^brew\  ]]; then
            brews+=("$entry")
        elif [[ "$entry" =~ ^mas\  ]]; then
            mas_items+=("$entry")
        fi
    done < "$brewfile"

    local total=$(( ${#fonts[@]} + ${#casks[@]} + ${#brews[@]} + ${#mas_items[@]} ))
    local current=0

    # Install fonts
    if [[ ${#fonts[@]} -gt 0 ]]; then
        info " Fonts (${#fonts[@]} items)"
        for entry in "${fonts[@]}"; do
            current=$((current + 1))
            local name
            name=$(echo "$entry" | sed 's/.*"\(.*\)".*/\1/')
            printf "  [%d/%d] %s ... " "$current" "$total" "$name"
            if brew list --cask "$name" &>/dev/null 2>&1; then
                ok "already installed"
            else
                if brew install --cask "$name" &>/dev/null 2>&1; then
                    ok "installed"
                else
                    warn "failed"
                fi
            fi
        done
    fi

    # Install brew formulae
    if [[ ${#brews[@]} -gt 0 ]]; then
        info " Formulae (${#brews[@]} items)"
        for entry in "${brews[@]}"; do
            current=$((current + 1))
            local name
            name=$(echo "$entry" | sed 's/.*"\(.*\)".*/\1/')
            printf "  [%d/%d] %s ... " "$current" "$total" "$name"
            if brew list "$name" &>/dev/null 2>&1; then
                ok "already installed"
            else
                if brew install "$name" &>/dev/null 2>&1; then
                    ok "installed"
                else
                    warn "failed"
                fi
            fi
        done
    fi

    # Install cask applications
    if [[ ${#casks[@]} -gt 0 ]]; then
        info " Applications (${#casks[@]} items)"
        for entry in "${casks[@]}"; do
            current=$((current + 1))
            local name
            name=$(echo "$entry" | sed 's/.*"\(.*\)".*/\1/')
            printf "  [%d/%d] %s ... " "$current" "$total" "$name"
            if brew list --cask "$name" &>/dev/null 2>&1; then
                ok "already installed"
            else
                if brew install --cask "$name" &>/dev/null 2>&1; then
                    ok "installed"
                else
                    warn "failed"
                fi
            fi
        done
    fi

    # Install Mac App Store apps
    if [[ ${#mas_items[@]} -gt 0 ]]; then
        info " Mac App Store (${#mas_items[@]} items)"
        if command_exists mas; then
            for entry in "${mas_items[@]}"; do
                current=$((current + 1))
                local id name
                id=$(echo "$entry" | sed 's/.*id:[[:space:]]*\([0-9]*\).*/\1/')
                name=$(echo "$entry" | sed 's/mas "\(.*\)",.*/\1/')
                printf "  [%d/%d] %s (id: %s) ... " "$current" "$total" "$name" "$id"
                if mas list | grep -q "^$id "; then
                    ok "already installed"
                else
                    if mas install "$id" &>/dev/null 2>&1; then
                        ok "installed"
                    else
                        warn "failed"
                    fi
                fi
            done
        else
            warn "mas CLI not found - install brew formulae first, then re-run"
        fi
    fi

    ok "Apps: $current/$total processed"
}

config_apps() {
    # cmux
    info " Configuring cmux"
    defaults write com.cmuxterm.app appearanceMode -string "dark"
    defaults write com.cmuxterm.app appIconMode -string "dark"
    defaults write com.cmuxterm.app appLanguage -string "system"
    # Sidebar
    defaults write com.cmuxterm.app sidebarActiveTabIndicatorStyle -string "solidFill"
    defaults write com.cmuxterm.app sidebarPreset -string "nativeSidebar"
    defaults write com.cmuxterm.app sidebarMaterial -string "sidebar"
    defaults write com.cmuxterm.app sidebarBlendMode -string "withinWindow"
    defaults write com.cmuxterm.app sidebarBlurOpacity -integer 1
    defaults write com.cmuxterm.app sidebarTintHex -string "#000000"
    defaults write com.cmuxterm.app sidebarTintOpacity -string "0.18"
    defaults write com.cmuxterm.app sidebarCornerRadius -integer 0
    defaults write com.cmuxterm.app sidebarHideAllDetails -bool false
    defaults write com.cmuxterm.app sidebarState -string "followWindow"
    ok "cmux: sidebar configured (solid fill, native preset, dark)"
    # Notifications
    defaults write com.cmuxterm.app notificationSound -string "Hero"
    defaults write com.cmuxterm.app notificationPaneRingEnabled -bool false
    ok "cmux: notifications configured (Hero sound, ring disabled)"
    # Browser
    defaults write com.cmuxterm.app browserThemeMode -string "system"
    defaults write com.cmuxterm.app browserOpenSidebarPullRequestLinksInCmuxBrowser -bool false
    ok "cmux: browser configured (system theme)"
}

install_ai() {
    info "󰧑 Installing AI tools"
    brew bundle --file="$SCRIPT_DIR/brewfiles/Brewfile.ai"

    # Cortex Code CLI (npm)
    info "󰧑 Checking Cortex Code CLI"
    if command_exists cortex; then
        ok "Already installed"
    else
        info " Installing Cortex Code CLI via npm..."
        if command_exists npm; then
            npm install -g @snowflake-labs/cortex-cli || warn "Failed to install Cortex Code CLI"
        else
            fail "npm not found - install Node.js first, then run: npm install -g @snowflake-labs/cortex-cli"
        fi
    fi

    # Claude Code (npm)
    info "󰧑 Checking Claude Code"
    if command_exists claude; then
        ok "Already installed"
    else
        info " Installing Claude Code via npm..."
        if command_exists npm; then
            npm install -g @anthropic-ai/claude-code
        else
            fail "npm not found - install Node.js first, then run: npm install -g @anthropic-ai/claude-code"
        fi
    fi

    # MCP Servers (npm)
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

    info "󰧑 Checking MCP servers"
    if command_exists npm; then
        for server in "${MCP_SERVERS[@]}"; do
            if npm list -g "$server" &>/dev/null; then
                ok "$server already installed"
            else
                info " Installing $server..."
                npm install -g "$server" || warn "Failed to install $server"
            fi
        done
    else
        fail "npm not found - install Node.js first, then re-run to install MCP servers"
    fi

    # AI-related VS Code extensions
    AI_VSCODE_EXTENSIONS=(
        "snowflake.cortex-code"
        "saoudrizwan.claude-dev"
        "github.copilot"
        "github.copilot-chat"
        "continue.continue"
    )

    info "󰧑 Installing AI VS Code extensions"
    if command_exists code; then
        INSTALLED_EXTENSIONS=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
        for ext in "${AI_VSCODE_EXTENSIONS[@]}"; do
            ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
            if echo "$INSTALLED_EXTENSIONS" | grep -q "$ext_lower"; then
                ok "$ext already installed"
            else
                info " Installing $ext..."
                code --install-extension "$ext" || warn "Failed to install $ext"
            fi
        done
    else
        warn "VS Code CLI not found - install AI extensions manually from VS Code marketplace"
    fi
}

config_ai() {
    :
}

install_vscode() {
    VSCODE_EXTENSIONS=(
        # Python / Data Science
        "ms-python.python"
        "ms-python.vscode-pylance"
        "ms-python.black-formatter"
        "ms-python.debugpy"
        "ms-python.vscode-python-envs"
        "ms-toolsai.jupyter"
        "ms-toolsai.jupyter-keymap"
        "ms-toolsai.jupyter-renderers"
        "ms-toolsai.vscode-jupyter-cell-tags"
        "ms-toolsai.vscode-jupyter-slideshow"

        # SQL / Data
        "mtxr.sqltools"
        "randomfractalsinc.duckdb-sql-tools"
        "dorzey.vscode-sqlfluff"
        "mechatroner.rainbow-csv"
        "mohsen1.prettify-json"
        "redhat.vscode-yaml"
        "innoverio.vscode-dbt-power-user"

        # Cloud / Containers
        "ms-azuretools.vscode-docker"
        "ms-azuretools.vscode-containers"
        "ms-vscode-remote.remote-containers"
        "ms-kubernetes-tools.vscode-kubernetes-tools"
        "ms-vscode.azure-account"
        "amazonwebservices.aws-toolkit-vscode"

        # SQL Server / MSSQL
        "ms-mssql.mssql"
        "ms-mssql.data-workspace-vscode"
        "ms-mssql.sql-bindings-vscode"
        "ms-mssql.sql-database-projects-vscode"

        # Git
        "github.vscode-pull-request-github"
        "eamodio.gitlens"

        # General Development
        "esbenp.prettier-vscode"
        "oderwat.indent-rainbow"
        "ms-vscode.powershell"
        "visualstudioexptteam.vscodeintellicode"
        "visualstudioexptteam.intellicode-api-usage-examples"

        # Qlik
        "gimly81.qlik"
        "q-masters.vscode-qlik"
        "vinzent.qlikanswers"

        # Themes
        "github.github-vscode-theme"
        "hyzeta.vscode-theme-github-light"
        "rokoroku.vscode-theme-darcula"
        "gerane.theme-solarized-light"
        "jamiewest.theme-light-vs-mac"
        "crazyfluff.bettermaterialthemedarkerhighcontrast"
        "PKief.material-icon-theme"
        "catppuccin.catppuccin-vsc"
    )

    info "󰨞 Installing VS Code extensions"
    if command_exists code; then
        INSTALLED_EXTENSIONS=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
        for ext in "${VSCODE_EXTENSIONS[@]}"; do
            ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
            if echo "$INSTALLED_EXTENSIONS" | grep -q "$ext_lower"; then
                ok "$ext already installed"
            else
                info " Installing $ext..."
                code --install-extension "$ext" || warn "Failed to install $ext"
            fi
        done
    else
        warn "VS Code CLI not found - install extensions manually from VS Code marketplace"
    fi
}

config_vscode() {
    :
}

install_config() {
    :
}

config_config() {
    info " Configuring macOS preferences"

    # Dock
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.8
    defaults write com.apple.dock tilesize -int 34
    ok "Dock: auto-hide on, no delay, icon size 34"

    # Menu bar clock
    defaults write com.apple.menuextra.clock ShowAMPM -bool true
    defaults write com.apple.menuextra.clock ShowDate -int 0
    defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
    ok "Menu bar: clock shows AM/PM and day of week"

    # Control Center
    defaults write com.apple.controlcenter "NSStatusItem VisibleCC Battery" -bool true
    defaults write com.apple.controlcenter "NSStatusItem VisibleCC WiFi" -bool true
    ok "Menu bar: battery and Wi-Fi visible"

    # Appearance
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
    ok "Appearance: dark mode with auto-switch"

    # Finder
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    ok "Finder: show extensions, path bar, status bar, list view"

    # Text input
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
    ok "Text input: auto-correct, auto-capitalize, and period substitution off"

    # Hot corners
    defaults write com.apple.dock wvous-tl-corner -int 13
    defaults write com.apple.dock wvous-tl-modifier -int 524288
    defaults write com.apple.dock wvous-tr-corner -int 2
    defaults write com.apple.dock wvous-tr-modifier -int 0
    defaults write com.apple.dock wvous-bl-corner -int 4
    defaults write com.apple.dock wvous-bl-modifier -int 0
    defaults write com.apple.dock wvous-br-corner -int 14
    defaults write com.apple.dock wvous-br-modifier -int 524288
    ok "Hot corners: TL=Lock Screen(Opt), TR=Mission Control, BL=Desktop, BR=Quick Note(Opt)"

    # Mission Control
    defaults write com.apple.dock expose-animation-duration -float 0.1
    defaults write com.apple.dock showAppExposeGestureEnabled -bool true
    ok "Mission Control: fast animation, app exposé gesture on"

    # Screenshots
    mkdir -p "$HOME/Pictures/Screenshots"
    defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
    defaults write com.apple.screencapture type -string "png"
    ok "Screenshots: PNG format, saved to ~/Pictures/Screenshots"

    # AeroSpace config
    info " Installing AeroSpace config"
    if [ -f "$HOME/.aerospace.toml" ]; then
        warn "~/.aerospace.toml already exists - skipping (check $SCRIPT_DIR/aerospace.toml for reference)"
    else
        cp "$SCRIPT_DIR/aerospace.toml" "$HOME/.aerospace.toml"
        ok "Copied aerospace.toml to ~/.aerospace.toml"
    fi

    # Sketchybar config
    info " Installing Sketchybar config"
    mkdir -p "$HOME/.config/sketchybar/plugins"
    if [ -f "$HOME/.config/sketchybar/sketchybarrc" ]; then
        warn "~/.config/sketchybar/sketchybarrc already exists - skipping (check $SCRIPT_DIR/dotfiles/sketchybar/ for reference)"
    else
        cp "$SCRIPT_DIR/dotfiles/sketchybar/sketchybarrc" "$HOME/.config/sketchybar/sketchybarrc"
        cp "$SCRIPT_DIR/dotfiles/sketchybar/plugins/"* "$HOME/.config/sketchybar/plugins/"
        chmod +x "$HOME/.config/sketchybar/plugins/"*
        ok "Copied sketchybar config to ~/.config/sketchybar/"
    fi

    # Borders config
    info " Installing JankyBorders config"
    mkdir -p "$HOME/.config/borders"
    if [ -f "$HOME/.config/borders/bordersrc" ]; then
        warn "~/.config/borders/bordersrc already exists - skipping (check $SCRIPT_DIR/dotfiles/borders/bordersrc for reference)"
    else
        cp "$SCRIPT_DIR/dotfiles/borders/bordersrc" "$HOME/.config/borders/bordersrc"
        chmod +x "$HOME/.config/borders/bordersrc"
        ok "Copied bordersrc to ~/.config/borders/"
    fi

    # btop config
    info " Installing btop config"
    mkdir -p "$HOME/.config/btop"
    if [ -f "$HOME/.config/btop/btop.conf" ]; then
        warn "~/.config/btop/btop.conf already exists - skipping (check $SCRIPT_DIR/dotfiles/btop/btop.conf for reference)"
    else
        cp "$SCRIPT_DIR/dotfiles/btop/btop.conf" "$HOME/.config/btop/btop.conf"
        ok "Copied btop.conf to ~/.config/btop/"
    fi

    # Skitty-notes (Neovim sticky notes via linkarzu/dotfiles-latest)
    info " Installing skitty-notes (neobean Neovim config)"
    if [ -d "$HOME/.config/linkarzu/dotfiles-latest" ]; then
        warn "~/.config/linkarzu/dotfiles-latest already exists - skipping"
    else
        mkdir -p "$HOME/.config/linkarzu"
        git clone https://github.com/linkarzu/dotfiles-latest.git "$HOME/.config/linkarzu/dotfiles-latest"
        ok "Cloned linkarzu/dotfiles-latest for skitty-notes"
    fi

    # Starship config
    info " Installing Starship config"
    mkdir -p "$HOME/.config"
    if [ -f "$HOME/.config/starship.toml" ]; then
        warn "~/.config/starship.toml already exists - skipping (check $SCRIPT_DIR/dotfiles/starship.toml for reference)"
    else
        cp "$SCRIPT_DIR/dotfiles/starship.toml" "$HOME/.config/starship.toml"
        ok "Copied starship.toml to ~/.config/starship.toml"
    fi

    # Ghostty config
    info " Installing Ghostty config"
    mkdir -p "$HOME/.config/ghostty"
    if [ -f "$HOME/.config/ghostty/config" ]; then
        warn "~/.config/ghostty/config already exists - skipping (check $SCRIPT_DIR/dotfiles/ghostty/config for reference)"
    else
        cp "$SCRIPT_DIR/dotfiles/ghostty/config" "$HOME/.config/ghostty/config"
        ok "Copied ghostty config to ~/.config/ghostty/config"
    fi

    # Zsh config
    info " Installing .zshrc"
    if [ -f "$HOME/.zshrc" ]; then
        warn "~/.zshrc already exists - skipping (check $SCRIPT_DIR/dotfiles/.zshrc for reference)"
    else
        cp "$SCRIPT_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
        ok "Copied .zshrc to ~/.zshrc"
    fi

    # Apply changes
    killall Dock
    killall Finder
    killall SystemUIServer 2>/dev/null || true
    ok "macOS preferences applied"
}

# ============================================================
# Main dispatcher
# ============================================================
info " Selected groups: ${SELECTED_GROUPS[*]}"
[[ "$DO_INSTALL" == true ]] && info " Mode: install" || true
[[ "$DO_CONFIG" == true ]] && info " Mode: config" || true

for group in "${SELECTED_GROUPS[@]}"; do
    if $DO_INSTALL; then
        "install_${group}"
    fi
    if $DO_CONFIG; then
        "config_${group}"
    fi
done

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
info " Done! Review any warnings above."
echo ""
