#!/bin/bash

# omarchy:summary=Remove default Chromium and install Helium Browser (AUR) as the default browser

set -e

if pacman -Q chromium &>/dev/null; then
  echo "Removing Chromium..."
  sudo pacman -Rns --noconfirm chromium
else
  echo "Chromium not installed, skipping removal."
fi

echo "Installing helium-browser-bin from the AUR..."
yay -S --noconfirm helium-browser-bin

echo "Setting Helium as the default browser..."
mkdir -p ~/.config/omarchy/defaults
printf '%s\n' "helium-browser" > ~/.config/omarchy/defaults/browser

echo "Done. Helium Browser is now the default."