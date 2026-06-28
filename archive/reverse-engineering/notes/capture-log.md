# Capture Log

## 2026-06-27 - VueScan preview warm-up attempt

File:

- `captures/raw/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-baseline-20260627-181447.pcapng`

SHA-256:

- `671f3dc9b57d3113e3d36fc65db9a8fdf7229fb3e6fc5559f3be59d1a00c6965`

Observed UI/device state:

- VueScan Preview was pressed.
- Scanner displayed a warm-up state.
- VueScan showed `Preview...` with only a cancel button.
- VueScan later returned to the normal UI.
- Scanner was still warming afterward.

Interpretation:

- Treat this capture as a warm-up / preview-attempt capture, not as the manual baseline preview.
- The actual manual baseline preview should be captured after the scanner reaches a ready state.

## 2026-06-27 - VueScan manual ready baseline preview

File:

- `captures/raw/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-ready-baseline-20260627-181825.pcapng`

SHA-256:

- `3dffeeefec43fdf16e1e28e7dbbd26cf862e37c368c77402e1c95e5ddadd88c7`

Extracted:

- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-ready-baseline-20260627-181825.small.tsv`
- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-ready-baseline-20260627-181825.lengths.tsv`

VueScan settings:

- Action: Preview
- Media: B/W negative
- Preview area: Maximum
- Bits per pixel: 16 bit Gray
- Preview resolution: 400 dpi
- Scan resolution: 3200 dpi
- Number of samples: 1
- Manual/auto-reduced settings per user setup before capture

Endpoint summary:

- Endpoint-filtered packets: 3226
- Total endpoint data length: 13280925 bytes
- Endpoint `0x82`: 2108 packets, 13280238 bytes
- Endpoint `0x01`: 1118 packets, 687 bytes
- Large IN packets `>=512` bytes: 988
- Large IN bytes: 13279214
- First large frame: 252
- Last large frame: 3332
- Large IN pattern: 494 x `16384`, 494 x `10497`

`FS W` payload:

```text
command_frame=215 payload_frame=219
9001000090010000000000000000000090060000700f000000100101080300000000000000000000000000000000000000000000000000000000000000000000
```

## 2026-06-27 - VueScan manual ready baseline preview repeat

File:

- `captures/raw/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-ready-repeat-20260627-182350.pcapng`

SHA-256:

- `15627e3ccef4fafbcd0eb18161568c787ae4ee691f964e5051d1f27f6792baba`

Extracted:

- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-ready-repeat-20260627-182350.small.tsv`
- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-ready-repeat-20260627-182350.lengths.tsv`

VueScan settings:

- Same settings as ready baseline preview.
- User observed that Preview started immediately without warm-up.

Endpoint summary:

- Endpoint-filtered packets: 3198
- Total endpoint data length: 13280799 bytes
- Endpoint `0x82`: 2094 packets, 13280126 bytes
- Endpoint `0x01`: 1104 packets, 673 bytes
- Large IN packets `>=512` bytes: 988
- Large IN bytes: 13279214
- First large frame: 550
- Last large frame: 3620
- Large IN pattern: 494 x `16384`, 494 x `10497`

`FS W` payload:

```text
command_frame=513 payload_frame=517
9001000090010000000000000000000090060000700f000000100101080300000000000000000000000000000000000000000000000000000000000000000000
```

Comparison to ready baseline:

- `FS W` 64-byte payload is identical.
- Large IN byte total is identical: `13279214`.
- Large IN length pattern is identical: 494 pairs of `16384` and `10497`.
- Smaller packet count differences are likely pre-scan/status polling differences.

## 2026-06-27 - VueScan manual preview at 200 dpi

File:

- `captures/raw/f3200-vuescan-preview-bwneg-16gray-200dpi-manual-20260627-182646.pcapng`

SHA-256:

- `c5514c787a62f47c8eb90e11418cad5c308f3472a2017aa6ad305621f9dbc1f8`

Extracted:

- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-200dpi-manual-20260627-182646.small.tsv`
- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-200dpi-manual-20260627-182646.lengths.tsv`

VueScan settings:

- Same as ready baseline except Preview resolution changed from 400 dpi to 200 dpi.

Endpoint summary:

- Endpoint-filtered packets: 922
- Total endpoint data length: 3321117 bytes
- Endpoint `0x82`: 572 packets, 3320814 bytes
- Endpoint `0x01`: 350 packets, 303 bytes
- Large IN packets `>=512` bytes: 220
- Large IN bytes: 3319790
- First large frame: 410
- Last large frame: 1136
- Large IN pattern: 110 x `16384`, 109 x `13857`, 1 x `7137`

`FS W` payload:

```text
command_frame=373 payload_frame=377
c8000000c8000000000000000000000048030000b807000000100101120300000000000000000000000000000000000000000000000000000000000000000000000
```

Comparison to 400 dpi ready baseline:

```text
offset  400dpi  200dpi
0       90      c8
1       01      00
4       90      c8
5       01      00
16      90      48
17      06      03
20      70      b8
21      0f      07
28      08      12
```

Little-endian 16-bit candidates:

- Offset `0`: `0x0190` = 400, `0x00c8` = 200.
- Offset `4`: `0x0190` = 400, `0x00c8` = 200.
- Offset `16`: `0x0690` = 1680, `0x0348` = 840.
- Offset `20`: `0x0f70` = 3952, `0x07b8` = 1976.

The 200 dpi capture strongly suggests offsets `0` and `4` encode preview resolution or x/y resolution. Offsets `16` and `20` scale exactly with resolution and are likely image geometry or transfer dimensions.

## 2026-06-27 - VueScan manual preview at 800 dpi

File:

- `captures/raw/f3200-vuescan-preview-bwneg-16gray-800dpi-manual-20260627-182939.pcapng`

SHA-256:

- `6c7daec73e742e347efa17b2ed8e98afc05d139b3aa6879adae558921571ae3c`

Extracted:

- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-800dpi-manual-20260627-182939.small.tsv`
- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-800dpi-manual-20260627-182939.lengths.tsv`

VueScan settings:

- Same as ready baseline except Preview resolution changed to 800 dpi.

Endpoint summary:

- Endpoint-filtered packets: 12329
- Total endpoint data length: 53247451 bytes
- Endpoint `0x82`: 8141 packets, 53245176 bytes
- Endpoint `0x01`: 4188 packets, 2275 bytes
- Large IN packets `>=512` bytes: 3952
- Large IN bytes: 53243320
- First large frame: 544
- Last large frame: 12616
- Large IN pattern: 1976 x `16384`, 1976 x `10561`

`FS W` payload:

```text
command_frame=507 payload_frame=511
20030000200300000000000000000000280d0000e01e000000100101040300000000000000000000000000000000000000000000000000000000000000000000
```

Comparison across 200/400/800 dpi:

```text
offset  200dpi  400dpi  800dpi  LE16 values when read at offset
0       c8      90      20      200 / 400 / 800
1       00      01      03
4       c8      90      20      200 / 400 / 800
5       00      01      03
16      48      90      28      840 / 1680 / 3368
17      03      06      0d
20      b8      70      e0      1976 / 3952 / 7904
21      07      0f      1e
28      12      08      04
```

Working interpretation:

- Offsets `0` and `4` are strong x/y preview resolution candidates.
- Offset `20` is a strong geometry/line-count candidate because it scales exactly: `1976`, `3952`, `7904`.
- Offset `16` is also geometry-like, but 800 dpi is `3368`, not the exact double of `1680`; keep this as a dimension with alignment/crop/overscan behavior rather than a simple scale factor.
- Offset `28` decreases as resolution rises: `0x12`, `0x08`, `0x04`. It may be a mode, shift, packing, or remainder-related field.

## 2026-06-27 - VueScan manual area input attempt, reverted to maximum

File:

- `captures/raw/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-area-x34.5-y45.6-w78.9-h98.9-frame11-20260627-183858.pcapng`

SHA-256:

- `7adc7a111508feaa820479497801b8e80990fc5afd5114532c89fd6c61ad45f4`

Extracted:

- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-area-x34.5-y45.6-w78.9-h98.9-frame11-20260627-183858.small.tsv`
- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-area-x34.5-y45.6-w78.9-h98.9-frame11-20260627-183858.lengths.tsv`

VueScan settings attempted before preview:

- Preview area: Manual
- Preview X offset: `34.5`
- Preview Y offset: `45.6`
- Preview X size: `78.9`
- Preview Y size: `98.9`
- Frame number: `11`
- Preview resolution: 400 dpi
- Scan resolution: 3200 dpi

User observation after preview:

- VueScan changed Preview area back to full area: `0`, `0`, `106.9`, `251.0`.
- Treat this as a reverted/manual-area-failed capture, not a valid cropped-area preview.

Endpoint summary:

- Endpoint-filtered packets: 3358
- Total endpoint data length: 13281519 bytes
- Endpoint `0x82`: 2174 packets, 13280766 bytes
- Endpoint `0x01`: 1184 packets, 753 bytes
- Large IN packets `>=512` bytes: 988
- Large IN bytes: 13279214
- First large frame: 972
- Last large frame: 4052
- Large IN pattern: 494 x `16384`, 494 x `10497`

`FS W` payload:

```text
command_frame=935 payload_frame=939
9001000090010000000000000000000090060000700f000000100101080300000000000000000000000000000000000000000000000000000000000000000000
```

Comparison to 400 dpi ready baseline:

- `FS W` payload is identical.
- Large IN byte total is identical: `13279214`.
- Large IN pattern is identical: 494 pairs of `16384` and `10497`.
- Conclusion: the attempted manual preview area was not reflected in the scanner command.

## 2026-06-27 - VueScan manual area preview, reflected in scan

File:

- `captures/raw/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-20260627-184234.pcapng`

SHA-256:

- `1c2861d51373cee30ba8098910f20a4ed336eef50c4063fd551684e53750ab4a`

Extracted:

- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-20260627-184234.small.tsv`
- `captures/extracted/f3200-vuescan-preview-bwneg-16gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-20260627-184234.lengths.tsv`

VueScan settings:

- Preview area: Manual
- Preview X offset: `1.2`
- Preview Y offset: `4.5`
- Preview X size: `78.9`
- Preview Y size: `98.9`
- Preview resolution: 400 dpi
- Scan resolution: 3200 dpi

User observation:

- VueScan did not revert the area to full size.
- Scanner previewed only a smaller region.

Endpoint summary:

- Endpoint-filtered packets: 1018
- Total endpoint data length: 3865209 bytes
- Endpoint `0x82`: 640 packets, 3864898 bytes
- Endpoint `0x01`: 378 packets, 311 bytes
- Large IN packets `>=512` bytes: 260
- Large IN bytes: 3863970
- First large frame: 1502
- Last large frame: 2318
- Large IN pattern: 130 x `16384`, 129 x `13377`, 1 x `8417`

`FS W` payload:

```text
command_frame=1455 payload_frame=1459
90010000900100001300000047000000d804000016060000001001010c0300000000000000000000000000000000000000000000000000000000000000000000
```

Comparison to 400 dpi full-area baseline:

```text
offset  full  crop  LE16_full  LE16_crop
8       00    13    0          19
12      00    47    0          71
16      90    d8    1680       1240
17      06    04    6          4
20      70    16    3952       1558
21      0f    06    15         6
28      08    0c    776        780
```

Working interpretation:

- Offsets `8` and `12` are now strong crop offset candidates.
- Offsets `16` and `20` remain strong crop width/height or transfer dimension candidates.
- Offset `20` falls from full-area `3952` to cropped `1558`, consistent with reduced preview height or line count.
- Offset `16` falls from full-area `1680` to cropped `1240`, consistent with reduced preview width or line width.

## 2026-06-27 - VueScan manual area preview, 8-bit gray

File:

- `captures/raw/f3200-vuescan-preview-bwneg-8gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-20260627-185424.pcapng`

SHA-256:

- `70993ba0d4cff6a2443bdd8ba835cb498404567d303b675cbe99ca43844cdd6b`

Extracted:

- `captures/extracted/f3200-vuescan-preview-bwneg-8gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-20260627-185424.small.tsv`
- `captures/extracted/f3200-vuescan-preview-bwneg-8gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-20260627-185424.lengths.tsv`

VueScan settings:

- Same as the 16-bit manual cropped preview, except Bits per pixel changed to `8 bit Gray`.

Endpoint summary:

- Endpoint-filtered packets: 582
- Total endpoint data length: 1933752 bytes
- Endpoint `0x82`: 352 packets, 1932754 bytes
- Endpoint `0x01`: 230 packets, 998 bytes
- Large IN packets `>=512` bytes: 120
- Large IN bytes: 1931980
- First large frame: 862
- Last large frame: 1258
- Large IN pattern: 60 x `16384`, 59 x `15857`, 1 x `13377`

`FS W` payload:

```text
command_frame=825 payload_frame=829
90010000900100001300000047000000d804000016060000000801011a0300000000000000000000000000000000000000000000000000000000000000000000
```

Decoded fields:

```text
resolution_main      400
resolution_sub       400
offset_main          19
offset_sub           71
scan_length_main     1240
scan_length_sub      1558
scanning_color       0
data_format_depth    8
option_control       1
scanning_mode        1
block_line_number    26
gamma_correction     3
```

Comparison to 16-bit gray cropped preview:

```text
offset  16gray  8gray
25      10      08
28      0c      1a
```

Interpretation:

- Offset `25` is confirmed as data format / bit depth: `16` for 16-bit gray, `8` for 8-bit gray.
- Offset `28` is confirmed as block line number and changes from `12` to `26`.
- Geometry fields are unchanged.
- Large IN data bytes are almost exactly half of the 16-bit capture: `3863970` to `1931980`.

## 2026-06-27 - VueScan manual area preview, Slide film media

File:

- `captures/raw/f3200-vuescan-preview-slidefilm-16gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-frame1-20260627-185727.pcapng`

SHA-256:

- `0a1b14bd04e9af229067e040d18fab896a9c9d43bb9cacf0f3a215635e0bc278`

Extracted:

- `captures/extracted/f3200-vuescan-preview-slidefilm-16gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-frame1-20260627-185727.small.tsv`
- `captures/extracted/f3200-vuescan-preview-slidefilm-16gray-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-frame1-20260627-185727.lengths.tsv`

VueScan settings:

- Same geometry as the 16-bit cropped preview.
- Media changed from `B/W negative` to `Slide film`.
- Bits per pixel: `16 bit Gray`
- Preview resolution: 400 dpi
- Scan resolution: 3200 dpi
- Frame number shown by user: `1`

Endpoint summary:

- Endpoint-filtered packets: 1034
- Total endpoint data length: 3865956 bytes
- Endpoint `0x82`: 648 packets, 3864872 bytes
- Endpoint `0x01`: 386 packets, 1084 bytes
- Large IN packets `>=512` bytes: 260
- Large IN bytes: 3863970
- First large frame: 1502
- Last large frame: 2318
- Large IN pattern: 130 x `16384`, 129 x `13377`, 1 x `8417`

`FS W` payload:

```text
command_frame=1465 payload_frame=1469
90010000900100001300000047000000d804000016060000001001010c0300000000000000000000000000000000000000000000000000000000000000000000
```

Comparison to B/W negative 16-bit cropped preview:

- `FS W` payload is identical.
- Large IN byte total is identical: `3863970`.
- Large IN pattern is identical: 130 x `16384`, 129 x `13377`, 1 x `8417`.

Interpretation:

- In this preview path, changing VueScan Media from `B/W negative` to `Slide film` did not change the scanner-side `FS W` parameter block or transferred image size.
- The media setting may affect VueScan post-processing rather than scanner command parameters, at least for 16-bit gray preview with this manual area.

## 2026-06-27 - VueScan manual area preview, Color negative 24-bit RGB

File:

- `captures/raw/f3200-vuescan-preview-colorneg-24rgb-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-frame1-20260627-190014.pcapng`

SHA-256:

- `c31b41709dc91bd629ef7223578f56a119809ff3ce467ef1ad5a85bfbbf627c0`

Extracted:

- `captures/extracted/f3200-vuescan-preview-colorneg-24rgb-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-frame1-20260627-190014.small.tsv`
- `captures/extracted/f3200-vuescan-preview-colorneg-24rgb-400dpi-manual-area-x1.2-y4.5-w78.9-h98.9-frame1-20260627-190014.lengths.tsv`

VueScan settings:

- Media: Color negative
- Bits per pixel: 24 bit RGB
- Same manual area: x=`1.2`, y=`4.5`, width=`78.9`, height=`98.9`
- Preview resolution: 400 dpi
- Scan resolution: 3200 dpi
- User observed warm-up before preview scan started.

Endpoint summary:

- Endpoint-filtered packets: 1484
- Total endpoint data length: 5798274 bytes
- Endpoint `0x82`: 938 packets, 5797095 bytes
- Endpoint `0x01`: 546 packets, 1179 bytes
- Large IN packets `>=512` bytes: 390
- Large IN bytes: 5795955
- First large frame: 1214
- Last large frame: 2430
- Large IN pattern: 195 x `16384`, 194 x `13377`, 1 x `5937`

`FS W` payload:

```text
command_frame=1051 payload_frame=1055
90010000900100001300000047000000d80400001606000013080101080300000000000000010000000000000000000000000000000000000000000000000000
```

Decoded fields:

```text
resolution_main      400
resolution_sub       400
offset_main          19
offset_sub           71
scan_length_main     1240
scan_length_sub      1558
scanning_color       19
data_format_depth    8
option_control       1
scanning_mode        1
block_line_number    8
gamma_correction     3
film_type            1
```

Comparison to 16-bit B/W negative cropped preview:

```text
offset  16gray_bwneg  24rgb_colorneg
24      00            13
25      10            08
28      0c            08
37      00            01
```

Comparison to 8-bit gray cropped preview:

```text
offset  8gray  24rgb
24      00     13
28      1a     08
37      00     01
```

Interpretation:

- Offset `24`, scanning color, changes to `0x13` for RGB.
- Offset `25`, data format, remains `8`, consistent with 24-bit RGB being 8 bits per channel.
- Offset `37`, film type, changes to `1` for Color negative in this capture.
- Large IN data is about 3x the 8-bit gray crop, matching 3 channels at 8 bits.
