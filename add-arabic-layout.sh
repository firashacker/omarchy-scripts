#!/usr/bin/env bash
#
# add-arabic-layout.sh
#
# Add an Arabic keyboard layout to Omarchy, switchable from the US layout with
# Alt + Shift.
#
# It installs a small, self-contained override into ~/.config/hypr/input.lua,
# leaving the rest of that file untouched, then reloads and validates Hyprland.
# Safe to re-run: the previous config is backed up and the block it manages is
# replaced rather than stacked.
#
# Usage:
#   add-arabic-layout.sh
#   LAYOUT="us,ara" OPTIONS="grp:alt_shift_toggle" add-arabic-layout.sh

set -euo pipefail

LAYOUT="${LAYOUT:-us,ara}"
OPTIONS="${OPTIONS:-compose:caps,grp:alt_shift_toggle}"
CONFIG="${HOME}/.config/hypr/input.lua"
TEMPLATE="${OMARCHY_PATH:-/usr/share/omarchy}/config/hypr/input.lua"
BEGIN="-- BEGIN omarchy-arabic-layout"
END="-- END omarchy-arabic-layout"

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "hyprctl not found; is this an Omarchy/Hyprland session?" >&2
  exit 1
fi

mkdir -p "$(dirname "$CONFIG")"

# Start from Omarchy's template the first time so the reference comments stay.
if [[ ! -f "$CONFIG" && -f "$TEMPLATE" ]]; then
  cp "$TEMPLATE" "$CONFIG"
fi
touch "$CONFIG"

backup="${CONFIG}.bak.$(date +%s)"
cp "$CONFIG" "$backup"

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
-- US + Arabic, switched with Alt + Shift.
-- shift:both_capslock_cancel is deliberately omitted: it redefines the Shift
-- keys as [Shift, Caps_Lock] and overrides the ISO_Next_Group action that
-- grp:alt_shift_toggle relies on, which silently breaks the shortcut.
hl.config({
  input = {
    kb_layout = "$LAYOUT",
    kb_options = "$OPTIONS",
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

echo "Arabic layout installed (kb_layout = $LAYOUT)."
echo "Switch between US and Arabic with Alt + Shift."
echo "Previous config backed up to: $backup"
