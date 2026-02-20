#!/bin/bash
set -e

OS="$(uname -s)"
REPO_URL="https://github.com/schroneko/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

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

if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Cloning dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists, pulling latest..."
    git -C "$DOTFILES_DIR" pull
fi

echo "Configuring git hooks..."
cd "$DOTFILES_DIR"
git config core.hooksPath .githooks

echo "Linking dotfiles with stow..."
stow --no-folding .

echo "Installing packages from Brewfile..."
if [[ "$OS" == "Darwin" ]]; then
    brew bundle --global
else
    grep -v "^cask " ~/.Brewfile \
        | grep -v '"xcodegen"' \
        | grep -v '"mint"' \
        | brew bundle --file=-
fi

if command -v volta &>/dev/null; then
    echo "Installing global npm packages via Volta..."
    volta install textlint
    npm install -g textlint-rule-ja-space-between-half-and-full-width textlint-rule-no-space-between-full-width
fi

echo ""
echo "=== Setup Complete ==="
echo "Restart your terminal or run: exec zsh"
