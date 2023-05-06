## ========== Defaults Write ==========
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g AppleShowAllExtensions -bool true
defaults write -g AppleShowAllFiles -bool true
defaults write -g InitialKeyRepeat -int 12
defaults write -g KeyRepeat -int 1.5
defaults write -g WebKitDeveloperExtras -bool true
defaults write -g WebKitDeveloperExtras -bool true
defaults write -g com.apple.trackpad.scaling 2
defaults write .GlobalPreferences NSAutomaticCapitalizationEnabled -bool false
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.LaunchServices LSQuarantine -bool false
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
defaults write com.apple.Safari ShowStatusBar -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock static-only -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder WarnOnEmptyTrash -bool false


## ========== Change Capslock to Ctrl ==========
keyboard_id="$(ioreg -c AppleEmbeddedKeyboard -r | grep -Eiw "VendorID|ProductID" | awk '{ print $4 }' | paste -s -d'-\n' -)-0"
defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboard_id} -array-add "
<dict>
  <key>HIDKeyboardModifierMappingDst</key>\
  <integer>30064771300</integer>\
  <key>HIDKeyboardModifierMappingSrc</key>\
  <integer>30064771129</integer>\
</dict>
"

## ========== Disable Startup Sound ==========
sudo nvram SystemAudioVolume=" "

## ========== Cache Clear ==========
if ! ${TESTMODE}; then
  for app in \
    "cfprefsd" "Safari" \
    "Activity Monitor" "Address Book" "Calendar" \
    "Contacts" "Dock" "Finder" "Mail" "Messages" \
    "SystemUIServer" "Terminal" "Transmission" "iCal"; do
    killall "${app}"
  done
fi
