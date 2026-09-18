#!/usr/bin/env bash
#
# set-window-opacity.sh
#
# Ask the user for an opacity value for inactive windows (0.0 - 1.0) and apply
# it to Hyprland by appending a self-contained block to
# ~/.config/hypr/looknfeel.lua. Active windows stay at full opacity.
#
# Safe to re-run: the previous config is backed up and the block it manages is
# replaced rather than stacked. If Hyprland rejects the result it is rolled back.

set -euo pipefail

CONFIG="${HOME}/.config/hypr/looknfeel.lua"
BEGIN="-- BEGIN omarchy-window-opacity"
END="-- END omarchy-window-opacity"
ACTIVE_OPACITY="${ACTIVE_OPACITY:-1.0}"

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "hyprctl not found; is this an Omarchy/Hyprland session?" >&2
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "Error: $CONFIG not found." >&2
  exit 1
fi

inactive="${INACTIVE_OPACITY:-}"
if [[ -z "$inactive" ]]; then
  read -rp "Inactive window opacity (0.0 - 1.0, e.g. 0.85): " inactive
fi

if ! [[ "$inactive" =~ ^[0-9]+([.][0-9]+)?$ ]] || \
   awk -v v="$inactive" 'BEGIN{ exit (v >= 0 && v <= 1) }'; then
  echo "Error: \"$inactive\" is not a number between 0.0 and 1.0." >&2
  exit 1
fi

backup="${CONFIG}.bak.$(date +%s)"
cp "$CONFIG" "$backup"
echo "Backed up looknfeel config to: $backup"

# Drop any block this script installed before, so re-runs don't duplicate it.
tmp="$(mktemp)"
awk -v b="$BEGIN" -v e="$END" '
  index($0, b) { skip = 1 }
  !skip { print }
  index($0, e) { skip = 0 }
' "$CONFIG" > "$tmp"
mv "$tmp" "$CONFIG"

cat >> "$CONFIG" <<LUA

$BEGIN
-- Window opacity: active stays at $ACTIVE_OPACITY, inactive at $inactive.
hl.config({
  decoration = {
    active_opacity = $ACTIVE_OPACITY,
    inactive_opacity = $inactive,
  },
})
$END
LUA

hyprctl reload >/dev/null

if errors="$(hyprctl configerrors)" && [[ -n "$errors" ]]; then
  echo "Hyprland rejected the config:" >&2
  printf '%s\n' "$errors" >&2
  cp "$backup" "$CONFIG"
  hyprctl reload >/dev/null
  echo "Rolled back to $backup" >&2
  exit 1
fi

echo "Inactive window opacity set to $inactive (active = $ACTIVE_OPACITY)."
echo "Previous config backed up to: $backup"