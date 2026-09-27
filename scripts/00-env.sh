#!/usr/bin/env bash
# 00-env.sh
source "$(dirname "$0")/00-env.sh"
JTERMOS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export JTERMOS_ROOT
export DL_DIR="${JTERMOS_ROOT}/dl"
export OUTPUT_DIR="${JTERMOS_ROOT}/output"
export ROOTFS_DIR="${OUTPUT_DIR}/rootfs"
export BOOT_DIR="${OUTPUT_DIR}/boot"
export IMAGE_DIR="${OUTPUT_DIR}/image"
export TOOLS_DIR="${OUTPUT_DIR}/tools-aarch64"
export KERNEL_VERSION="6.6.47"
export BUSYBOX_VERSION="1.36.1"
export TEMURIN_VERSION="17.0.12+7"
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export BOARD_DTB="bcm2711-rpi-4-b.dtb"
export BOARD_DTS_VENDOR="broadcom"
export CONSOLE="ttyS0,115200"
mkdir -p "$DL_DIR" "$OUTPUT_DIR" "$ROOTFS_DIR" "$BOOT_DIR" "$IMAGE_DIR"
c_green() { printf "\033[1;32m[+] %s\033[0m\n" "$*"; }
c_yellow(){ printf "\033[1;33m[!] %s\033[0m\n" "$*"; }
c_red()  { printf "\033[1;31m[x] %s\033[0m\n" "$*"; }