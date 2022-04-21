## ========== Defaults Write ==========
defaults write -g ApplePressAndHoldEnabled -bool true
defaults write -g AppleShowAllFiles -bool true

## ========== Cache Clear ==========
if ! ${TESTMODE}; then
  for app in \
    "cfprefsd" \
    "Activity Monitor" "Address Book" "Calendar" \
    "Contacts" "Dock" "Finder" "Mail" "Messages" \
    "SystemUIServer" "Terminal" "Transmission" "iCal"; do
    killall "${app}"
  done
fi
