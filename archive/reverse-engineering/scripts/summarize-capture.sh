#!/usr/bin/env sh
set -eu

input="${1:-}"
[ -n "$input" ] || {
  echo "usage: scripts/summarize-capture.sh captures/extracted/file.lengths.tsv" >&2
  exit 1
}
[ -f "$input" ] || {
  echo "not a file: $input" >&2
  exit 1
}

awk -F '\t' '
  NF >= 5 {
    frame=$1
    ep=$4
    len=$5 + 0
    packets++
    total += len
    ep_packets[ep]++
    ep_bytes[ep] += len
    if (ep == "0x82" && len >= 512) {
      large_packets++
      large_bytes += len
      if (first_large == "") first_large = frame
      last_large = frame
      large_len_count[len]++
    }
    len_count[len]++
  }
  END {
    print "packets\t" packets
    print "total_data_len\t" total
    print ""
    print "endpoint\tpackets\tbytes"
    for (ep in ep_packets) print ep "\t" ep_packets[ep] "\t" ep_bytes[ep]
    print ""
    print "large_in_packets_ge_512\t" large_packets
    print "large_in_bytes\t" large_bytes
    print "first_large_frame\t" first_large
    print "last_large_frame\t" last_large
    print ""
    print "large_in_lengths\tcount"
    for (len in large_len_count) print len "\t" large_len_count[len]
  }
' "$input"
