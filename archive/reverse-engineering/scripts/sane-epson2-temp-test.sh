#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

need_cmd ssh
need_remote_host

mode="${1:--L}"
case "$mode" in
  -L|-A) ;;
  *) die "usage: scripts/sane-epson2-temp-test.sh [-L|-A]" ;;
esac

ssh "$REMOTE_HOST" "
  set -eu
  d=/tmp/f3200-sane-test/sane.d
  mkdir -p \"\$d\"
  printf '%s\n' epson2 >\"\$d/dll.conf\"
  printf '%s\n' 'usb 0x04b8 0x080a' >\"\$d/epson2.conf\"
  echo '[temp sane config]'
  cat \"\$d/dll.conf\"
  cat \"\$d/epson2.conf\"
  echo
  echo '[VueScan/device users]'
  ps aux | grep -i '[v]uescan\\|[s]canimage\\|[s]aned' || true
  fuser -v /dev/bus/usb/002/007 2>&1 || true
  echo
  echo '[scanimage $mode]'
  if [ '$mode' = '-L' ]; then
    SANE_CONFIG_DIR=\"\$d\" SANE_DEBUG_EPSON2=5 scanimage -L 2>&1
  else
    device=\${F3200_SANE_DEVICE:-}
    if [ -z \"\$device\" ]; then
      device=\$(SANE_CONFIG_DIR=\"\$d\" scanimage -L 2>/dev/null | grep -o \"epson2:[^']*\" | head -1)
    fi
    if [ -z \"\$device\" ]; then
      echo 'no device found for -A' >&2
      exit 1
    fi
    SANE_CONFIG_DIR=\"\$d\" SANE_DEBUG_EPSON2=5 scanimage -d \"\$device\" -A 2>&1
  fi
"
