# Global settings
global_settings=(
  "ApplePressAndHoldEnabled -bool false"
  "AppleShowAllExtensions -bool true"
  "AppleShowAllFiles -bool true"
  "InitialKeyRepeat -int 15"
  "KeyRepeat -int 2"
  "WebKitDeveloperExtras -bool true"
  "com.apple.trackpad.scaling 2"
  ".GlobalPreferences NSAutomaticCapitalizationEnabled -bool false"
)

# App-specific settings
app_settings=(
  "com.apple.AppleMultitouchTrackpad Clicking -bool true"
  "com.apple.LaunchServices LSQuarantine -bool false"
  "com.apple.Safari IncludeDevelopMenu -bool true"
  "com.apple.Safari InstallExtensionUpdatesAutomatically -bool true"
  "com.apple.Safari ShowFullURLInSmartSearchField -bool true"
  "com.apple.Safari ShowStatusBar -bool true"
  "com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true"
  "com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true"
  "com.apple.desktopservices DSDontWriteNetworkStores -bool true"
  "com.apple.desktopservices DSDontWriteUSBStores -bool true"
  "com.apple.dock autohide -bool true"
  "com.apple.dock orientation -string 'left'"
  "com.apple.dock show-recents -bool false"
  "com.apple.dock static-only -bool true"
  "com.apple.finder ShowPathbar -bool true"
  "com.apple.finder WarnOnEmptyTrash -bool false"
)

# Apply global settings
for setting in "${global_settings[@]}"; do
  defaults write -g $setting
done

# Apply app-specific settings
for setting in "${app_settings[@]}"; do
  defaults write $setting
done

# Disable startup sound
sudo nvram SystemAudioVolume=" "
