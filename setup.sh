#!/bin/bash
set -e

OS="$(uname -s)"
REPO_URL="git@github.com:schroneko/dotfiles.git"
REPO_PATH="github.com/schroneko/dotfiles"

if command -v ghq &>/dev/null; then
    DOTFILES_DIR="$(ghq root)/$REPO_PATH"
else
    DOTFILES_DIR="$HOME/ghq/$REPO_PATH"
fi

echo "=== Dotfiles Setup ==="
echo "OS: $OS"

if [[ "$OS" == "Darwin" ]]; then
    if ! xcode-select -p &>/dev/null; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "Press any key after installation completes..."
        read -n 1
    fi
fi

if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$OS" == "Darwin" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

if ! command -v stow &>/dev/null; then
    echo "Installing stow..."
    brew install stow
fi

if [[ "$OS" == "Linux" ]] && ! command -v zsh &>/dev/null; then
    echo "Installing zsh..."
    brew install zsh
fi

if command -v ghq &>/dev/null; then
    echo "Cloning dotfiles with ghq..."
    ghq get "$REPO_URL"
elif [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Cloning dotfiles..."
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists, pulling latest..."
    git -C "$DOTFILES_DIR" pull
fi

echo "Configuring git hooks..."
cd "$DOTFILES_DIR"
git config core.hooksPath .githooks

echo "Configuring git pull..."
git config pull.autostash true

echo "Linking dotfiles with stow..."
stow --no-folding --target="$HOME" .

if [[ "$OS" == "Darwin" ]]; then
    echo "Configuring LaunchAgent..."
    mkdir -p "$HOME/Library/LaunchAgents"
    launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.schroneko.dotfiles-sync.plist" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.schroneko.dotfiles-sync.plist"
    launchctl enable "gui/$(id -u)/com.schroneko.dotfiles-sync"
fi

echo "Installing packages from Brewfile..."
"$DOTFILES_DIR/scripts/dotfiles-sync.sh"

if command -v mise &>/dev/null; then
    echo "Installing Node.js via mise..."
    mise use -g node@lts
fi

echo ""
echo "=== Setup Complete ==="
echo "Restart your terminal or run: exec zsh"
