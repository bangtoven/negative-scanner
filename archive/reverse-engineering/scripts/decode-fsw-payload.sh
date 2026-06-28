#!/usr/bin/env sh
set -eu

hex="${1:-}"
if [ -z "$hex" ]; then
  read -r hex
fi

if [ -z "$hex" ]; then
  echo "usage: scripts/decode-fsw-payload.sh <128-hex-byte-payload>" >&2
  echo "   or: scripts/extract-fsw-payloads.sh file.small.tsv | awk '{print \$3}' | scripts/decode-fsw-payload.sh" >&2
  exit 1
fi

case "$hex" in
  *[!0-9a-fA-F]*)
    echo "payload must be hex" >&2
    exit 1
    ;;
esac

[ ${#hex} -eq 128 ] || {
  echo "payload must be 64 bytes / 128 hex characters; got ${#hex}" >&2
  exit 1
}

perl -e '
  my $hex = shift;
  sub b { hex(substr($hex, $_[0] * 2, 2)) }
  sub le32 {
    my ($off) = @_;
    return b($off) | (b($off+1) << 8) | (b($off+2) << 16) | (b($off+3) << 24);
  }
  my @fields = (
    [0,  "u32", "resolution_main"],
    [4,  "u32", "resolution_sub"],
    [8,  "u32", "offset_main"],
    [12, "u32", "offset_sub"],
    [16, "u32", "scan_length_main"],
    [20, "u32", "scan_length_sub"],
    [24, "u8",  "scanning_color"],
    [25, "u8",  "data_format_depth"],
    [26, "u8",  "option_control"],
    [27, "u8",  "scanning_mode"],
    [28, "u8",  "block_line_number"],
    [29, "u8",  "gamma_correction"],
    [30, "u8",  "brightness"],
    [31, "u8",  "color_correction"],
    [32, "u8",  "halftone_processing"],
    [33, "u8",  "threshold"],
    [34, "u8",  "auto_area_segmentation"],
    [35, "u8",  "sharpness_control"],
    [36, "u8",  "mirroring"],
    [37, "u8",  "film_type"],
    [38, "u8",  "main_lamp_lighting_mode"],
  );
  print "offset\tfield\tvalue\n";
  for my $f (@fields) {
    my ($off, $type, $name) = @$f;
    my $value = $type eq "u32" ? le32($off) : b($off);
    print "$off\t$name\t$value\n";
  }
' "$hex"
