#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

need_cmd ssh
need_remote_host

label="${1:-vuescan}"
case "$label" in
  *[!A-Za-z0-9._-]*|'') die "label must contain only A-Z, a-z, 0-9, dot, underscore, or dash" ;;
esac

name="${label}-$(timestamp)"
remote_pcap="/tmp/f3200-${name}.pcapng"
remote_log="/tmp/f3200-${name}.tshark.log"

ssh "$REMOTE_HOST" "
  set -eu
  sudo -n modprobe usbmon
  if [ -f '$REMOTE_STATE' ]; then
    old_pid=\$(sed -n 's/^PID=//p' '$REMOTE_STATE' || true)
    if [ -n \"\$old_pid\" ] && kill -0 \"\$old_pid\" >/dev/null 2>&1; then
      echo 'capture already running: pid='\$old_pid >&2
      exit 1
    fi
  fi
  nohup sudo -n tshark -i '$USBMON_IFACE' -w '$remote_pcap' >'$remote_log' 2>&1 &
  pid=\$!
  printf 'PID=%s\nPCAP=%s\nLOG=%s\nSTARTED=%s\n' \"\$pid\" '$remote_pcap' '$remote_log' \"\$(date -Is)\" >'$REMOTE_STATE'
  cat '$REMOTE_STATE'
"

printf '\nStarted remote capture. Perform the controlled VueScan action, then run:\n'
printf '  scripts/capture-stop-copy.sh\n'
