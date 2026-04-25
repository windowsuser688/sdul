# SuperDuperUltraLightweight Linux (SDUL)

A minimal, non-graphical Linux distro built on Linux 6.19.11.
Supports i386 and x86_64.

## Build Requirements
- gcc, make, wget, xorriso, cpio, bc
- For i386 cross-compile: gcc-multilib

## Quick Start
```bash
cd sdul
make x86_64   # build 64-bit ISO
make i386     # build 32-bit ISO
make all      # build both
```

## Structure
- `kernel/`   - kernel config files
- `rootfs/`   - root filesystem skeleton
- `scripts/`  - build scripts
- `output/`   - built ISOs land here
