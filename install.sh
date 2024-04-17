#! /bin/zsh
set -eux

DOTFILES_DIR="$HOME/dotfiles"

[ "$(uname)" = "Darwin" ] || { echo "This script is for macOS!"; exit 1; }

if ! xcode-select -p &>/dev/null; then
  xcode-select --install &>/dev/null
fi

[ -d "$DOTFILES_DIR" ] || git clone git@github.com:schroneko/dotfiles.git "$DOTFILES_DIR"

cd "$DOTFILES_DIR"
for dotfile in .[^.]*; do
  [[ "$dotfile" == ".git" || "$dotfile" == ".DS_Store" ]] && continue
  [ -L "$HOME/$dotfile" ] && continue
  ln -snfv "$DOTFILES_DIR/$dotfile" "$HOME/$dotfile"
done

command -v brew &>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew bundle --global

[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
