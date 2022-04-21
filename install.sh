#! /bin/bash
set -eux

## ========== Dotfiles Path ==========
DOTPATH=$HOME/dotfiles

## ========== Not macOS ==========
if [ "$(uname)" != "Darwin" ] ; then
	echo "This Scripts is for macOS!"
	exit 1
fi

## ========== Clone Repo ==========
if [ ! -d $DOTPATH ]; then
  git clone https://github.com/schroneko/dotfiles $HOME/dotfiles
fi

## ========== Create Symbolic Links ==========
dotfiles=(.vimrc .zshrc .Brewfile)
for dotfile in ${dotfiles}; do
  ln -snfv $DOTPATH/$dotfile $HOME
done

## ========== Xcode ==========
xcode-select --install > /dev/null

## ========== Homebrew ==========
if [ ! -f /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

## ========== Brew Bundle ==========
brew bundle --global
brew update
brew upgrade
brew cleanup

