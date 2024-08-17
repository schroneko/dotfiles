#!/bin/bash

# グローバル設定

# キーを押し続けたときに文字を繰り返さないようにする
defaults write -g ApplePressAndHoldEnabled -bool false

# すべてのファイル拡張子を表示
defaults write -g AppleShowAllExtensions -bool true

# 隠しファイルを表示
defaults write -g AppleShowAllFiles -bool true

# キーリピート開始までの時間を短縮
defaults write -g InitialKeyRepeat -int 15

# キーリピートの速度を上げる
defaults write -g KeyRepeat -int 2

# WebKitの開発者ツールを有効化
defaults write -g WebKitDeveloperExtras -bool true

# トラックパッドの速度を上げる
defaults write -g com.apple.trackpad.scaling 2

# 自動大文字化を無効にする
defaults write .GlobalPreferences NSAutomaticCapitalizationEnabled -bool false

# アプリ固有の設定

# トラックパッドのタップでクリックを有効化
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# ダウンロードしたアプリの警告を無効化
defaults write com.apple.LaunchServices LSQuarantine -bool false

# ネットワークドライブで.DS_Storeファイルを作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# USBドライブで.DS_Storeファイルを作成しない
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Dock関連の設定
# 自動的に隠す
defaults write com.apple.dock autohide -bool true

# 最近使用したアプリを表示しない
defaults write com.apple.dock show-recents -bool false

# 固定のアプリのみ表示
defaults write com.apple.dock static-only -bool true

# Dockのアプリをすべて削除
defaults write com.apple.dock persistent-apps -array

# Finder関連の設定
# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# ゴミ箱を空にする前の警告を無効化
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# 起動音を無効化
sudo nvram SystemAudioVolume=" "

# 設定の即時反映
killall Dock
killall Finder
killall SystemUIServer
killall "System Preferences"
