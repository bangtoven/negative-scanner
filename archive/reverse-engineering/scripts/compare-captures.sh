#!/usr/bin/env sh
set -eu

if [ "$#" -lt 2 ]; then
  echo "usage: scripts/compare-captures.sh a.small.tsv b.small.tsv [more.small.tsv...]" >&2
  exit 1
fi

tmp="${TMPDIR:-/tmp}/f3200-compare-$$.tsv"
body="${TMPDIR:-/tmp}/f3200-compare-body-$$.tsv"
trap 'rm -f "$tmp" "$body"' EXIT INT TERM

for f in "$@"; do
  [ -f "$f" ] || {
    echo "not a file: $f" >&2
    exit 1
  }
  awk -F '\t' -v file="$f" '
    NF >= 6 && $4 == "0x01" {
      print file "\tOUT\t" $5 "\t" $6
    }
    NF >= 6 && $4 == "0x82" && $5 + 0 <= 64 {
      print file "\tIN\t" $5 "\t" $6
    }
  ' "$f" >>"$tmp"
done

awk -F '\t' '
  {
    key=$2 "\t" $3 "\t" $4
    files[key]=files[key] $1 "\n"
    count[key]++
  }
  END {
    for (key in count) {
      print key "\t" count[key]
    }
  }
' "$tmp" | sort -k1,1 -k2,2n -k4,4 >"$body"

printf 'direction\tlen\thex\tcount\n'
cat "$body"
