#!/bin/bash
# Packs the rootfs into an initrd (cpio + gzip)
set -e

ARCH=${1:-x86_64}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDUL_DIR="$(dirname "$SCRIPT_DIR")"
ROOTFS_DIR="$SDUL_DIR/output/rootfs-${ARCH}"
OUTPUT="$SDUL_DIR/output/initrd-${ARCH}.img"

echo "[SDUL] Packing initrd for $ARCH..."

cd "$ROOTFS_DIR"
find . | cpio -H newc -o | gzip -9 > "$OUTPUT"

echo "[SDUL] initrd: $OUTPUT ($(du -sh "$OUTPUT" | cut -f1))"
