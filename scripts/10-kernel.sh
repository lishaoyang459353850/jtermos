#!/usr/bin/env bash
# 10-kernel.sh
source "$(dirname "$0")/00-env.sh"
KERNEL_DIR="${OUTPUT_DIR}/linux-${KERNEL_VERSION}"
TARBALL="${DL_DIR}/linux-${KERNEL_VERSION}.tar.xz"
if [ ! -d "$KERNEL_DIR" ]; then
    [ -f "$TARBALL" ] || wget -c "https://mirrors.aliyun.com/linux-kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz" -O "$TARBALL"
    tar xf "$TARBALL" -C "$OUTPUT_DIR"
fi
cd "$KERNEL_DIR"
if [ ! -f .config ]; then
    make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" defconfig
    ./scripts/kconfig/merge_config.sh -n .config "${JTERMOS_ROOT}/configs/jterm-kernel.fragment"
    make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" olddefconfig
fi
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j"$(nproc)" Image dtbs
cp arch/arm64/boot/Image.gz "${BOOT_DIR}/"
cp arch/arm64/boot/dts/${BOARD_DTS_VENDOR}/${BOARD_DTB} "${BOOT_DIR}/" 2>/dev/null || true