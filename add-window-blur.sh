#!/usr/bin/env bash
#
# add-window-blur.sh
#
# Enable Hyprland window blur on Omarchy by overriding the stock
# decoration.blur (disabled by default) with a self-contained block appended
# to ~/.config/hypr/looknfeel.lua. User config files are loaded after Omarchy's
# defaults, so this override sticks without touching /usr/share/omarchy.
#
# Safe to re-run: the previous config is backed up and the block it manages is
# replaced rather than stacked. If Hyprland rejects the result it is rolled back.
#
# Usage:
#   add-window-blur.sh
#   BLUR_SIZE=4 BLUR_PASSES=2 XRAY=1 add-window-blur.sh

set -euo pipefail

CONFIG="${HOME}/.config/hypr/looknfeel.lua"
BEGIN="-- BEGIN omarchy-window-blur"
END="-- END omarchy-window-blur"

# Blur settings, override any value via the environment (see Hyprland wiki).
SIZE="${BLUR_SIZE:-6}"
PASSES="${BLUR_PASSES:-3}"
IGNORE_OPACITY="${BLUR_IGNORE_OPACITY:-false}"
XRAY="${XRAY:-false}"
NOISE="${BLUR_NOISE:-0.01}"
CONTRAST="${BLUR_CONTRAST:-0.9}"
BRIGHTNESS="${BLUR_BRIGHTNESS:-0.9}"
VIBRANCY="${BLUR_VIBRANCY:-0.2}"
VIBRANCY_DARKNESS="${BLUR_VIBRANCY_DARKNESS:-0.0}"

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "hyprctl not found; is this an Omarchy/Hyprland session?" >&2
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "Error: $CONFIG not found." >&2
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
-- Window blur (overrides Omarchy's stock decoration.blur, which disables it).
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = $SIZE,
      passes = $PASSES,
      ignore_opacity = $IGNORE_OPACITY,
      xray = $XRAY,
      noise = $NOISE,
      contrast = $CONTRAST,
      brightness = $BRIGHTNESS,
      vibrancy = $VIBRANCY,
      vibrancy_darkness = $VIBRANCY_DARKNESS,
    },
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

echo "Window blur enabled (size = $SIZE, passes = $PASSES)."
echo "Previous config backed up to: $backup"