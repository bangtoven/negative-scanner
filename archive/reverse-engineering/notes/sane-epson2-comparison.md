# SANE epson2 Comparison

SANE upstream was cloned into:

- `sane-backends`

Relevant files:

- `sane-backends/backend/epson2-commands.c`
- `sane-backends/backend/epson2-ops.c`
- `sane-backends/backend/epson2_usb.c`
- `sane-backends/backend/epson2.h`
- `sane-backends/doc/descriptions/epson2.desc`

## F-3200 Support Status

`doc/descriptions/epson2.desc` lists:

```text
model: F-3200
interface: USB IEEE1394
usbid: 0x04b8 0x080a
status: unsupported
comment: Film scanner
```

`tools/epson2usb.pl` skips devices whose status is `:unsupported`, so `backend/epson2_usb.c` does not include product ID `0x080a` in the generated USB product list.

## Protocol Match

The captured VueScan traffic matches SANE `epson2` extended ESC/I commands:

- `1c46` = `FS F`, request scanner status.
- `1c57` = `FS W`, set scanning parameter.
- `1c47` = `FS G`, start extended scan and get block layout.

`epson2-commands.c` defines `esci_set_scanning_parameter()` as:

1. send `FS W`
2. send a 64-byte parameter block

This exactly matches the captured sequence:

```text
OUT 1c57
IN  06
OUT <64-byte block>
IN  06
```

## FS W 64-byte Field Map

SANE logs the `FS W` block as:

```text
offset  size  field
0       u32   resolution of main scan
4       u32   resolution of sub scan
8       u32   offset length of main scan
12      u32   offset length of sub scan
16      u32   scanning length of main scan
20      u32   scanning length of sub scan
24      u8    scanning color
25      u8    data format
26      u8    option control
27      u8    scanning mode
28      u8    block line number
29      u8    gamma correction
30      u8    brightness
31      u8    color correction
32      u8    halftone processing
33      u8    threshold
34      u8    auto area segmentation
35      u8    sharpness control
36      u8    mirroring
37      u8    film type
38      u8    main lamp lighting mode
```

This confirms the earlier capture-derived hypotheses:

- Offsets `0` and `4` are x/y resolution.
- Offsets `8` and `12` are x/y crop offsets.
- Offsets `16` and `20` are width/height-like scan dimensions.
- Offset `28` is the block line count, not an image geometry value.

## FS G Block Layout

`epson2-ops.c:e2_start_ext_scan()` sends `FS G` and reads 14 bytes:

```text
buf[0]      STX
buf[1]      status
buf[2..5]   block size, little-endian u32
buf[6..9]   block count, little-endian u32
buf[10..13] last block size, little-endian u32
```

This matches captured examples such as:

```text
0292000000000000000000000000
```

Decoded:

- STX: `0x02`
- status: `0x92`
- block size: `0`
- block count: `0`
- last block size: `0`

The status byte needs more investigation; VueScan nevertheless proceeds to read image data after this exchange.

## Image Data Read Model

For extended commands, SANE reads:

```text
block_size + 1
```

The extra byte is an end-of-block status byte. SANE sends an ACK before every next block except the last one.

This matches VueScan captures where large IN image blocks are followed by small OUT `06` ACK packets.

## Comparison With Captures

### 400 dpi full preview

Payload:

```text
9001000090010000000000000000000090060000700f000000100101080300000000000000000000000000000000000000000000000000000000000000000000
```

Decoded:

```text
resolution_main      400
resolution_sub       400
offset_main          0
offset_sub           0
scan_length_main     1680
scan_length_sub      3952
scanning_color       0
data_format_depth    16
option_control       1
scanning_mode        1
block_line_number    8
gamma_correction     3
```

### 200/400/800 dpi

Resolution fields:

```text
offset 0: 200 / 400 / 800
offset 4: 200 / 400 / 800
```

Scan dimensions:

```text
main length: 840 / 1680 / 3368
sub length:  1976 / 3952 / 7904
```

### 400 dpi cropped preview

Manual area:

```text
x=1.2mm y=4.5mm width=78.9mm height=98.9mm
```

Payload:

```text
90010000900100001300000047000000d804000016060000001001010c0300000000000000000000000000000000000000000000000000000000000000000000
```

Decoded:

```text
resolution_main      400
resolution_sub       400
offset_main          19
offset_sub           71
scan_length_main     1240
scan_length_sub      1558
block_line_number    12
```

The values align with SANE's mm-to-pixel formula:

```text
value = round(mm / 25.4 * dpi)
```

Examples:

- `1.2 / 25.4 * 400 = 18.9`, captured `19`.
- `4.5 / 25.4 * 400 = 70.9`, captured `71`.
- `98.9 / 25.4 * 400 = 1557.5`, captured `1558`.

The captured main length `1240` is lower than the direct rounded width calculation for `78.9mm` at 400 dpi (`1243`). This likely reflects scanner/backend alignment, VueScan crop adjustment, or 8-pixel rounding.

## Implications

The F-3200 is not using a mysterious unrelated protocol for the observed preview path. It is using the same extended ESC/I `FS W` and `FS G` structure implemented by SANE `epson2`.

## 8-bit Gray Check

Changing only VueScan Bits per pixel from `16 bit Gray` to `8 bit Gray` on the same 400 dpi cropped preview changed only two `FS W` bytes:

```text
offset  16gray  8gray
25      10      08
28      0c      1a
```

Decoded:

- Offset `25`, `data format`, changed from `16` to `8`.
- Offset `28`, `block line number`, changed from `12` to `26`.
- Resolution, crop offsets, and scan lengths stayed identical.

The image payload dropped from `3863970` large IN bytes to `1931980`, almost exactly half, matching the expected 16-bit to 8-bit gray transition.

This validates SANE's `data format` and `block line number` mapping for this F-3200 preview path.

## Media Setting Check

Changing VueScan Media from `B/W negative` to `Slide film` while keeping the same 16-bit gray cropped preview produced an identical `FS W` block and identical large IN image byte count.

Observed:

```text
FS W payload: identical
large IN bytes: 3863970 in both captures
large IN pattern: 130 x 16384, 129 x 13377, 1 x 8417 in both captures
```

Implication:

- The VueScan Media setting did not map to `FS W` field `film type` in this preview case.
- It may be handled by VueScan post-processing, or another command outside the `FS W` scan parameter block.

## 24-bit RGB / Color Negative Check

Changing to VueScan Media `Color negative` and Bits per pixel `24 bit RGB` on the same 400 dpi cropped preview produced:

```text
scanning_color      19
data_format_depth   8
block_line_number   8
film_type           1
```

Compared to 16-bit B/W negative:

```text
offset  16gray_bwneg  24rgb_colorneg
24      00            13
25      10            08
28      0c            08
37      00            01
```

Compared to 8-bit gray:

```text
offset  8gray  24rgb
24      00     13
28      1a     08
37      00     01
```

Implications:

- `scanning_color` value `0x13` indicates RGB/color mode for this extended ESC/I path.
- `data_format_depth` remains `8`, consistent with 24-bit RGB being 8 bits per channel.
- `film_type` value `1` is used for Color negative in this capture.
- Large IN bytes are about 3x the 8-bit gray crop, matching RGB channel count.

The project should now shift from broad protocol discovery to targeted validation:

- Confirm exact rounding/alignment of main scan length.
- Confirm color mode fields.
- Confirm positive/negative film type field.
- Decode actual image payload layout from captured pcap before sending any commands.

No USB replay or handcrafted command transmission is needed yet.
