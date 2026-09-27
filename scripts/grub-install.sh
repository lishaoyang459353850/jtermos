#!/usr/bin/env bash
# grub-install.sh
source "$(dirname "$0")/00-env.sh"
EFI_DIR="${BOOT_DIR}/EFI/BOOT"
mkdir -p "$EFI_DIR"
GRUB_MODULES="normal linux linuxefi configfile ext2 fat serial efi_gop efi_uga gfxterm echo test"
if grub-mkimage --list-targets 2>/dev/null | grep -q arm64-efi; then
    grub-mkimage -O arm64-efi -o "${EFI_DIR}/grubaa64.efi" -p /EFI/BOOT ${GRUB_MODULES}
else
    grub-mkimage -O x86_64-efi -o "${EFI_DIR}/grubx64.efi" -p /EFI/BOOT ${GRUB_MODULES}
fi
if command -v mkimage >/dev/null; then
    cat > "${BOOT_DIR}/boot.cmd" <<EOF
setenv bootargs console=${CONSOLE} root=/dev/mmcblk0p2 rootfstype=squashfs ro rootwait loglevel=3 quiet
load mmc 0:1 \${kernel_addr_r} Image.gz
load mmc 0:1 \${fdt_addr_r} ${BOARD_DTB}
booti \${kernel_addr_r} - \${fdt_addr_r}
EOF
    mkimage -C none -A arm64 -T script -d "${BOOT_DIR}/boot.cmd" "${BOOT_DIR}/boot.scr"
fi