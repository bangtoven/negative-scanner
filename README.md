# Epson F-3200 Film Scanner

Lightweight Epson F-3200 film scanning project for macOS.

The goal is to scan negatives with an Epson F-3200 without VueScan. The current direction is to use SANE `epson2` for scanner transport, keep the original SANE source as a submodule, and keep the F-3200 backend change as a small patch.

Repository layout:

- `sane-backends/` - SANE upstream submodule, F-3200 patch, and patch notes
- `archive/reverse-engineering/` - previous USB capture notes and helper scripts

Local captures, scan outputs, build products, and local installs are not committed.
