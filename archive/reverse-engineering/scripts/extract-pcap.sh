#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

need_cmd tshark

pcap="${1:-}"
[ -n "$pcap" ] || die "usage: scripts/extract-pcap.sh captures/raw/file.pcapng"
[ -f "$pcap" ] || die "not a file: $pcap"

mkdir -p "$CAPTURE_ROOT/extracted"
stem=$(basename "$pcap")
stem=${stem%.pcapng}

small="$CAPTURE_ROOT/extracted/$stem.small.tsv"
lengths="$CAPTURE_ROOT/extracted/$stem.lengths.tsv"
safe_capture_path "$small"
safe_capture_path "$lengths"

filter="usb.endpoint_address == $SCANNER_OUT_EP || usb.endpoint_address == $SCANNER_IN_EP"

tshark -r "$pcap" -Y "$filter" -T fields \
  -e frame.number \
  -e frame.time_relative \
  -e usb.endpoint_address.direction \
  -e usb.endpoint_address \
  -e usb.data_len \
  -e usb.capdata >"$small"

tshark -r "$pcap" -Y "$filter" -T fields \
  -e frame.number \
  -e frame.time_relative \
  -e usb.endpoint_address.direction \
  -e usb.endpoint_address \
  -e usb.data_len >"$lengths"

wc -l "$small" "$lengths"
