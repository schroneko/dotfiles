#!/bin/bash
set -e

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"

OS="$(uname -s)"
REPO_URL="git@github.com:schroneko/dotfiles.git"
REPO_PATH="github.com/schroneko/dotfiles"

if [[ "$OS" == "Darwin" && -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

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

if ! command -v ghq &>/dev/null; then
    echo "Installing ghq..."
    brew install ghq
    DOTFILES_DIR="$(ghq root)/$REPO_PATH"
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

launch_agent_path="$HOME/Library/LaunchAgents/com.schroneko.dotfiles-sync.plist"
if [[ -L "$launch_agent_path" ]]; then
    rm -f "$launch_agent_path"
fi

echo "Linking dotfiles with stow..."
stow --no-folding --target="$HOME" .

if [[ "$OS" == "Darwin" ]]; then
    echo "Configuring LaunchAgent..."
    mkdir -p "$HOME/Library/LaunchAgents"
    ln -sfn "$DOTFILES_DIR/Library/LaunchAgents/com.schroneko.dotfiles-sync.plist" "$launch_agent_path"

    if launchctl print "gui/$(id -u)" >/dev/null 2>&1; then
        launchctl bootout "gui/$(id -u)" "$launch_agent_path" 2>/dev/null || true
        if launchctl bootstrap "gui/$(id -u)" "$launch_agent_path"; then
            launchctl enable "gui/$(id -u)/com.schroneko.dotfiles-sync"
            launchctl kickstart -k "gui/$(id -u)/com.schroneko.dotfiles-sync"
        else
            echo "Warning: LaunchAgent bootstrap failed; run launchctl manually after login." >&2
        fi
    else
        echo "Warning: no GUI launchd domain available; skipping LaunchAgent bootstrap." >&2
    fi

    echo "Applying macOS defaults..."
    "$DOTFILES_DIR/scripts/macos-defaults.sh"
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
