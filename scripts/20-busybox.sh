#!/usr/bin/env bash
# 20-busybox.sh
source "$(dirname "$0")/00-env.sh"
BB_DIR="${OUTPUT_DIR}/busybox-${BUSYBOX_VERSION}"
TARBALL="${DL_DIR}/busybox-${BUSYBOX_VERSION}.tar.bz2"
if [ ! -d "$BB_DIR" ]; then
    [ -f "$TARBALL" ] || wget -c "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2" -O "$TARBALL"
    tar xf "$TARBALL" -C "$OUTPUT_DIR"
fi
cd "$BB_DIR"
if [ ! -f .config ]; then
    make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" defconfig
    sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
    sed -i 's/^CONFIG_STATIC=.*/CONFIG_STATIC=y/' .config
    make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" oldconfig </dev/null || true
fi
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j"$(nproc)"
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" install
aarch64-linux-gnu-strip --strip-unneeded ./_install/bin/busybox 2>/dev/null || true