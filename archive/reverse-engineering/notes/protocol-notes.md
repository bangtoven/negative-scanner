# Protocol Notes

## Descriptor

Observed via `lsusb -v` and saved in `archive/reverse-engineering/notes/f3200-lsusb-v.txt`.

Scanner interface:

- Interface `0`: `EPSON Scanner`, vendor-specific
- Bulk OUT endpoint: `0x01`
- Bulk IN endpoint: `0x82`
- Max packet size: `512`

Mass storage interface:

- OUT endpoint: `0x04`
- IN endpoint: `0x85`

Analysis currently focuses only on scanner interface endpoint pair `0x01`/`0x82`.

## First VueScan Capture

Capture:

- `captures/raw/vuescan-controlled-20260527-112132.pcapng`
- SHA-256: `0d3b8d895d0260b3878e5b629d25977b07cf1db8f7d98b3b09ecedbaa7a7e496`
- Size: about 40 MB
- Packets: 16400

Scanner endpoint summary:

- Endpoint-filtered packets: 12552
- Total endpoint data length: 39844206 bytes
- Endpoint `0x82`: 8256 packets, 39840997 bytes
- Endpoint `0x01`: 4296 packets, 3209 bytes
- Large IN packets `>=512` bytes: 3952
- Large IN bytes: 39838136
- First large frame: 4002
- Last large frame: 15974

Image-like IN traffic:

- Repeating `16384` byte IN packets
- Repeating `3777` byte IN packets

## Important Command Sequence

Frames around scan setup/start:

```text
3027 OUT 0x01 len=2  data=1c57
3030 IN  0x82 len=1  data=06
3031 OUT 0x01 len=64 data=9001000090010000000000000000000090060000700f000013100101020300000000000000000000000000000000000000000000000000000000000000000000
3034 IN  0x82 len=1  data=06
3045 OUT 0x01 len=2  data=1c46
3048 IN  0x82 len=16 data=0000c000020000000000000000000000
3049 OUT 0x01 len=2  data=1c47
3052 IN  0x82 len=14 data=0292000000000000000000000000
```

Earlier traffic shows Epson-style commands such as `1b49`, `1b66`, `1b69`, and `1c49`.
