# Capture Plan

## Rules

- Preserve raw pcapng files exactly.
- Do not overwrite captures.
- Do not replay traffic.
- Do not send manual USB commands.
- Do not run SANE scans at this stage.
- Keep Ubuntu as the USB/capture host and this Mac folder as the archive/analysis host.

## VueScan Captures

For each VueScan test:

1. Start usbmon capture on Ubuntu.
2. Perform exactly one controlled VueScan action.
3. Stop capture.
4. Copy pcapng to `captures/raw/`.
5. Extract endpoint TSVs to `captures/extracted/`.
6. Write down the user-visible VueScan settings and action.

Suggested dimensions to vary one at a time:

- Preview versus scan action.
- Film holder or mode.
- Resolution.
- Crop area.
- Color mode.
- Exposure/multi-sampling settings.

## Naming

Use descriptive labels plus timestamp:

```text
vuescan-<scenario>-YYYYMMDD-HHMMSS.pcapng
```

The scripts generate names in that format automatically.

## SANE Config-Only Test

Allowed only as an optional diagnostic:

- `scanimage -L`
- `scanimage -A` against the device, if needed

Not allowed:

- `scanimage > file`
- any command that initiates a scan
