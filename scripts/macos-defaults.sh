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

terminal_plist="$HOME/Library/Preferences/com.apple.Terminal.plist"
terminal_profile="$(defaults read com.apple.Terminal 'Default Window Settings' 2>/dev/null || printf 'Basic')"
terminal_keymap_path=":\"Window Settings\":\"${terminal_profile}\":keyMapBoundKeys"
terminal_ctrl_equal_sequence="$(printf '\033[61;5u')"
terminal_ctrl_equal_keys=('^003d' '^003D' '^3d' '^3D' '^0018' '^001B' '^001b' '^001D' '^001d' '$^002d' '$^002D' '^$002d' '^$002D' '$^2d' '$^2D' '^$2d' '^$2D' '$^001B' '$^001b' '^$001B' '^$001b' '^005f' '^005F' '$^005f' '$^005F' '^=' '$^-' '^$-' '^_' '$^_')

if (( dry_run )); then
    printf '+ %q %q %q %q\n' /usr/libexec/PlistBuddy -c "Add ${terminal_keymap_path} dict" "$terminal_plist"
    for terminal_ctrl_equal_key in "${terminal_ctrl_equal_keys[@]}"; do
        printf '+ %q %q %q %q\n' /usr/libexec/PlistBuddy -c "Delete ${terminal_keymap_path}:${terminal_ctrl_equal_key}" "$terminal_plist"
        printf '+ %q %q %q %q\n' /usr/libexec/PlistBuddy -c "Add ${terminal_keymap_path}:${terminal_ctrl_equal_key} string ${terminal_ctrl_equal_sequence}" "$terminal_plist"
    done
else
    if ! /usr/libexec/PlistBuddy -c "Print ${terminal_keymap_path}" "$terminal_plist" >/dev/null 2>&1; then
        /usr/libexec/PlistBuddy -c "Add ${terminal_keymap_path} dict" "$terminal_plist"
    fi
    for terminal_ctrl_equal_key in "${terminal_ctrl_equal_keys[@]}"; do
        /usr/libexec/PlistBuddy -c "Delete ${terminal_keymap_path}:${terminal_ctrl_equal_key}" "$terminal_plist" >/dev/null 2>&1 || true
        /usr/libexec/PlistBuddy -c "Add ${terminal_keymap_path}:${terminal_ctrl_equal_key} string ${terminal_ctrl_equal_sequence}" "$terminal_plist"
    done
    defaults import com.apple.Terminal "$terminal_plist"
    killall cfprefsd >/dev/null 2>&1 || true
fi

if ! (( dry_run )); then
    killall Dock >/dev/null 2>&1 || true
    killall Finder >/dev/null 2>&1 || true
    killall SystemUIServer >/dev/null 2>&1 || true
fi
