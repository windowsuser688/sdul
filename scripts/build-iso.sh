#!/bin/bash
# Assembles the final bootable ISO for SDUL
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDUL_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$SDUL_DIR/output"
ISO_STAGE="$OUTPUT_DIR/iso-stage"
ISO_OUT="$OUTPUT_DIR/sdul.iso"

echo "[SDUL] Assembling ISO..."

# Prepare ISO staging area
rm -rf "$ISO_STAGE"
mkdir -p "$ISO_STAGE/boot/grub"

# Copy kernels and initrds
for ARCH in x86_64 i386; do
    [ -f "$OUTPUT_DIR/vmlinuz-${ARCH}" ]  && cp "$OUTPUT_DIR/vmlinuz-${ARCH}"  "$ISO_STAGE/boot/"
    [ -f "$OUTPUT_DIR/initrd-${ARCH}.img" ] && cp "$OUTPUT_DIR/initrd-${ARCH}.img" "$ISO_STAGE/boot/"
done

# Copy grub config
cp "$SDUL_DIR/iso/boot/grub/grub.cfg" "$ISO_STAGE/boot/grub/"

# Build ISO with grub-mkrescue
grub-mkrescue -o "$ISO_OUT" "$ISO_STAGE" -- \
    -volid "SDUL" \
    -joliet -joliet-long \
    2>/dev/null

echo "[SDUL] ISO ready: $ISO_OUT ($(du -sh "$ISO_OUT" | cut -f1))"
echo ""
echo "Test with QEMU:"
echo "  qemu-system-x86_64 -m 256M -cdrom $ISO_OUT -nographic"
echo "  qemu-system-i386   -m 256M -cdrom $ISO_OUT -nographic"
