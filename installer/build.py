#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""
把 JTermOS 安装程序打包成单个 Windows exe（PyInstaller）。

准备：
    pip install pyinstaller

用法：
    python build.py                                     # 只打包程序
    python build.py --iso ..\jtermos-beta1.iso          # 把 ISO 一起塞进 exe（真正单文件，双击就能装）

产物：dist\JTermOS-Installer.exe
"""
import os
import sys
import argparse
import subprocess


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--iso", help="要一起打包进 exe 的 ISO 路径")
    ap.add_argument("--name", default="JTermOS-Installer", help="产物名")
    ap.add_argument("--console", action="store_true", help="保留控制台窗口（调试用）")
    args = ap.parse_args()

    here = os.path.dirname(os.path.abspath(__file__))
    entry = os.path.join(here, "jtermos_installer.py")

    cmd = [sys.executable, "-m", "PyInstaller", "--noconfirm", "--clean",
           "--onefile", "--name", args.name, "--hidden-import", "tkinter"]
    if not args.console:
        cmd.append("--windowed")
    if args.iso:
        iso = os.path.abspath(args.iso)
        if not os.path.isfile(iso):
            print(f"[!] 找不到 ISO：{iso}")
            return 1
        cmd += ["--add-data", f"{iso}{os.pathsep}."]
        print(f"[i] 已内置 ISO：{iso}")
    cmd.append(entry)

    print("[i] 执行：", " ".join(cmd))
    r = subprocess.run(cmd, cwd=here)
    if r.returncode != 0:
        print("[!] 打包失败")
        return r.returncode
    out = os.path.join(here, "dist", args.name + (".exe" if os.name == "nt" else ""))
    print(f"\n完成 ✔  产物：{out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
