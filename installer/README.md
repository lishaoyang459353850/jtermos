# JTermOS 安装程序（Windows）

把 JTermOS 的 ISO 镜像复制到你选择的磁盘。**只复制 ISO 文件本身**——不分区、不格式化、不写引导，安全可逆。

## 功能

- 自动列出本机所有磁盘（盘符、类型、卷标、容量、剩余空间、文件系统）
- 可移动磁盘自动排在最前面并标 ★
- 选盘 → 二次确认 → 自动复制，带实时进度与速度
- 源镜像自动查找：打包内置 → 程序同目录 → 桌面 / 下载 → 各盘根目录
- 空间不足会提前拦下；图形界面不可用时自动退回命令行模式

## 打包（你来做）

需要 Python 3.8+ 和 PyInstaller：

```bat
:: 方式一：双击
build.bat

:: 方式二：命令行
pip install pyinstaller
python build.py
```

产物在 `dist\JTermOS-Installer.exe`。

### 想做成"真正单文件、双击即装"

把 ISO 一起塞进 exe：

```bat
python build.py --iso ..\jtermos-beta1.iso
```

这样生成的 exe 自带镜像，双击就能直接选盘安装，不需要另外找 ISO 文件。

## 直接运行（不打包）

```bat
python jtermos_installer.py                 :: 图形界面
python jtermos_installer.py --cli           :: 命令行
python jtermos_installer.py --iso D:\jtermos-beta1.iso
```

## 说明

JTermOS 本身是纯终端系统，ISO 里没有图形界面和 Python，所以"双击安装"只能由 Windows 侧的这个程序来做。
它负责把 ISO 放到你想要的地方；之后用 Rufus / balenaEtcher 之类的工具写入 U 盘，或直接留档分发。
