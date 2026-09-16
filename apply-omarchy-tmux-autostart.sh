#!/usr/bin/env bash
# Make every interactive terminal start inside tmux. Rerunnable: replaces the
# previously inserted block in ~/.bashrc.
set -euo pipefail

BASHRC="${HOME}/.bashrc"
START="# Omarchy tmux autostart:start"
END="# Omarchy tmux autostart:end"

if [[ ! -f "$BASHRC" ]]; then
  echo "Error: $BASHRC not found." >&2
  exit 1
fi

backup="${BASHRC}.bak.$(date +%s)"
cp "$BASHRC" "$backup"
echo "Backed up bashrc to: $backup"

if grep -qF "$START" "$BASHRC"; then
  sed -i "/^${START}$/,/^${END}$/d" "$BASHRC"
  echo "Removed previously inserted block."
fi

cat >> "$BASHRC" <<'EOF'
# Omarchy tmux autostart:start
# Start a fresh tmux session in every new terminal (each window gets its own
# session). Skip when already inside tmux or tmux is unavailable.
if [[ -z "${TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new
fi
# Omarchy tmux autostart:end
EOF

echo "Tmux autostart block appended to: $BASHRC"

echo "Done. Open a new terminal to start a fresh tmux session (each terminal gets its own)."
echo "If tmux ever fails to start, remove the block between '$START' and '$END' in $BASHRC (or run with a backup restored)."