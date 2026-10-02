#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
JTermOS 安装程序  (Windows)
==========================================
把 JTermOS 的 ISO 镜像复制到你选择的磁盘。

- 列出本机所有可写磁盘（含容量、类型、剩余空间）
- 选盘 -> 二次确认 -> 自动复制，全程无需其他操作
- 只复制 ISO 文件本身，不写引导、不分区、不格式化，安全可逆

用法：
    python jtermos_installer.py             # 图形界面
    python jtermos_installer.py --cli       # 纯命令行
    python jtermos_installer.py --iso D:\\path\\jtermos-beta1.iso
"""

import os
import sys
import json
import shutil
import argparse
import subprocess

APP_NAME = "JTermOS 安装程序"
APP_VER = "1.0 beta1"
ISO_HINT = "jtermos"

DRIVE_TYPE = {0: "未知", 1: "无根目录", 2: "可移动磁盘", 3: "本地磁盘", 4: "网络", 5: "光驱", 6: "内存盘"}


# ------------------------------------------------------------------ 基础
def is_windows():
    return os.name == "nt"


def human(n):
    """字节数转可读"""
    n = float(n or 0)
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024 or unit == "TB":
            return f"{n:.1f} {unit}" if unit != "B" else f"{int(n)} B"
        n /= 1024


def app_dir():
    """程序所在目录（兼容 PyInstaller 单文件模式）"""
    if getattr(sys, "frozen", False):
        return os.path.dirname(os.path.abspath(sys.executable))
    return os.path.dirname(os.path.abspath(__file__))


def bundled_dir():
    """PyInstaller 解包目录（打包进去的 ISO 在这里）"""
    return getattr(sys, "_MEIPASS", None)


# ------------------------------------------------------------------ 找 ISO
def find_iso(explicit=None):
    """定位 JTermOS ISO：显式指定 > 打包内置 > 常见位置 > 各盘根目录"""
    if explicit:
        return explicit if os.path.isfile(explicit) else None

    # 1) PyInstaller 内置
    bd = bundled_dir()
    if bd:
        for f in sorted(os.listdir(bd)):
            if f.lower().endswith(".iso"):
                return os.path.join(bd, f)

    hits = []

    def scan(d):
        try:
            for f in sorted(os.listdir(d)):
                if f.lower().endswith(".iso") and ISO_HINT in f.lower():
                    hits.append(os.path.join(d, f))
        except Exception:
            pass

    home = os.path.expanduser("~")
    for d in (app_dir(), os.getcwd(),
              os.path.join(home, "Desktop"), os.path.join(home, "桌面"),
              os.path.join(home, "Downloads"), os.path.join(home, "下载")):
        if os.path.isdir(d):
            scan(d)
    if hits:
        return hits[0]

    # 2) 各盘根目录
    for letter in "CDEFGHIJKLMNOPQRSTUVWXYZ":
        scan(letter + ":\\")
    return hits[0] if hits else None


# ------------------------------------------------------------------ 列磁盘
def list_volumes():
    """枚举本机磁盘卷，返回 dict 列表"""
    if not is_windows():
        raise RuntimeError("本安装程序仅支持 Windows")
    ps = ("Get-CimInstance Win32_LogicalDisk | "
          "Select-Object DeviceID,VolumeName,DriveType,Size,FreeSpace,FileSystem | "
          "ConvertTo-Json -Compress")
    r = subprocess.run(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    raw = (r.stdout or "").strip()
    if not raw:
        return []
    data = json.loads(raw)
    if isinstance(data, dict):
        data = [data]
    out = []
    for d in data:
        dt = int(d.get("DriveType") or 0)
        size = int(d.get("Size") or 0)
        free = int(d.get("FreeSpace") or 0)
        out.append({
            "id": d.get("DeviceID") or "",
            "label": (d.get("VolumeName") or "").strip(),
            "fs": (d.get("FileSystem") or "").strip(),
            "drive_type": dt,
            "type_name": DRIVE_TYPE.get(dt, "其他"),
            "size": size,
            "free": free,
            "removable": dt == 2,
        })
    out.sort(key=lambda v: (not v["removable"], v["id"]))
    return out


# ------------------------------------------------------------------ 复制
def copy_iso(iso_path, target_root, progress=None):
    """把 ISO 复制到目标盘根目录，返回落地路径"""
    name = os.path.basename(iso_path)
    dst = os.path.join(target_root, name)
    total = os.path.getsize(iso_path)
    done = 0
    t0 = __import__("time").time()
    with open(iso_path, "rb") as fi, open(dst, "wb") as fo:
        while True:
            buf = fi.read(4 * 1024 * 1024)
            if not buf:
                break
            fo.write(buf)
            done += len(buf)
            if progress:
                speed = done / max(1e-6, __import__("time").time() - t0)
                progress(done, total, speed)
    return dst


# ------------------------------------------------------------------ GUI
def run_gui(iso_path):
    import tkinter as tk
    from tkinter import ttk, filedialog, messagebox

    root = tk.Tk()
    root.title(f"{APP_NAME} v{APP_VER}")
    root.geometry("720x520")
    root.minsize(680, 480)

    style = ttk.Style()
    try:
        style.theme_use("vista")
    except Exception:
        pass

    head = tk.Frame(root, bg="#0d1117")
    head.pack(fill="x")
    tk.Label(head, text="  JTermOS", bg="#0d1117", fg="#00e6a0",
             font=("Consolas", 20, "bold")).pack(side="left", pady=10)
    tk.Label(head, text=f"安装程序 v{APP_VER}   ·   把 ISO 镜像复制到目标磁盘",
             bg="#0d1117", fg="#8fa3bf", font=("Microsoft YaHei UI", 10)).pack(side="left", pady=10)

    body = ttk.Frame(root, padding=14)
    body.pack(fill="both", expand=True)

    # 源镜像
    src = ttk.LabelFrame(body, text="源镜像", padding=10)
    src.pack(fill="x")
    var_iso = tk.StringVar(value=iso_path or "")
    ent = ttk.Entry(src, textvariable=var_iso, state="readonly")
    ent.pack(side="left", fill="x", expand=True)

    def browse():
        p = filedialog.askopenfilename(title="选择 JTermOS ISO", filetypes=[("ISO 镜像", "*.iso"), ("所有文件", "*.*")])
        if p:
            var_iso.set(p)

    ttk.Button(src, text="浏览…", command=browse).pack(side="left", padx=(8, 0))

    # 磁盘列表
    lst = ttk.LabelFrame(body, text="目标磁盘（选一个）", padding=10)
    lst.pack(fill="both", expand=True, pady=(12, 0))
    cols = ("id", "type", "label", "size", "free", "fs")
    tv = ttk.Treeview(lst, columns=cols, show="headings", height=8, selectmode="browse")
    for c, t, w in (("id", "盘符", 90), ("type", "类型", 100), ("label", "卷标", 140),
                    ("size", "总容量", 110), ("free", "剩余", 110), ("fs", "文件系统", 100)):
        tv.heading(c, text=t)
        tv.column(c, width=w, anchor="center" if c in ("id", "type", "size", "free", "fs") else "w")
    tv.pack(fill="both", expand=True, side="left")
    sb = ttk.Scrollbar(lst, orient="vertical", command=tv.yview)
    sb.pack(side="right", fill="y")
    tv.configure(yscrollcommand=sb.set)

    vols = []

    def refresh():
        nonlocal vols
        tv.delete(*tv.get_children())
        try:
            vols = list_volumes()
        except Exception as e:
            messagebox.showerror(APP_NAME, f"读取磁盘失败：{e}")
            return
        for v in vols:
            tv.insert("", "end", values=(v["id"], v["type_name"], v["label"] or "—",
                                         human(v["size"]), human(v["free"]), v["fs"] or "—"))
        if vols:
            tv.selection_set(tv.get_children()[0])

    ttk.Button(lst, text="刷新", command=refresh).pack(side="bottom", anchor="e", pady=(8, 0))

    # 进度 + 操作
    bar = ttk.Progressbar(body, mode="determinate", maximum=100)
    bar.pack(fill="x", pady=(14, 4))
    status = tk.StringVar(value="就绪")
    ttk.Label(body, textvariable=status, foreground="#444").pack(anchor="w")

    btns = ttk.Frame(body)
    btns.pack(fill="x", pady=(10, 0))

    def do_install():
        iso = var_iso.get().strip()
        if not iso or not os.path.isfile(iso):
            messagebox.showerror(APP_NAME, "请先选择 JTermOS 的 ISO 镜像文件。")
            return
        sel = tv.selection()
        if not sel:
            messagebox.showwarning(APP_NAME, "请先在列表里选一个目标磁盘。")
            return
        idx = tv.index(sel[0])
        v = vols[idx]
        need = os.path.getsize(iso)
        if v["free"] and v["free"] < need:
            messagebox.showerror(APP_NAME, f"目标盘剩余空间不足。\n需要 {human(need)}，可用 {human(v['free'])}。")
            return
        ok = messagebox.askyesno(
            "确认安装",
            f"即将把镜像复制到：\n\n"
            f"    磁盘：{v['id']}  {v['label'] or ''}  ({v['type_name']})\n"
            f"    容量：{human(v['size'])}    剩余：{human(v['free'])}\n"
            f"    文件：{os.path.basename(iso)}  ({human(need)})\n\n"
            f"只复制文件，不会分区或格式化。是否继续？")
        if not ok:
            status.set("已取消")
            return
        btn_go.config(state="disabled")
        bar["value"] = 0

        def worker():
            try:
                def prog(done, total, speed):
                    pct = done * 100.0 / max(1, total)
                    root.after(0, lambda: (bar.configure(value=pct),
                                           status.set(f"复制中 {pct:5.1f}%   {human(done)}/{human(total)}   {human(speed)}/s")))
                dst = copy_iso(iso, v["id"] + "\\", progress=prog)
                root.after(0, lambda: (bar.configure(value=100),
                                       status.set("完成 ✔"),
                                       messagebox.showinfo(APP_NAME,
                                                           f"安装完成！\n\n镜像已复制到：\n{dst}\n\n"
                                                           f"现在可以用它制作启动盘或分发给别人了。")))
            except Exception as e:
                root.after(0, lambda: (status.set("失败"),
                                       messagebox.showerror(APP_NAME, f"复制失败：{e}")))
            finally:
                root.after(0, lambda: btn_go.config(state="normal"))

        import threading
        threading.Thread(target=worker, daemon=True).start()

    btn_go = ttk.Button(btns, text="开始安装", command=do_install)
    btn_go.pack(side="right")
    ttk.Button(btns, text="退出", command=root.destroy).pack(side="right", padx=(0, 8))

    refresh()
    root.mainloop()


# ------------------------------------------------------------------ CLI
def run_cli(iso_path):
    print(f"\n{APP_NAME} v{APP_VER}")
    print("=" * 52)
    if not iso_path or not os.path.isfile(iso_path):
        print("未找到 JTermOS ISO，请用 --iso 指定路径。")
        return 1
    print(f"源镜像：{iso_path}  ({human(os.path.getsize(iso_path))})\n")
    vols = list_volumes()
    if not vols:
        print("未发现可写磁盘。")
        return 1
    print("可用磁盘：")
    for i, v in enumerate(vols, 1):
        mark = " ★" if v["removable"] else ""
        print(f"  [{i}] {v['id']:<4} {v['type_name']:<8} {v['label'] or '—':<12} "
              f"总 {human(v['size']):>9}  剩余 {human(v['free']):>9}{mark}")
    try:
        n = int(input("\n选择目标磁盘编号: ").strip())
        v = vols[n - 1]
    except Exception:
        print("无效选择。")
        return 1
    c = input(f"确认把镜像复制到 {v['id']} ({v['label'] or v['type_name']})？输入 yes 继续: ").strip().lower()
    if c != "yes":
        print("已取消。")
        return 1
    print("复制中…")

    def prog(done, total, speed):
        pct = done * 100.0 / max(1, total)
        sys.stdout.write(f"\r  {pct:5.1f}%  {human(done)}/{human(total)}  {human(speed)}/s")
        sys.stdout.flush()

    dst = copy_iso(iso_path, v["id"] + "\\", progress=prog)
    print(f"\n完成 ✔  已复制到 {dst}")
    return 0


# ------------------------------------------------------------------ main
def main():
    ap = argparse.ArgumentParser(description=f"{APP_NAME} v{APP_VER}")
    ap.add_argument("--iso", help="指定 JTermOS ISO 路径")
    ap.add_argument("--cli", action="store_true", help="使用命令行界面")
    args = ap.parse_args()

    iso = find_iso(args.iso)

    if args.cli:
        return run_cli(iso)
    try:
        run_gui(iso)
        return 0
    except Exception as e:
        print(f"[!] 图形界面不可用（{e}），改用命令行。")
        return run_cli(iso)


if __name__ == "__main__":
    sys.exit(main())
