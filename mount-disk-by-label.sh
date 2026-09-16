#!/usr/bin/env bash
# Add a partition by LABEL to /etc/fstab so it auto-mounts at boot, with
# nofail so the system boots even if the disk is absent.
set -euo pipefail

echo "Detected labels:"
lsblk -no LABEL | grep . | sort -u | sed 's/^/  /'
echo

read -rp "Disk label (e.g. Data): " label
label="${label//\"/}"

dev=""
while read -r line; do
  if [[ $line =~ NAME=\"([^\"]+)\"[[:space:]]+LABEL=\"(.*)\" ]]; then
    if [[ ${BASH_REMATCH[2]} == "$label" ]]; then
      dev="/dev/${BASH_REMATCH[1]}"
      break
    fi
  fi
done < <(lsblk -nP -o NAME,LABEL)

if [[ -z $dev ]]; then
  echo "Error: no device with label \"$label\" found." >&2
  exit 1
fi

fs_type=$(lsblk -no FSTYPE "$dev" | head -1)
if [[ -z $fs_type || $fs_type == crypto_LUKS ]]; then
  echo "Error: no mountable filesystem found on $dev." >&2
  exit 1
fi

read -rp "Mount point [${HOME}/Data]: " mount_point
mount_point="${mount_point/#\~/$HOME}"
mount_point="${mount_point:-${HOME}/Data}"
mkdir -p "$mount_point"

mount_fstab=$(printf '%s' "$mount_point" | sed 's/ /\\040/g')

entry="LABEL=\"${label}\"  ${mount_fstab}  ${fs_type}  defaults,nofail  0  0"

echo "Adding to /etc/fstab:"
printf '  %s\n' "$entry"
printf '%s\n' "$entry" | sudo tee -a /etc/fstab >/dev/null

sudo systemctl daemon-reload

echo "Trying to mount now..."
if sudo mount "$mount_point"; then
  echo "Mounted LABEL=\"$label\" ($dev) at $mount_point."
else
  echo "Mount failed (entry was still added; nofail means boot continues anyway)." >&2
  exit 1
fi