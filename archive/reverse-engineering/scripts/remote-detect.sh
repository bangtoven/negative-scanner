#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

need_cmd ssh
need_remote_host

ssh "$REMOTE_HOST" "
  set -eu
  echo host=\$(hostname)
  echo user=\$(id -un)
  echo scanner_usb_id=$SCANNER_USB_ID
  echo
  echo '[lsusb]'
  lsusb | grep -i '$SCANNER_USB_ID' || true
  echo
  echo '[tools]'
  for c in lsusb tshark dumpcap scanimage sane-find-scanner; do
    if command -v \"\$c\" >/dev/null 2>&1; then
      echo \"\$c: \$(command -v \"\$c\")\"
    else
      echo \"\$c: missing\"
    fi
  done
  echo
  echo '[sudo checks]'
  sudo -n modprobe usbmon >/dev/null 2>&1 && echo 'modprobe usbmon: ok' || echo 'modprobe usbmon: denied'
  sudo -n tshark -D >/dev/null 2>&1 && echo 'sudo tshark: ok' || echo 'sudo tshark: denied'
  [ -r /sys/kernel/debug/usb/usbmon/2u ] && echo 'usbmon2 debugfs: readable' || echo 'usbmon2 debugfs: not readable'
"
