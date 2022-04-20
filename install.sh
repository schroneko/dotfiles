#! /bin/bash
set -eux
EXEPATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)

## ========== Brew Bundle ==========
brew upgrade
brew bundle --file "${EXEPATH}"/Brewfile

## ========== Npm ==========
npm update -g npm
npm install -g $(cat "${EXEPATH}"/Npmfile)
