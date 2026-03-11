#!/usr/bin/env bash
set -euo pipefail

while pgrep -qf "brew (bundle|fetch|install|upgrade)"; do
    echo "Waiting for another brew process to finish..."
    sleep 5
done

brew update
brew upgrade --greedy
brew autoremove
brew doctor
brew cleanup
