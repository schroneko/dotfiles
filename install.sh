#! /bin/zsh
set -eux

## ========== Dotfiles Path ==========
DOT_DIR=$HOME/dotfiles

## ========== Not macOS ==========
if [ "$(uname)" != "Darwin" ]; then
	echo "This Scripts is for macOS!"
	exit 1
fi

## ========== Clone Repo ==========
if [ ! -d $DOT_DIR ]; then
  git clone https://github.com/schroneko/dotfiles $HOME/dotfiles
fi

## ========== Create Symbolic Links ==========
if if [ ! -d ${DOT_DIR} ]; then
  cd $DOT_DIR
  for dotfile in .*; do
    [[ "$dotfile" == ".git" ]] && continue
    [[ "$dotfile" == ".DS_Store" ]] && continue
    ln -snfv $DOT_DIR/"$dotfile" $HOME/"$dotfile"
  done
fi

## ========== Xcode ==========
xcode-select --install >/dev/null 2>&1

## ========== Homebrew ==========
which brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

## ========== Source zshrc ==========
source $HOME/.zshrc

## ========== Brew Bundle ==========
brew bundle --global
