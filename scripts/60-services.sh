#!/usr/bin/env bash
# 60-services.sh
source "$(dirname "$0")/00-env.sh"
chmod +x "$ROOTFS_DIR/etc/init.d/"* 2>/dev/null || true
chmod +x "$ROOTFS_DIR/opt/jterm/bin/"* 2>/dev/null || true
mkdir -p "$ROOTFS_DIR/var/run"