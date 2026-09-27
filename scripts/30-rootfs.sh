#!/usr/bin/env bash
# 30-rootfs.sh
source "$(dirname "$0")/00-env.sh"
BB_INSTALL="${OUTPUT_DIR}/busybox-${BUSYBOX_VERSION}/_install"
rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"
cp -a "${BB_INSTALL}"/* "$ROOTFS_DIR/"
mkdir -p "$ROOTFS_DIR"/{etc/init.d,etc/profile.d,proc,sys,dev,tmp,var/log,var/run,home,mnt,data,opt/jterm/{app,bin,jre},usr/share/zoneinfo/Asia}
sudo mknod -m 622 "$ROOTFS_DIR/dev/console" c 5 1 2>/dev/null || true
sudo mknod -m 666 "$ROOTFS_DIR/dev/null" c 1 3 2>/dev/null || true
cp -a "${JTERMOS_ROOT}/rootfs-overlay/etc/." "$ROOTFS_DIR/etc/"
cp -a "${JTERMOS_ROOT}/rootfs-overlay/opt/." "$ROOTFS_DIR/opt/"
chmod +x "$ROOTFS_DIR/etc/init.d/"* "$ROOTFS_DIR/opt/jterm/bin/"* 2>/dev/null || true
ln -sf usr/share/zoneinfo/Asia/Shanghai "$ROOTFS_DIR/etc/localtime"
if [ -f "${JTERMOS_ROOT}/app/app.jar" ]; then
    cp "${JTERMOS_ROOT}/app/app.jar" "$ROOTFS_DIR/opt/jterm/app/"
fi