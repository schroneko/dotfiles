#! /bin/bash
set -eux
# EXEPATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)

## ========== Clone Repo ==========
if [ ! -d ~/dotfiles ]; then
  git clone git@github.com:schroneko/dotfiles.git
fi

## ========== Install Homebrew ==========
if [ ! -f /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

## ========== Brew Bundle ==========
brew upgrade
brew bundle --file "${EXEPATH}"/.Brewfile

## ========== Npm ==========
npm update -g npm
npm install -g $(cat "${EXEPATH}"/Npmfile)

## ========== Create Symbolic Links ==========
for file in .??*; do
    [ "$file" = ".git" ] && continue
    ln -snfv $EXEPATH/"$file" $HOME
done
ln -snfv "${EXEPATH}"/.vimrc $HOME
ln -snfv "${EXEPATH}"/.zshrc $HOME
ln -snfv "${EXEPATH}"/.Brewfile $HOME

