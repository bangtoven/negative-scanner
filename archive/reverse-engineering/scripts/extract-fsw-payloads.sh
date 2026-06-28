#!/usr/bin/env sh
set -eu

small="${1:-}"
[ -n "$small" ] || {
  echo "usage: scripts/extract-fsw-payloads.sh captures/extracted/file.small.tsv" >&2
  exit 1
}
[ -f "$small" ] || {
  echo "not a file: $small" >&2
  exit 1
}

awk -F '\t' '
  NF >= 6 {
    frame=$1
    ep=$4
    len=$5 + 0
    data=$6

    if (expect_payload && ep == "0x01" && len == 64) {
      print command_frame "\t" frame "\t" data
      expect_payload=0
      next
    }

    if (ep == "0x01" && len == 2 && data == "1c57") {
      command_frame=frame
      expect_payload=1
      next
    }
  }
' "$small"
