# CLAUDE.md

## Project: data-dev-tools

macOS setup automation for data engineering tools. Installs CLI tools, desktop apps, and cloud platform CLIs via a single script.

## Setup

```bash
./install.sh                      # Install + config everything
./install.sh cloud data           # Install + config specific groups
./install.sh cloud --install      # Only install cloud tools
./install.sh cloud --config       # Only run config for cloud
./install.sh --list               # Show available groups
```

## Groups

`cloud`, `data`, `terminal`, `apps`, `ai`, `vscode`, `config`

## Project Structure

- `install.sh` - Main install script with group-based modularity
- `Brewfile` - Aggregate Brewfile (sources all group files)
- `brewfiles/Brewfile.<group>` - Per-group Homebrew formulae and casks
- `aerospace.toml` - AeroSpace tiling window manager config
- `dotfiles/starship.toml` - Starship prompt config
- `dotfiles/ghostty/config` - Ghostty/cmux terminal config
- `dotfiles/.zshrc` - Zsh shell config
- `CLAUDE.md` - Project context for Claude Code

## How it works

1. Parses CLI args: group names + `--install`/`--config` flags
2. Installs Xcode Command Line Tools and Homebrew (always, as prerequisites)
3. For each selected group, runs `install_<group>()` and/or `config_<group>()`
4. Each install function runs `brew bundle` with its group Brewfile + any non-Homebrew installs
5. The `config` group handles macOS preferences, AeroSpace, Starship, Ghostty, and zsh configs

## Conventions

- Homebrew-installable tools go in `brewfiles/Brewfile.<group>`
- Non-Homebrew installs go in `install_<group>()` functions in `install.sh`
- Each install checks if already installed before attempting
- Install vs config logic is separated into `install_<group>()` and `config_<group>()` functions
- Script uses `set -euo pipefail` for safety
