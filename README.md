# Epson F-3200 Film Scanner

Lightweight Epson F-3200 film scanning project for macOS.

The goal is to scan negatives with an Epson F-3200 without VueScan. The current direction is to use SANE `epson2` for scanner transport, keep the original SANE source as a submodule, and keep the F-3200 backend change as a small patch.

## Plan

- Make patched SANE `epson2` reliably expose F-3200 TPU, film type, 16-bit gray, and RGB scan modes.
- Use `scanimage` as the first validation frontend before writing a custom app.
- Capture a low-resolution transparency preview of the whole holder.
- Detect the fixed 35mm frame positions from that preview; allow manual correction when detection is wrong.
- Scan selected frames at final DPI and bit depth.
- Keep negative conversion and image adjustment outside scanner transport:
  - invert negative
  - set black/white points
  - adjust gamma or curve
  - balance RGB color negative channels
- Build a small F-3200-specific frontend only after the SANE path is proven.
- Use archived VueScan USB captures only to explain or verify scanner behavior.

## SANE Test Commands

Apply the local backend patch:

```sh
git submodule update --init sane-backends/upstream
cd sane-backends/upstream
git apply ../f3200.patch
```

Check device discovery:

```sh
local/sane-f3200/bin/scanimage -L
```

Check exposed options:

```sh
local/sane-f3200/bin/scanimage -d 'epson2:libusb:000:004' -A
```

Small 16-bit gray transparency test:

```sh
local/sane-f3200/bin/scanimage -d 'epson2:libusb:000:004' \
  --source 'Transparency Unit' \
  --film-type 'Negative Film' \
  --mode Gray \
  --depth 16 \
  --resolution 400 \
  --preview=yes \
  -l 0 -t 0 -x 10 -y 10 \
  > scans/test-gray16-400.pnm
```

Small RGB48 transparency test:

```sh
local/sane-f3200/bin/scanimage -d 'epson2:libusb:000:004' \
  --source 'Transparency Unit' \
  --film-type 'Negative Film' \
  --mode Color \
  --depth 16 \
  --resolution 400 \
  --preview=yes \
  -l 0 -t 0 -x 10 -y 10 \
  > scans/test-rgb48-400.pnm
```

Full-holder preview for frame detection:

```sh
local/sane-f3200/bin/scanimage -d 'epson2:libusb:000:004' \
  --source 'Transparency Unit' \
  --film-type 'Negative Film' \
  --mode Gray \
  --depth 8 \
  --resolution 400 \
  --preview=yes \
  -l 0 -t 0 -x 106.9 -y 251.0 \
  > scans/holder-preview-gray8-400.pnm
```

Repository layout:

- `sane-backends/` - SANE upstream submodule, F-3200 patch, and patch notes
- `archive/reverse-engineering/` - previous USB capture notes and helper scripts

Local captures, scan outputs, build products, and local installs are not committed.
