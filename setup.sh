#!/bin/bash
# Set up a Mac: Homebrew, this repo, config symlinks, macOS defaults, hourly sync.
#   setup.sh          full setup
#   setup.sh --link   only (re)create the config symlinks
set -euo pipefail

REPO_URL="git@github.com:schroneko/dotfiles.git"
DOTFILES="$HOME/ghq/github.com/schroneko/dotfiles"
AGENT="com.schroneko.dotfiles-sync"
LINKS=".zshrc .zshenv .gitconfig .ssh/config .config/nvim/init.lua .config/mise/config.toml Library/KeyBindings/DefaultKeyBinding.dict"

link_files() {
    local f
    for f in $LINKS; do
        mkdir -p "$(dirname "$HOME/$f")"
        if [[ -e "$HOME/$f" && ! -L "$HOME/$f" ]]; then
            mv "$HOME/$f" "$HOME/$f.before-dotfiles"
            echo "backed up ~/$f to ~/$f.before-dotfiles"
        fi
        ln -sfn "$DOTFILES/$f" "$HOME/$f"
    done
}

if [[ "${1:-}" == "--link" ]]; then link_files; exit 0; fi

if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    read -r -p "Press Enter after the Command Line Tools finish installing..."
fi
if [[ ! -x /opt/homebrew/bin/brew ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

if [[ -d "$DOTFILES/.git" ]]; then
    git -C "$DOTFILES" pull --rebase --autostash
else
    git clone "$REPO_URL" "$DOTFILES"
fi

link_files
"$DOTFILES/scripts/macos-defaults.sh"

plist="$HOME/Library/LaunchAgents/$AGENT.plist"
mkdir -p "$(dirname "$plist")"
cp "$DOTFILES/Library/LaunchAgents/$AGENT.plist" "$plist"
launchctl bootout "gui/$(id -u)/$AGENT" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$plist"
echo "Done. The first sync is running in the background (log: ~/Library/Logs/dotfiles-sync.log)."
echo "Restart your terminal or run: exec zsh"
