#!/usr/bin/env bash
# 70-image.sh
source "$(dirname "$0")/00-env.sh"
cd "$OUTPUT_DIR"
cp "${JTERMOS_ROOT}/configs/grub.cfg" "${BOOT_DIR}/grub.cfg"
"${JTERMOS_ROOT}/scripts/grub-install.sh"
SQUASHFS="${OUTPUT_DIR}/jtermos-rootfs.squashfs"
mksquashfs "$ROOTFS_DIR" "$SQUASHFS" -comp xz -b 1M -noappend -no-progress
cp "${JTERMOS_ROOT}/configs/genimage.cfg" "${OUTPUT_DIR}/genimage.cfg"
sed -i "s|__BOARD_DTB__|${BOARD_DTB}|g" "${OUTPUT_DIR}/genimage.cfg"
genimage --config "${OUTPUT_DIR}/genimage.cfg" --inputpath "${OUTPUT_DIR}" --outputpath "${IMAGE_DIR}" --rootpath "$ROOTFS_DIR" 2>&1 | tail -30