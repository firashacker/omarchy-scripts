#!/bin/bash

set -euo pipefail

LINE='o.launch_on_start('"'"'xhost +local:'"'"')'
AUTOSTART="$HOME/.config/hypr/autostart.lua"

if ! command -v xhost &>/dev/null; then
    sudo pacman -S --needed xorg-xhost
fi

if ! grep -qF 'xhost +local:' "$AUTOSTART"; then
    echo "$LINE" >> "$AUTOSTART"
fi

echo "Done!"