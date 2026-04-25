#!/bin/bash
# Builds a minimal busybox-based rootfs for SDUL
set -e

ARCH=${1:-x86_64}
BUSYBOX_VER="1.36.1"
BUSYBOX_URL="https://busybox.net/downloads/busybox-${BUSYBOX_VER}.tar.bz2"
ROOTFS_DIR="$(pwd)/output/rootfs-${ARCH}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDUL_DIR="$(dirname "$SCRIPT_DIR")"

echo "[SDUL] Building rootfs for $ARCH..."

# Clean and create dirs
rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"/{bin,sbin,usr/bin,usr/sbin,etc/init.d,proc,sys,dev,tmp,root,lib,lib64,mnt,run}

# Download busybox if needed
mkdir -p "$SDUL_DIR/output/src"
cd "$SDUL_DIR/output/src"
if [ ! -f "busybox-${BUSYBOX_VER}.tar.bz2" ]; then
    echo "[SDUL] Downloading busybox ${BUSYBOX_VER}..."
    wget -q "$BUSYBOX_URL"
fi
if [ ! -d "busybox-${BUSYBOX_VER}" ]; then
    tar xjf "busybox-${BUSYBOX_VER}.tar.bz2"
fi

cd "busybox-${BUSYBOX_VER}"

# Configure busybox
make distclean > /dev/null 2>&1 || true
if [ "$ARCH" = "i386" ]; then
    make defconfig ARCH=i386
    # Force 32-bit, disable broken applets
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
    sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config
    CFLAGS="-m32" LDFLAGS="-m32" make -j$(nproc) ARCH=i386 CROSS_COMPILE=""
else
    make defconfig
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
    sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config
    make -j$(nproc)
fi

make CONFIG_PREFIX="$ROOTFS_DIR" install

# Copy our rootfs overlay
cp -r "$SDUL_DIR/rootfs/etc" "$ROOTFS_DIR/"
chmod +x "$ROOTFS_DIR/etc/init.d/rcS"

# Create device nodes
mknod -m 622 "$ROOTFS_DIR/dev/console" c 5 1 2>/dev/null || true
mknod -m 666 "$ROOTFS_DIR/dev/null"    c 1 3 2>/dev/null || true
mknod -m 666 "$ROOTFS_DIR/dev/zero"    c 1 5 2>/dev/null || true
mknod -m 444 "$ROOTFS_DIR/dev/random"  c 1 8 2>/dev/null || true
mknod -m 444 "$ROOTFS_DIR/dev/urandom" c 1 9 2>/dev/null || true

# Create /init symlink - kernel looks for this first in initramfs
ln -sf sbin/init "$ROOTFS_DIR/init"

echo "[SDUL] rootfs for $ARCH built at $ROOTFS_DIR"
