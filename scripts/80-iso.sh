#!/usr/bin/env bash
# 80-iso.sh —— 打包可启动 ISO（x86_64，GRUB BIOS + EFI 双引导）
#
# 打包时带 -R（Rock Ridge）+ -J（Joliet），保证 /boot 下的长文件名
# （initramfs.cpio.gz / bzImage）在 ISO9660 里不被截断。
#
# 注：实测原版 ISO 的 Rock Ridge 长文件名本来就是好的，GRUB 能找到 bzImage /
# initramfs.cpio.gz 并正常引导 —— 之前把「卡住加载」归因到 8.3 文件名截断是错的。
# 真正的原因是 rootfs-overlay / grub.cfg 里的几个小问题：
#   · inittab 里 getty 路径与 busybox 实际安装位置不一致（一直报 can't run getty）
#   · grub.cfg 的 console= 顺序写反，shell 跑到了串口而不是屏幕
#   · rcS 里 ifconfig 的软链接是坏的
#   · rootfs 里缺 /bin/login，passwd 里 root 又是 shadow 占位（登录不进去）
# 这些已在 rootfs-overlay/ 与 configs/grub.cfg 里修掉。
#
# 期望的 boot 目录结构（x86_64）：
#   boot/
#     bzImage
#     initramfs.cpio.gz
#     grub/grub.cfg
#     grub/i386-pc/           （含 eltorito.img 这个 GRUB BIOS 核心镜像）
#     grub/x86_64-efi/
#     grub/fonts/unicode.pf2
#   efiboot.img               （FAT 镜像，含 EFI/BOOT/BOOTX64.EFI）
set -euo pipefail
cd "$(dirname "$0")/.."

BOOT_DIR="${1:-output/boot}"
ISO_OUT="${2:-output/image/jtermos.iso}"

[ -f "$BOOT_DIR/bzImage" ]           || { echo "[x] 缺 $BOOT_DIR/bzImage"; exit 1; }
[ -f "$BOOT_DIR/initramfs.cpio.gz" ] || { echo "[x] 缺 $BOOT_DIR/initramfs.cpio.gz"; exit 1; }
[ -f "$BOOT_DIR/grub/grub.cfg" ]     || { echo "[x] 缺 $BOOT_DIR/grub/grub.cfg"; exit 1; }

BIOS_IMG="$BOOT_DIR/grub/i386-pc/eltorito.img"
EFI_IMG="$BOOT_DIR/../efiboot.img"
[ -f "$EFI_IMG" ] || EFI_IMG="$BOOT_DIR/efiboot.img"

mkdir -p "$(dirname "$ISO_OUT")"

# 公共参数：-R 保留长文件名，-J 加 Joliet，-V 卷标
# BIOS 引导：-b eltorito.img，no-emul-boot + boot-load-size 4 + boot-info-table
# EFI  引导：-e efiboot.img，no-emul-boot
if command -v xorriso >/dev/null 2>&1; then
    xorriso -as mkisofs \
        -o "$ISO_OUT" \
        -V "JTERMOS" \
        -R -J \
        -b "grub/i386-pc/eltorito.img" \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        -eltorito-alt-boot \
        -e "$(basename "$EFI_IMG")" \
        -no-emul-boot \
        "$BOOT_DIR" "$EFI_IMG"
elif command -v genisoimage >/dev/null 2>&1; then
    genisoimage \
        -o "$ISO_OUT" \
        -V "JTERMOS" \
        -R -J \
        -b "grub/i386-pc/eltorito.img" \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        "$BOOT_DIR"
elif command -v mkisofs >/dev/null 2>&1; then
    mkisofs \
        -o "$ISO_OUT" \
        -V "JTERMOS" \
        -R -J \
        -b "grub/i386-pc/eltorito.img" \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        "$BOOT_DIR"
else
    echo "[x] 未找到 xorriso / genisoimage / mkisofs，请先安装其一："
    echo "    Debian/Ubuntu/WSL: sudo apt install xorriso"
    echo "    macOS:             brew install cdrtools    # 或 xorriso"
    echo "    Windows:           用 WSL 后同上，或装 mkisofs"
    exit 1
fi

echo "[+] 已生成 $ISO_OUT"
echo "[+] 测试：qemu-system-x86_64 -m 512M -cdrom $ISO_OUT -nographic"
