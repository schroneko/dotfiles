#! /bin/bash
set -eux
EXEPATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)

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

