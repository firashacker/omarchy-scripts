#!/usr/bin/env bash
set -euo pipefail

BINDINGS="${HOME}/.config/hypr/bindings.lua"
START_MARKER="-- omarchy-keybindings-applied:start"
END_MARKER="-- omarchy-keybindings-applied:end"
LEGACY_MARKER="-- omarchy-keybindings-applied"

if [[ ! -f "$BINDINGS" ]]; then
  echo "Error: $BINDINGS not found." >&2
  exit 1
fi

backup="${BINDINGS}.bak.$(date +%s)"
cp "$BINDINGS" "$backup"
echo "Backed up bindings to: $backup"

# Replace the previously inserted block (between the two markers), if present.
if grep -qF -- "$START_MARKER" "$BINDINGS"; then
  sed -i "/^${START_MARKER}$/,/^${END_MARKER}$/d" "$BINDINGS"
  echo "Removed previously inserted block."
fi
# Legacy single-marker block appended at EOF by an earlier script version.
if grep -qF -- "$LEGACY_MARKER" "$BINDINGS"; then
  sed -i "/^${LEGACY_MARKER}$/,\$d" "$BINDINGS"
  echo "Removed legacy block inserted at end of file."
fi

cat >> "$BINDINGS" <<'EOF'
-- omarchy-keybindings-applied:start
-- 1. Main menu: SUPER+SPACE -> SUPER+A
hl.unbind("SUPER + SPACE")
o.bind("SUPER + A", "Omarchy menu", "omarchy-menu toggle")

-- 2. Close window: SUPER+W -> SUPER+Q
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- 3. Browser on SUPER+W (was close window)
o.bind("SUPER + W", "Browser", { omarchy = "browser" })

-- 4. File manager: SUPER+F -> thunar (was full screen)
hl.unbind("SUPER + F")
o.bind("SUPER + F", "File manager", { launch = "thunar" })

-- 5. Full screen: SUPER+SHIFT+F (was file manager)
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- 6. Scratchpad reshuffle
hl.unbind("SUPER + S")
hl.unbind("SUPER + CTRL + S")
o.bind("SUPER + CTRL + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + SHIFT + CTRL + S", "Share", "omarchy-menu toggle share")
hl.unbind("SUPER + ALT + S")
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- 7. Floating terminal on SUPER+SHIFT+RETURN (was browser)
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Floating terminal", "setsid uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.terminal --title=Omarchy")

-- 8. System/power menu: SUPER+ESCAPE -> SUPER+X (was universal cut)
hl.unbind("SUPER + ESCAPE")
hl.unbind("SUPER + X")
o.bind("SUPER + X", "System menu", "omarchy-menu toggle system")

-- 9. Capture menu: SUPER+CTRL+C -> SUPER+S (was freed)
hl.unbind("SUPER + CTRL + C")
o.bind("SUPER + S", "Capture menu", "omarchy-menu toggle capture")

-- 10. Toggle floating: SUPER+T -> SUPER+SPACE; theme menu: SUPER+SHIFT+CTRL+SPACE -> SUPER+T
hl.unbind("SUPER + T")
hl.unbind("SUPER + SHIFT + CTRL + SPACE")
o.bind("SUPER + SPACE", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + T", "Theme menu", "omarchy-menu toggle theme")
-- omarchy-keybindings-applied:end
EOF

echo "Keybindings written to: $BINDINGS"

if command -v hyprctl >/dev/null 2>&1; then
  echo "--- hyprctl reload ---"
  hyprctl reload
  echo "--- hyprctl configerrors ---"
  hyprctl configerrors
else
  echo "Note: hyprctl not found; skipping reload. Changes apply on next login."
fi

sudo pacman -Sy thunar

echo "Done."
