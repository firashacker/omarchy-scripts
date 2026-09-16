#!/usr/bin/env bash
# Apply the Omarchy tmux blend. Rerunnable: replaces the previously inserted block.
set -euo pipefail

CONF="${HOME}/.config/tmux/tmux.conf"
START="# Omarchy tmux user blend:start"
END="# Omarchy tmux user blend:end"

if [[ ! -f "$CONF" ]]; then
  echo "Error: $CONF not found." >&2
  exit 1
fi

backup="${CONF}.bak.$(date +%s)"
cp "$CONF" "$backup"
echo "Backed up tmux config to: $backup"

if grep -qF "$START" "$CONF"; then
  sed -i "/^${START}$/,/^${END}$/d" "$CONF"
  echo "Removed previously inserted block."
fi

cat >> "$CONF" <<'EOF'
# Omarchy tmux user blend:start
# TPM + plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'tmux-plugins/tmux-yank'

# Custom binds (override stock)
bind h split-window -h -c "#{pane_current_path}"
bind v split-window -v -c "#{pane_current_path}"
bind Escape kill-window
bind Q kill-pane
bind -n M-H previous-window
bind -n M-L next-window
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle

# TPM bootstrap (last)
run '~/.tmux/plugins/tpm/tpm'
# Omarchy tmux user blend:end
EOF

echo "Tmux blend written to: $CONF"

if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

if command -v omarchy >/dev/null 2>&1; then
  omarchy restart tmux
else
  tmux source-file "$CONF" 2>/dev/null || \
    echo "No running tmux session to reload; new sessions will pick up the config."
fi

echo "Done."
echo "Inside a running tmux session, press prefix + I (C-Space, then Shift+i) once to install plugins."
echo "Reload the config anytime with prefix + q (shows 'Configuration reloaded')."
