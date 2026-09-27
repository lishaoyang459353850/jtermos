#!/usr/bin/env bash
# 50-copy-libs.sh
source "$(dirname "$0")/00-env.sh"
SYSROOT="$(aarch64-linux-gnu-gcc -print-sysroot)"
need_libs() {
    aarch64-linux-gnu-readelf -d "$1" 2>/dev/null | awk '/NEEDED/ { gsub(/[\[\]]/,"",$5); print $5 }'
}
find_lib() {
    find "$SYSROOT" -name "$1" -type f 2>/dev/null | head -1
}
mapfile -t ELFS < <(find "$ROOTFS_DIR" -type f -exec sh -c 'head -c 4 "$1" 2>/dev/null | grep -q "^\x7fELF" && echo "$1"' _ {} \;)
declare -A SEEN
for elf in "${ELFS[@]}"; do
    for lib in $(need_libs "$elf"); do
        [[ -n "${SEEN[$lib]:-}" ]] && continue
        SEEN[$lib]=1
        find "$ROOTFS_DIR" -name "$lib" | grep -q . && continue
        src="$(find_lib "$lib")"
        [ -z "$src" ] && continue
        mkdir -p "$ROOTFS_DIR/lib"
        cp -aL "$src" "$ROOTFS_DIR/lib/$lib"
        aarch64-linux-gnu-strip --strip-unneeded "$ROOTFS_DIR/lib/$lib" 2>/dev/null || true
    done
echo "/lib" > "$ROOTFS_DIR/etc/ld.so.conf"
echo "/usr/lib" >> "$ROOTFS_DIR/etc/ld.so.conf"
done