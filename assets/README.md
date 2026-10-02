# 开机画面资源

| 文件 | 说明 |
|---|---|
| `grub_logo.png` | GRUB 启动画面（1024×768，深色渐变 + 终端窗口图标 + JTermOS 字样 + v1.0 beta1 徽标）。由 `scripts/make_assets.py` 生成，输出可复现。 |
| `banner.ansi` | 控制台彩色块字横幅 `JTERMOS`，开机时由 `rcS` 输出到终端。仓库里以 base64 存放（`banner.ansi.b64`），避免终端转义字符在传输中被改写。 |

## 生成 / 还原

```bash
# 1) 生成 GRUB 启动图（需要 Pillow + DejaVu 字体）
python3 scripts/make_assets.py

# 2) 还原控制台横幅
base64 -d assets/banner.ansi.b64 > assets/banner.ansi
```

Windows PowerShell：

```powershell
[IO.File]::WriteAllBytes("assets\banner.ansi", [Convert]::FromBase64String((Get-Content assets\banner.ansi.b64 -Raw)))
```

## 它们怎么被用到

- `grub_logo.png` → 构建时复制为 ISO 内 `/boot/grub/logo.png`，由 `configs/grub.cfg` 的 `background_image` 加载。
- `banner.ansi` → 构建时复制为 rootfs 内 `/etc/jterm-banner.txt`，由 `/etc/init.d/rcS` 在启动时 `cat` 到控制台。
