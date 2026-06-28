# SANE Backend Investigation

SANE `epson2` contains useful Epson protocol concepts, but F-3200 is currently not treated as supported.

Known findings:

- `epson2.desc` lists F-3200 / `04b8:080a` as unsupported.
- `epson2_usb.c` skips unsupported devices.
- `epson2-commands.c` already documents the observed `FS W` 64-byte scanning parameter block.
- See `archive/reverse-engineering/notes/sane-epson2-comparison.md` for the field-level comparison against VueScan captures.

Current use of SANE must be config-only:

- `scanimage -L`
- `scanimage -A`

Use `scripts/sane-epson2-temp-test.sh` to run these with a temporary `epson2` config containing:

```text
usb 0x04b8 0x080a
```

First test result:

- `scanimage -L` with temporary config reached `epson2`.
- It failed at USB open with `Device busy`.
- `fuser` showed VueScan PID `3699` holding `/dev/bus/usb/002/007`.

Next SANE test requires closing VueScan first.

## Config Override Result

After VueScan was closed, temporary `epson2` config with `usb 0x04b8 0x080a` worked.

`scanimage -L` result:

```text
device `epson2:libusb:002:007' is a Epson F-3200 flatbed scanner
```

`scanimage -A` also succeeded and exposed options including:

- `--mode Lineart|Gray|Color`
- `--resolution 100|400|1600|3200dpi`
- `--preview`
- geometry `-l`, `-t`, `-x`, `-y`
- `--source Flatbed|Transparency Unit`
- `--film-type Positive Film|Negative Film|Positive Slide|Negative Slide` but inactive in the observed option listing

Important observed backend discovery values:

- Command level: `D8`
- Extended commands supported
- TPU detected
- TPU area: `0,0 106.933990,250.951996 mm`
- Highest available resolution: `3200`
- Model: `F-3200`
- SANE reported maximum supported color depth as `8`, despite VueScan successfully using 16-bit gray in captures.

## First Actual SANE Preview Scan

Command shape:

```sh
SANE_CONFIG_DIR=/tmp/f3200-sane-test/sane.d \
scanimage -d epson2:libusb:002:007 \
  --source "Transparency Unit" \
  --mode Gray \
  --resolution 400 \
  --preview=yes \
  -l 1.2 -t 4.5 -x 78.9 -y 98.9 \
  > /tmp/f3200-sane-preview-gray8-400dpi-crop-x1.2-y4.5-w78.9-h98.9.pnm
```

Result:

```text
/tmp/f3200-sane-preview-gray8-400dpi-crop-x1.2-y4.5-w78.9-h98.9.pnm:
Netpbm image data, size = 1240 x 1557, rawbits, greymap
```

Mac archive:

- `scans/sane/f3200-sane-preview-gray8-400dpi-crop-x1.2-y4.5-w78.9-h98.9.pnm`
- `captures/raw/f3200-sane-preview-gray8-400dpi-transparency-crop-x1.2-y4.5-w78.9-h98.9-20260627-191625.pcapng`
- `captures/extracted/f3200-sane-preview-gray8-400dpi-transparency-crop-x1.2-y4.5-w78.9-h98.9-20260627-191625.small.tsv`
- `captures/extracted/f3200-sane-preview-gray8-400dpi-transparency-crop-x1.2-y4.5-w78.9-h98.9-20260627-191625.lengths.tsv`

Endpoint summary:

```text
packets: 384
total_data_len: 1932590
0x82 IN: 200 packets, 1931627 bytes
0x01 OUT: 184 packets, 963 bytes
large IN bytes: 1930729
large IN pattern: 48 x 39681, 1 x 26041
```

`FS W` decoded:

```text
resolution_main      400
resolution_sub       400
offset_main          19
offset_sub           71
scan_length_main     1240
scan_length_sub      1557
scanning_color       0
data_format_depth    8
option_control       1
scanning_mode        1
block_line_number    32
gamma_correction     4
color_correction     1
threshold            128
```

Comparison to VueScan 8-bit gray cropped preview:

```text
offset  VueScan8  SANE8
20      16        15
28      1a        20
29      03        04
31      00        01
33      00        80
```

Key interpretation:

- SANE produced a valid image without any backend rebuild.
- Geometry is almost identical to VueScan; height is `1557` instead of VueScan's `1558`, matching the generated PNM height.
- SANE uses a larger block line number (`32`), so its USB reads are larger chunks (`39681` bytes) than VueScan's chunking.
- SANE default gamma/color-correction/threshold differ from VueScan.

Conclusion:

- The shortest path is now to use `epson2` with config support for `04b8:080a`, not to build a libusb dumper first.
- Minimum packaging patch is likely to mark F-3200 as supported enough to include product ID `0x080a`.
- Further backend work should focus on 16-bit support, film-type activation, and Mac/Homebrew packaging rather than basic protocol discovery.
