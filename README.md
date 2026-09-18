# omarchy-scripts

Personal, rerunnable configuration scripts for [Omarchy](https://omarchy.org/) — the
modern Arch Linux distribution built on Hyprland and Quickshell.

These scripts turn configuration changes into repeatable migrations: each one
backs up the current config, applies a clearly marked block of changes, and can
be re-run at any time to replace the block with an updated version. No manual
tweaking of config files required.

## Scripts

| Script | What it does |
| ------ | ------------ |
| `add-arabic-layout.sh` | Adds an Arabic keyboard layout (`us,ara`, switched with `Alt+Shift`) via a guarded block in `~/.config/hypr/input.lua`, reloads and validates with `hyprctl`, and rolls back if Hyprland rejects the config. |
| `allow-root-gui.sh` | Installs `xorg-xhost` if missing and enables root-run GUI apps to display by adding `xhost +local:` to the Hyprland autostart. |
| `apply-omarchy-keybindings.sh` | Remaps Hyprland keybindings (main menu → `SUPER+A`, close window → `SUPER+Q`, browser → `SUPER+W`, thunar → `SUPER+F`, fullscreen → `SUPER+SHIFT+F`, scratchpad reshuffle, floating terminal on `SUPER+SHIFT+RETURN`, system menu → `SUPER+X`, capture menu → `SUPER+S`, floating toggle → `SUPER+SPACE`, theme menu → `SUPER+T`) and validates with `hyprctl reload` + `hyprctl configerrors`. |
| `apply-omarchy-tmux.sh` | Blends a custom tmux setup into `~/.config/tmux/tmux.conf`: TPM + plugins (tmux-sensible, vim-tmux-navigator, tmux-yank), extra bindings, and pane/window behaviour — all on top of Omarchy's stock theming. |
| `apply-omarchy-tmux-autostart.sh` | Makes every new terminal start its own fresh tmux session by injecting a guarded block into `~/.bashrc` (skips nested shells automatically). |
| `install-helium-browser.sh` | Replaces the default Chromium with `helium-browser-bin` from the AUR and sets it as the default browser. |
| `mount-disk-by-label.sh` | Prompts for a disk's label, verifies a device with that label exists, and adds a `LABEL="..."  defaults,nofail` entry to `/etc/fstab` with an optional mount test. |
| `omarchy-remove-preinstalls` | Removes preinstalled Omarchy web apps and desktop applications. |
| `omarchy-webapp-remove-all` | Removes all installed web-app launchers. |
| `tmux.conf` | The blended reference tmux configuration (the target of `apply-omarchy-tmux.sh`). |

## Usage

Each script is self-contained and safe to re-run:

```bash
./add-arabic-layout.sh
./allow-root-gui.sh
./apply-omarchy-keybindings.sh
./apply-omarchy-tmux.sh
./apply-omarchy-tmux-autostart.sh
./install-helium-browser.sh
```

What every script does for you:

1. **Backs up** the current config to a timestamped `.bak` file before touching it.
2. **Appends** a block of changes delimited by `:start` / `:end` markers.
3. **Replaces on re-run** — edit the block inside the script and re-run to update
   the installed config cleanly, with no duplicates.
4. Picky scripts **validate** the result (e.g. `hyprctl configerrors`) and print
   any post-apply steps you need to take.

## Editing the applied changes

To adjust a migration, open the corresponding script, edit the Lua/tmux/bash
block between its markers, and re-run it. The previous block is stripped and the
new one installed in its place.

## Requirements

- An Omarchy installation (for the keybinding and tmux scripts)
- `hyprctl` for keybinding and layout validation
- `yay` for installing AUR packages (`install-helium-browser.sh`)
- `xorg-xhost` for `allow-root-gui.sh` (installed automatically if missing)
- TPM is installed automatically by `apply-omarchy-tmux.sh`

## Notes

- These scripts modify only user-level config (`~/.config/`, `~/.bashrc`); they
  never touch `/usr/share/omarchy/`.
- Because the installed changes live in marker-delimited blocks, re-running a
  script always produces a single clean block — no duplicate bindings, no
  acccumulated commented-out experiments.