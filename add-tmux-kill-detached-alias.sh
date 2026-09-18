#!/usr/bin/env bash
# Add a `tmux-kill-detached` alias to ~/.bashrc that kills all detached tmux
# sessions. Rerunnable: replaces the previously inserted block.
set -euo pipefail

BASHRC="${HOME}/.bashrc"
START="# Omarchy tmux-kill-detached alias:start"
END="# Omarchy tmux-kill-detached alias:end"

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
# Omarchy tmux-kill-detached alias:start
# Kill every tmux session with no attached client.
alias tmux-kill-detached='tmux list-sessions -F "#{session_name} #{session_attached}" 2>/dev/null | awk "\$2 == 0 {print \$1}" | xargs -r -n1 tmux kill-session -t'
# Omarchy tmux-kill-detached alias:end
EOF

echo "Alias added to: $BASHRC"
echo "Usage: source ~/.bashrc && tmux-kill-detached"