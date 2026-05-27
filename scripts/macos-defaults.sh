#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Skipping macOS defaults: unsupported OS"
    exit 0
fi

dry_run=0

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            dry_run=1
            ;;
        *)
            echo "Usage: $0 [--dry-run]" >&2
            exit 2
            ;;
    esac
done

run() {
    if (( dry_run )); then
        printf '+'
        printf ' %q' "$@"
        printf '\n'
        return 0
    fi

    "$@"
}

run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
run defaults write NSGlobalDomain InitialKeyRepeat -int 15
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
run defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
run defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
run defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
run defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

run defaults write com.apple.finder AppleShowAllFiles -bool true
run defaults write com.apple.finder FXDefaultSearchScope -string SCcf
run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
run defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
run defaults write com.apple.finder NewWindowTarget -string PfHm
run defaults write com.apple.finder ShowPathbar -bool true
run defaults write com.apple.finder ShowStatusBar -bool true
run defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

run defaults write com.apple.dock autohide -bool true
run defaults write com.apple.dock expose-group-apps -bool true
run defaults write com.apple.dock mru-spaces -bool false
run defaults write com.apple.dock show-recents -bool false
run defaults write com.apple.dock tilesize -int 48

run defaults write com.apple.screencapture disable-shadow -bool true
run defaults write com.apple.screencapture show-thumbnail -bool false
run defaults write com.apple.screencapture type -string png

run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
run defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

run defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

if ! (( dry_run )); then
    killall Dock >/dev/null 2>&1 || true
    killall Finder >/dev/null 2>&1 || true
    killall SystemUIServer >/dev/null 2>&1 || true
fi
