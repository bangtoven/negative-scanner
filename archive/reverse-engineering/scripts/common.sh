#!/usr/bin/env sh
set -eu

REMOTE_HOST="${F3200_REMOTE_HOST:-}"
USBMON_IFACE="${F3200_USBMON_IFACE:-usbmon2}"
SCANNER_USB_ID="${F3200_SCANNER_USB_ID:-04b8:080a}"
SCANNER_OUT_EP="${F3200_SCANNER_OUT_EP:-0x01}"
SCANNER_IN_EP="${F3200_SCANNER_IN_EP:-0x82}"
REMOTE_STATE="${F3200_REMOTE_STATE:-/tmp/f3200-usbmon-capture.env}"
CAPTURE_ROOT="${F3200_CAPTURE_ROOT:-captures}"

timestamp() {
  date '+%Y%m%d-%H%M%S'
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

need_remote_host() {
  [ -n "$REMOTE_HOST" ] || die "set F3200_REMOTE_HOST, for example user@host"
}

safe_capture_path() {
  path="$1"
  [ ! -e "$path" ] || die "refusing to overwrite existing file: $path"
}
