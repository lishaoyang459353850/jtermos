#!/usr/bin/env bash
# build.sh —— JTermOS 一键构建总入口
# 用法：
#   ./build.sh all          # 全部
#   ./build.sh kernel       # 只编译内核
#   ./build.sh rootfs       # 只重做 rootfs
#   ./build.sh image        # 只重新打包镜像
#   ./build.sh clean
set -euo pipefail
cd "$(dirname "$0")"

source scripts/00-env.sh

STEP="${1:-all}"

run() {
    local name="$1"; shift
    echo
    echo "=============================================="
    echo ">> $name"
    echo "=============================================="
    bash "scripts/$name"
}

case "$STEP" in
    all)
        run 10-kernel.sh
        run 20-busybox.sh
        run 30-rootfs.sh
        run 40-jlink.sh
        run 50-copy-libs.sh
        run 60-services.sh
        run 70-image.sh
        ;;
    kernel)  run 10-kernel.sh ;;
    busybox) run 20-busybox.sh ;;
    rootfs)
        run 30-rootfs.sh
        run 40-jlink.sh
        run 50-copy-libs.sh
        run 60-services.sh
        ;;
    image)   run 70-image.sh ;;
    clean)
        c_yellow "清理 output/"
        rm -rf output
        mkdir -p output
        ;;
    *)
        echo "用法: $0 {all|kernel|busybox|rootfs|image|clean}"
        exit 1
        ;;
esac

echo
c_green "完成。产物："
ls -lh "${IMAGE_DIR}/" 2>/dev/null || true