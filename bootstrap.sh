#!/bin/sh

RESET="\x1B[0m"
YELLOW="\x1b[33m"
DIM="\x1b[2m"
BRIGHT="\x1b[1m"

fancy_echo() {
  SECTION=$1; shift
  echo "\n ${BRIGHT}${RESET} ${DIM}[${RESET}${YELLOW}$SECTION${RESET}${DIM}]${RESET} ${BRIGHT}$@${RESET}\n"
}

set -e

# ****************************************************************************
# *                                 homebrew                                 *
# ****************************************************************************

fancy_echo homebrew configure
HOMEBREW_PREFIX="/usr/local"

if [ -d "$HOMEBREW_PREFIX" ]; then
  if ! [ -r "$HOMEBREW_PREFIX" ]; then
    sudo chown -R "$LOGNAME:admin" /usr/local
  fi
else
  sudo mkdir "$HOMEBREW_PREFIX"
  sudo chflags norestricted "$HOMEBREW_PREFIX"
  sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
fi

if ! command -v brew >/dev/null; then
  fancy_echo homebrew install
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    export PATH="/usr/local/bin:$PATH"
fi

fancy_echo homebrew update
brew update

fancy_echo homebrew brew
brew bundle --file=- <<EOF
cask_args appdir: "/Applications"

brew "ansible"
brew "autoconf"
brew "aws"
brew "git"
brew "go"
brew "m-cli"
brew "mas"
brew "openssl"
brew "rbenv"
brew "ruby-build"
brew "terraform"
brew "terraform-inventory"
brew "zsh"

cask "1password"
cask "adobe-photoshop-lightroom"
cask "alfred"
cask "appzapper"
cask "backblaze"
cask "boom"
cask "dropbox"
cask "firefox"
cask "flux"
cask "gitup"
cask "google-chrome"
cask "google-drive"
cask "google-photos-backup"
cask "handbrake"
cask "httpscoop"
cask "iterm2"
cask "nvalt"
cask "psequel"
cask "screenhero"
cask "sizeup"
cask "slack"
cask "spotify"
cask "sublime-text"
cask "things"
cask "wmail"

cask "font-hack"
EOF

# ****************************************************************************
# *                                    zsh                                   *
# ****************************************************************************

fancy_echo zsh chsh
chsh -s "$(which zsh)"

# ****************************************************************************
# *                                   xcode                                  *
# ****************************************************************************

fancy_echo xcode install

XCODE=`mas search xcode | grep "^[0-9]* Xcode$" | awk '{ print $1 }'`
mas install $XCODE
xcode-select --install

# ****************************************************************************
# *                                 dotfiles                                 *
# ****************************************************************************

fancy_echo dotfiles configure

if [ ! -d "/Users/filiptepper/.dotfiles" ]; then
  git clone git@github.com:filiptepper/dotfiles.git ~/.dotfiles
  cd ~/.dotfiles
  rake
fi

# ****************************************************************************
# *                               sublime-text                               *
# ****************************************************************************

fancy_echo sublime-text configure

if [ ! -f "/usr/local/bin/subl" ]; then
  ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin
fi

# ****************************************************************************
# *                                   macos                                  *
# ****************************************************************************

fancy_echo macos configure

# dock
defaults write com.apple.dock tilesize -int 16
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock dashboard-in-overlay -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string bottom

# dark menu bar
defaults write NSGlobalDomain AppleInterfaceStyle Dark

# hide menu bar
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# font smoothing
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# utf-8 in terminal
defaults write com.apple.terminal StringEncodings -array 4

# safari.app
# do not send data to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# show full address
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# default to about:blank
defaults write com.apple.Safari HomePage -string "about:blank"

# do not open downloads
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# browser back with backspace
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# show favorites bar
defaults write com.apple.Safari ShowFavoritesBar -bool true

# disable thumbnail cache
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# enable debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# remove icons in bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# develop menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# enable web inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# mail.app
# copy only e-mail address
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# do not display threads
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "no"

# spotlight
# do not index /Volumes
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

# default save local files to disk
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# disable dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# enable hidpi modes
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

# immediately ask for password
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1

# ctrl + scroll zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# full keyboard access
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# enable tap on login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# disable resume
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# do not terminate inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# do not ask if I want to run the app
defaults write com.apple.LaunchServices LSQuarantine -bool false

# expand save panel
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# expand print panel
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# quit printer app when printing is done
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# disable Photos opening on iPhone connection
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# check for update daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# show host details on login screen
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# disable animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g QLPanelAnimationDuration -float 0
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

# disable shadows in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# disable transparency
defaults write com.apple.universalaccess reduceTransparency -bool true
defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false

# disable boot sounds
sudo nvram SystemAudioVolume=" "

# disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# sizeup.app
defaults write com.irradiatedsoftware.SizeUp StartAtLogin -bool true
defaults write com.irradiatedsoftware.SizeUp ShowPrefsOnNextStart -bool false

# time machine.app
# don't ask for new drives
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# disable local time machine
hash tmutil &> /dev/null && sudo tmutil disablelocal

# finder.app
# default to desktop
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# do not show media on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# show path bar
defaults write com.apple.finder ShowPathbar -bool true

# show path in title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# do not warn when changing extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# search in current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# do not write .DS_Store to network stores
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# do not verify disk images
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# messages.app
# disable emoji
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# disable smart quotes
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

# disable spell checking
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

# always show ~/Library
chflags nohidden ~/Library

# always show /Volumes
sudo chflags nohidden /Volumes

# disable sleep
systemsetup -setcomputersleep Off > /dev/null

# disable hibernation
sudo pmset -a hibernatemode 0

if [ -f "/var/vm/sleepimage" ]; then
  sudo rm /var/vm/sleepimage
  sudo touch /private/var/vm/sleepimage
  sudo chflags uchg /private/var/vm/sleepimage
fi

# disable motion sensor for ssd
sudo pmset -a sms 0

# show following icons in the menu bar
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu"

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Google Chrome" "Google Chrome Canary" "Mail" "Messages" \
  "Opera" "Photos" "Safari" "SizeUp" "Spectacle" "SystemUIServer" "Terminal" \
  "Transmission" "Tweetbot" "Twitter" "iCal"; do
  killall "${app}" &> /dev/null
done

# ****************************************************************************
# *                                 security                                 *
# ****************************************************************************

sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
sudo pkill -HUP socketfilterfw
