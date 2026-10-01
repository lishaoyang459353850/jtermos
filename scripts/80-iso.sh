#!/usr/bin/env bash
# 80-iso.sh —— 打包可启动 ISO（x86_64，GRUB BIOS + EFI 双引导）
#
# ⚠️⚠️ 关键：必须带 -R（Rock Ridge）+ -J（Joliet）⚠️⚠️
#   否则 ISO9660 会把长文件名截断成 8.3 短名（大小写也变）：
#     initramfs.cpio.gz → INITRAMF.GZ
#     bzImage           → BZIMAGE
#     i386-pc           → I386_PC
#     x86_64-efi        → X86_64_E
#   GRUB 按 grub.cfg 里的原文件名（initramfs.cpio.gz / bzImage）找不到文件，
#   就会卡在 "Loading initramfs..." 不动 —— 这正是「卡住加载」的根因。
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