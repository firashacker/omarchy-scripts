#!/usr/bin/env bash
#
# install-nautilus-open-terminal.sh
#
# Install nautilus-open-any-terminal (Nautilus "Open in Terminal" context
# entry) from Omarchy's repo, point it at kitty, and restart Nautilus.
#
# Safe to re-run: pacman --needed and gsettings sets are idempotent.

set -euo pipefail

TERMINAL="${NAUTILUS_TERMINAL:-kitty}"
NEW_TAB="${NAUTILUS_NEW_TAB:-true}"
SCHEMA="com.github.stunkymonkey.nautilus-open-any-terminal"

sudo pacman -S --needed nautilus-open-any-terminal

if ! gsettings list-keys "$SCHEMA" >/dev/null 2>&1; then
  sudo glib-compile-schemas /usr/share/glib-2.0/schemas
fi

gsettings set "$SCHEMA" terminal "$TERMINAL"
gsettings set "$SCHEMA" new-tab "$NEW_TAB"
gsettings set "$SCHEMA" keybindings '<Ctrl><Alt>t'

nautilus -q

echo "Nautilus 'Open in Terminal' installed ($TERMINAL)."
echo "Right-click a folder in Nautilus to use it (Ctrl+Alt+T works too)."