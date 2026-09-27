#!/usr/bin/env bash
# 40-jlink.sh
source "$(dirname "$0")/00-env.sh"
JDK_DIR="${TOOLS_DIR}/jdk"
JRE_OUT="${OUTPUT_DIR}/jre"
VER_DIR="${TEMURIN_VERSION/+/%2B}"
TARBALL="${DL_DIR}/temurin17-aarch64.tar.gz"
if [ ! -d "$JDK_DIR" ]; then
    mkdir -p "$TOOLS_DIR"
    [ -f "$TARBALL" ] || wget -c "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${VER_DIR}/OpenJDK17U-jdk_aarch64_linux_hotspot_${VER_DIR}.tar.gz" -O "$TARBALL"
    tar xf "$TARBALL" -C "$TOOLS_DIR/"
    ln -sf "${TOOLS_DIR}/jdk-${TEMURIN_VERSION}" "$JDK_DIR"
fi
MODULES="java.base,java.logging,java.naming,java.sql,java.management,jdk.crypto.ec,jdk.unsupported,jdk.zipfs,jdk.charsets,jdk.localedata,jdk.security.auth,jdk.naming.dns"
rm -rf "$JRE_OUT"; mkdir -p "$JRE_OUT"
qemu-aarch64-static "${JDK_DIR}/bin/jlink" \
    --add-modules "${MODULES}" \
    --module-path "${JDK_DIR}/jmods" \
    --output "${JRE_OUT}" \
    --strip-debug --no-header-files --no-man-pages \
    --compress=zip-6 --endian little --vm server
rm -rf "${JRE_OUT}/jmods"
find "${JRE_OUT}/lib" -name "*.so" -exec aarch64-linux-gnu-strip --strip-unneeded {} \; 2>/dev/null || true
rm -rf "${ROOTFS_DIR}/opt/jterm/jre"
mkdir -p "${ROOTFS_DIR}/opt/jterm/jre"
cp -a "${JRE_OUT}/." "${ROOTFS_DIR}/opt/jterm/jre/"