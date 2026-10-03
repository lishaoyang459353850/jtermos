# JTermOS —— 带 GRUB 的轻量级 Linux 终端系统
**我们目前已经停止了支持，如果想获得后续支持，请访问：[https://pan.quark.cn/s/00d41f4bcaf2](https://pan.quark.cn/s/a9574af08859)
**1.0 beta1** ｜ 官网 [jtermos.webside.ccwu.cc](https://jtermos.webside.ccwu.cc/)

## 这是什么

从零构建的轻量可引导 Linux 终端系统：

- **GRUB 2.06 引导**（BIOS + EFI 双引导）
- **开机图形标志**：深色启动画面 + 终端窗口图标 + `JTermOS` 字样 + 版本徽标
- **开机控制台横幅**：彩色 `JTERMOS` 块字 + 版本行 + 内核启动日志
- Linux 内核 5.15 LTS（x86_64）
- BusyBox 静态 rootfs
- 内置 GitHub 优质项目：**fastfetch**、**neofetch**
- **内置安装程序**：终端 `jterm-install` + Windows 侧图形安装器（`installer/`）
- QEMU 实测可启动

## 1.0 beta1 更新

| 项目 | 说明 |
|---|---|
| 开机图形标志 | GRUB 启动画面 `assets/grub_logo.png`，1024×768 |
| 开机字样 + 内核日志 | 控制台横幅 `assets/banner.ansi`，`rcS` 打印版本行 + `dmesg` 最近 16 行 |
| 内核日志完整可见 | 启动参数由 `quiet loglevel=3` 改为 `loglevel=7`，去掉 `quiet` |
| 内置安装程序 | ISO 内 `/installer/`（Windows 图形安装器源码）+ 终端 `jterm-install` |
| 免密登录 | root 直接进 shell，省去登录步骤 |
| 构建脚本 | `scripts/` 下为一键构建链路 |

## 快速开始（QEMU 直接跑）

```bash
# 从 Release 下载 jtermos-beta1.iso
qemu-system-x86_64 -m 512M -cdrom jtermos-beta1.iso -vga std
# 开机即是 JTermOS 横幅 + 内核日志，回车进 shell
# 输 fastfetch 看系统信息，输 jterm-install 启动终端安装程序
```

## 安装

JTermOS 是纯终端系统，ISO 内没有图形界面、也没有 Python，所以"双击安装"由 **Windows 侧**的程序完成：

**方式一：Windows 图形安装器（推荐）**

1. 挂载 `jtermos-beta1.iso`，进入 `installer\` 目录
2. 双击 `build.bat` 编译出 `JTermOS-Installer.exe`（需 Python 3.8+）
3. 双击 `JTermOS-Installer.exe`，在列表里选目标磁盘 → 确认 → 自动复制

也可以直接 `python jtermos_installer.py` 运行，或用 `python build.py --iso ..\jtermos-beta1.iso`
把镜像一起打包进 exe，做成真正单文件、双击即装。

**方式二：终端安装程序**

在 JTermOS 里执行 `jterm-install`，按提示选磁盘、输入 `yes` 确认，系统会原样写入目标磁盘。

**方式三：任何写盘工具**

用 Rufus / balenaEtcher 等把 ISO 写入 U 盘即可。

## 目录结构

```
jtermos/
├── build.sh                  # 一键构建总入口
├── configs/
│   ├── jterm-kernel.fragment # 内核增量配置
│   ├── genimage.cfg          # 分区/镜像定义
│   ├── grub.cfg              # GRUB 启动菜单 + 启动画面
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
├── assets/                   # 开机画面资源
│   ├── grub_logo.png         # GRUB 启动图
│   └── banner.ansi           # 控制台块字横幅
├── installer/                # Windows 图形安装器（Python 源码）
│   ├── jtermos_installer.py  # 主程序
│   ├── build.py / build.bat  # PyInstaller 打包脚本
│   └── README.md             # 使用说明
├── rootfs-overlay/           # 直接覆盖到 rootfs
│   ├── etc/...               # inittab / rcS / os-release ...
│   └── usr/bin/jterm-install # 终端安装程序
└── app/
    └── app.jar               # 放你的 Java 应用
```

## 从零构建

```bash
sudo apt install -y build-essential bc flex bison libssl-dev libncurses-dev \
    qemu-user-static u-boot-tools device-tree-compiler squashfs-tools cpio \
    wget git rsync file genimage mtools dosfstools

./build.sh all
```

## 指标

| 指标 | 目标 |
|---|---|
| ISO 大小 | ~28 MB |
| 启动到 shell | < 5 s |
| 崩溃恢复 | ≤ 5 s |
