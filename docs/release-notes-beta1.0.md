# JTermOS 1.0 beta1 发布说明

**发布日期**：2026-10-02
**镜像**：`jtermos-beta1.iso`（28,450,816 字节）
**SHA256**：`85f3eee68e38ae2ae50af9302f94172319a553bcd77a6677f7a970829417dc1e`

---

## 本次新增

### 1. 开机图形标志

GRUB 启动画面 `assets/grub_logo.png`（1024×768）：深色渐变底 + 终端窗口图标（红黄绿三个圆点）+ 青绿色 `JTermOS` 字样 + 大号标题 + 副标题 + `v1.0 beta1` 徽标。

GRUB 配置同时补上了 `png` / `font` / `all_video` 模块与 `set gfxmode`，菜单项在图形模式下渲染。

### 2. 开机显示 jtermos 字样 + 内核日志

控制台启动后打印：

- 彩色块字横幅 `JTERMOS`（`assets/banner.ansi`）
- 版本行 `JTermOS 1.0 beta1 | Linux <版本> <架构>`
- 内核启动日志（`dmesg` 最近 16 行）

配套改动：启动参数由 `quiet loglevel=3` 改为 `loglevel=7` 并去掉 `quiet`，内核日志不再被静默；`rcS` 里 `dmesg -n 7` 保证控制台日志等级完整。

### 3. ISO 内置安装程序

- **Windows 图形安装器**（`installer/`，Python 源码）：列出本机磁盘 → 选盘 → 二次确认 → 自动复制 ISO，带实时进度与速度。附 PyInstaller 打包脚本（`build.bat` / `build.py`）。
- **终端安装程序** `jterm-install`：在 JTermOS 里执行，列出磁盘 → 选号 → 输入 `yes` 确认 → `dd` 原样写入。

### 4. 其他修复与优化

- root 免密登录，开机直接进 shell
- `os-release` 版本号更新为 `1.0-beta1`
- ISO 卷标 `JTERMOS_B1`，Rock Ridge + Joliet 双长名，长文件名不再丢失
- ISO 根目录新增 `README.TXT` 说明安装方式

---

## 已实测验证

| 项目 | 结果 |
|---|---|
| QEMU 启动到 login | ✅ |
| GRUB 图形启动画面显示 | ✅ 无花屏、无模块缺失报错 |
| 控制台块字横幅 + 版本行 | ✅ |
| 内核启动日志完整可见 | ✅ |
| ISO 内 `/installer/` 文件齐全 | ✅ |

---

## 已知限制

1. **内核自带的企鹅 logo 改不了**。那是内核编译期烘焙进 `bzImage` 的，改动需要重新编译内核；本次的"图形标志"是用 GRUB 启动画面实现的。
2. **"双击安装"只能在 Windows 侧做**。JTermOS 是纯终端系统，ISO 里没有图形界面、没有 Python，系统内只有终端命令 `jterm-install`。
3. **仓库 `scripts/` 里的构建链路是 ARM64 目标**（bcm2711 / genimage SD 卡），与本 ISO 的 x86_64 链路不一致，`./build.sh all` 无法复现本 ISO。本 ISO 由独立链路构建。
4. beta 版本，安装程序尚未在真实 U 盘上做过完整的写入—启动验证。

---

## 安装方式

**Windows**：挂载 ISO → 进 `installer\` → 双击 `build.bat` 编译 → 双击 `JTermOS-Installer.exe` → 选盘 → 确认。

**终端**：在 JTermOS 里执行 `jterm-install`。

**写盘工具**：Rufus / balenaEtcher 直接写 ISO 到 U 盘。
