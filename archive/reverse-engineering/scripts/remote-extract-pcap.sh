#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

need_cmd ssh
need_remote_host
need_cmd scp

pcap="${1:-}"
[ -n "$pcap" ] || die "usage: scripts/remote-extract-pcap.sh captures/raw/file.pcapng"
[ -f "$pcap" ] || die "not a file: $pcap"

mkdir -p "$CAPTURE_ROOT/extracted"
stem=$(basename "$pcap")
stem=${stem%.pcapng}
remote_pcap="/tmp/f3200-extract-$stem.pcapng"
remote_small="/tmp/f3200-extract-$stem.small.tsv"
remote_lengths="/tmp/f3200-extract-$stem.lengths.tsv"
small="$CAPTURE_ROOT/extracted/$stem.small.tsv"
lengths="$CAPTURE_ROOT/extracted/$stem.lengths.tsv"

safe_capture_path "$small"
safe_capture_path "$lengths"

scp "$pcap" "$REMOTE_HOST:$remote_pcap"

ssh "$REMOTE_HOST" "
  set -eu
  filter='usb.endpoint_address == $SCANNER_OUT_EP || usb.endpoint_address == $SCANNER_IN_EP'
  tshark -r '$remote_pcap' -Y \"\$filter\" -T fields \
    -e frame.number \
    -e frame.time_relative \
    -e usb.endpoint_address.direction \
    -e usb.endpoint_address \
    -e usb.data_len \
    -e usb.capdata >'$remote_small'
  tshark -r '$remote_pcap' -Y \"\$filter\" -T fields \
    -e frame.number \
    -e frame.time_relative \
    -e usb.endpoint_address.direction \
    -e usb.endpoint_address \
    -e usb.data_len >'$remote_lengths'
  wc -l '$remote_small' '$remote_lengths'
"

scp "$REMOTE_HOST:$remote_small" "$small"
scp "$REMOTE_HOST:$remote_lengths" "$lengths"

printf 'saved: %s\n' "$small"
printf 'saved: %s\n' "$lengths"
