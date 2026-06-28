#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

need_cmd ssh
need_remote_host
need_cmd scp

device="${1:-}"
label="sane-config-only-$(timestamp)"
remote_pcap="/tmp/f3200-${label}.pcapng"
remote_log="/tmp/f3200-${label}.log"
local_pcap="$CAPTURE_ROOT/raw/f3200-${label}.pcapng"
local_log="$CAPTURE_ROOT/raw/f3200-${label}.log"

mkdir -p "$CAPTURE_ROOT/raw"
safe_capture_path "$local_pcap"
safe_capture_path "$local_log"

ssh "$REMOTE_HOST" "
  set -eu
  sudo -n modprobe usbmon
  nohup sudo -n tshark -i '$USBMON_IFACE' -w '$remote_pcap' >'$remote_log' 2>&1 &
  pid=\$!
  sleep 1
  scanimage -L || true
  if [ -n '$device' ]; then
    scanimage -d '$device' -A || true
  else
    scanimage -A || true
  fi
  kill -INT \"\$pid\" >/dev/null 2>&1 || true
  sleep 2
  ls -lh '$remote_pcap'
  echo '$remote_pcap'
"

scp "$REMOTE_HOST:$remote_pcap" "$local_pcap"
scp "$REMOTE_HOST:$remote_log" "$local_log" || true
shasum -a 256 "$local_pcap"
printf 'saved: %s\n' "$local_pcap"
