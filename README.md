# JTermOS —— 带 GRUB 的轻量级 Linux 终端系统
**9.30更新，官网**[jtermos.webside.ccwu.cc](https://jtermos.webside.ccwu.cc/)
## 这是什么

从零构建的轻量可引导 Linux 终端系统：

- **GRUB 2.06 引导**（BIOS + EFI 双引导）
- Linux 内核（5.15 LTS / 6.6 裁剪版）
- BusyBox 静态 rootfs（~250KB）
- Temurin OpenJDK 17 jlink 裁剪 JRE（~40MB）
- 内置 GitHub 优质项目：**fastfetch**、**neofetch**
- Java 应用自动启动 + 崩溃自恢复
- QEMU 实测可启动

## 快速开始（需要QEMU)

```bash
# 从 Release 下载 jtermos.iso
qemu-system-x86_64 -m 512M -cdrom jtermos.iso -nographic
# 按回车进 shell，输 fastfetch 看系统信息
```

## 目录结构

```
jtermos/
├── build.sh                  # 一键构建总入口
├── configs/
│   ├── jterm-kernel.fragment # 内核增量配置
│   ├── genimage.cfg          # 分区/镜像定义
│   ├── grub.cfg              # GRUB 启动菜单
│   └── boot.cmd              # U-Boot 备选启动脚本
├── scripts/
│   ├── 00-env.sh             # 环境变量
│   ├── 10-kernel.sh          # 编译内核
│   ├── 20-busybox.sh         # 编译 BusyBox
│   ├── 30-rootfs.sh          # 组装 rootfs
│   ├── 40-jlink.sh           # jlink 裁剪 JRE
│   ├── 50-copy-libs.sh       # ldd/readelf 扫库拷贝
│   ├── 60-services.sh        # 安装 init/服务脚本
│   ├── 70-image.sh           # 打 squashfs + ISO
│   └── grub-install.sh       # 生成 EFI GRUB
├── rootfs-overlay/           # 直接覆盖到 rootfs
│   └── etc/..., opt/jterm/...
└── app/
    └── app.jar               # 放你的 Java 应用
```

## 从零构建

```bash
sudo apt install -y build-essential bc flex bison libssl-dev libncurses-dev \
    qemu-user-static u-boot-tools device-tree-compiler squashfs-tools cpio \
    wget git rsync file genimage mtools dosfstools grub-efi-arm64-bin

./build.sh all
```

## 指标

| 指标 | 目标 |
|---|---|
| ISO 大小 | ~28 MB |
| rootfs.squashfs | 30–60 MB |
| 启动到 shell | < 5 s |
| JVM RSS | 90–120 MB |
| 崩溃恢复 | ≤ 5 s |
