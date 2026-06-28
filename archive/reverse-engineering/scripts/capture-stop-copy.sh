#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

need_cmd ssh
need_remote_host
need_cmd scp

mkdir -p "$CAPTURE_ROOT/raw"

state=$(ssh "$REMOTE_HOST" "test -f '$REMOTE_STATE' && cat '$REMOTE_STATE' || true")
[ -n "$state" ] || die "no remote capture state found at $REMOTE_STATE"

pid=$(printf '%s\n' "$state" | sed -n 's/^PID=//p')
remote_pcap=$(printf '%s\n' "$state" | sed -n 's/^PCAP=//p')
remote_log=$(printf '%s\n' "$state" | sed -n 's/^LOG=//p')
[ -n "$pid" ] || die "remote state missing PID"
[ -n "$remote_pcap" ] || die "remote state missing PCAP"

ssh "$REMOTE_HOST" "
  set -eu
  if kill -0 '$pid' >/dev/null 2>&1; then
    kill -INT '$pid' >/dev/null 2>&1 || true
    sleep 2
  fi
  if kill -0 '$pid' >/dev/null 2>&1; then
    kill -TERM '$pid' >/dev/null 2>&1 || true
    sleep 1
  fi
  ls -lh '$remote_pcap'
"

base=$(basename "$remote_pcap")
local_pcap="$CAPTURE_ROOT/raw/$base"
safe_capture_path "$local_pcap"

if ! scp "$REMOTE_HOST:$remote_pcap" "$local_pcap"; then
  ssh "$REMOTE_HOST" "sudo -n cat '$remote_pcap'" >"$local_pcap"
fi

if [ -n "$remote_log" ]; then
  local_log="$CAPTURE_ROOT/raw/$base.log"
  safe_capture_path "$local_log"
  if ! scp "$REMOTE_HOST:$remote_log" "$local_log"; then
    ssh "$REMOTE_HOST" "sudo -n cat '$remote_log'" >"$local_log" || true
  fi
fi

ssh "$REMOTE_HOST" "rm -f '$REMOTE_STATE'" >/dev/null 2>&1 || true

shasum -a 256 "$local_pcap"
printf 'saved: %s\n' "$local_pcap"
