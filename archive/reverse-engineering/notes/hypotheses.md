# Hypotheses

These are working notes, not confirmed protocol documentation.

- `0x1c` appears to be Epson `FS`.
- `0x06` appears to be ACK.
- `1c46` likely means `FS F`, scanner status.
- `1c57` likely means `FS W`, set extended scan parameters.
- The 64-byte block after `1c57` is likely the `FS W` payload, not an independent command.
- `1c47` likely means `FS G`, start extended scan or request block layout.
- `16384` byte IN packets and trailing `3777` byte IN packets likely contain image payload blocks.
- The `64` byte `FS W` payload is the immediate target for cross-capture comparison.

## Parameter Block From First Capture

```text
9001000090010000000000000000000090060000700f000013100101020300000000000000000000000000000000000000000000000000000000000000000000
```

Next step: compare this block across captures where only one VueScan setting changes.
