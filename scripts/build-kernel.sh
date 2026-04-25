#!/bin/bash
# Builds the Linux kernel for SDUL
set -e

ARCH=${1:-x86_64}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDUL_DIR="$(dirname "$SCRIPT_DIR")"
KERNEL_DIR="$(dirname "$SDUL_DIR")"  # linux kernel root is parent of sdul/
OUTPUT_DIR="$SDUL_DIR/output"

mkdir -p "$OUTPUT_DIR"

echo "[SDUL] Building kernel for $ARCH..."

cd "$KERNEL_DIR"

if [ "$ARCH" = "i386" ]; then
    cp "$SDUL_DIR/kernel/config-i386" .config
    make ARCH=i386 olddefconfig
    make ARCH=i386 -j$(nproc) bzImage
    cp arch/x86/boot/bzImage "$OUTPUT_DIR/vmlinuz-i386"
else
    cp "$SDUL_DIR/kernel/config-x86_64" .config
    make ARCH=x86_64 olddefconfig
    make ARCH=x86_64 -j$(nproc) bzImage
    cp arch/x86/boot/bzImage "$OUTPUT_DIR/vmlinuz-x86_64"
fi

echo "[SDUL] Kernel built: $OUTPUT_DIR/vmlinuz-${ARCH}"
