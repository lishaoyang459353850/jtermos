#!/usr/bin/env python3
# 生成开机画面资源：GRUB splash 图 + 控制台 ASCII 横幅
import os
from PIL import Image, ImageDraw, ImageFont

OUT = "assets"
os.makedirs(OUT, exist_ok=True)
MONO_B = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"
SANS_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
CJK = "/usr/share/fonts/truetype/arphic/uming.ttc"
if not os.path.exists(CJK):
    for cand in ["/usr/share/fonts/truetype/arphic/ukai.ttc",
                 "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc"]:
        if os.path.exists(cand): CJK = cand; break

W, H = 1024, 768
BG_TOP = (9, 13, 22); BG_BOT = (16, 26, 44)
ACCENT = (0, 230, 160)      # 青绿
ACCENT2 = (90, 170, 255)    # 蓝
TXT = (232, 238, 248)

img = Image.new("RGB", (W, H), BG_TOP)
d = ImageDraw.Draw(img)
# 竖向渐变背景
for y in range(H):
    t = y / (H - 1)
    d.line([(0, y), (W, y)], fill=(int(BG_TOP[0]+(BG_BOT[0]-BG_TOP[0])*t),
                                  int(BG_TOP[1]+(BG_BOT[1]-BG_TOP[1])*t),
                                  int(BG_TOP[2]+(BG_BOT[2]-BG_TOP[2])*t)))
# 顶部一条强调线
d.rectangle([0, 0, W, 6], fill=ACCENT)

# ---- 终端窗口图形标志 ----
bx0, by0, bx1, by1 = 322, 132, 702, 372
d.rounded_rectangle([bx0+6, by0+8, bx1+6, by1+8], radius=16, fill=(0, 0, 0))
d.rounded_rectangle([bx0, by0, bx1, by1], radius=16, fill=(22, 30, 46), outline=(52, 66, 92), width=2)
d.rounded_rectangle([bx0, by0, bx1, by0+40], radius=16, fill=(32, 42, 62))
d.rectangle([bx0, by0+24, bx1, by0+40], fill=(32, 42, 62))
for i, c in enumerate([(255, 95, 86), (255, 189, 46), (39, 201, 63)]):
    cx = bx0 + 24 + i*24
    d.ellipse([cx-8, by0+13, cx+8, by0+29], fill=c)
f_mono = ImageFont.truetype(MONO_B, 40)
d.text((bx0+28, by0+72), "JTermOS", font=f_mono, fill=ACCENT)
d.text((bx0+28, by0+128), "> _", font=ImageFont.truetype(MONO_B, 26), fill=ACCENT2)
d.rectangle([bx0+86, by0+128, bx0+100, by0+156], fill=ACCENT2)

# ---- 主标题 ----
f_big = ImageFont.truetype(SANS_B, 84)
title = "JTermOS"
tb = d.textbbox((0, 0), title, font=f_big)
d.text(((W-(tb[2]-tb[0]))//2, 430), title, font=f_big, fill=TXT)
# 副标题
f_sub = ImageFont.truetype(MONO_B, 26)
sub = "Lightweight Linux Terminal System"
sb = d.textbbox((0, 0), sub, font=f_sub)
d.text(((W-(sb[2]-sb[0]))//2, 545), sub, font=f_sub, fill=(150, 170, 200))
# 版本徽标
f_ver = ImageFont.truetype(MONO_B, 22)
ver = "v1.0  beta1"
vb = d.textbbox((0, 0), ver, font=f_ver)
vx = (W-(vb[2]-vb[0]))//2
d.rounded_rectangle([vx-18, 606, vx+(vb[2]-vb[0])+18, 654], radius=24,
                    fill=(20, 40, 40), outline=ACCENT, width=2)
d.text((vx, 612), ver, font=f_ver, fill=ACCENT)
# 底部提示
f_tip = ImageFont.truetype(MONO_B, 20)
tip = "Booting ...  kernel log follows"
tb2 = d.textbbox((0, 0), tip, font=f_tip)
d.text(((W-(tb2[2]-tb2[0]))//2, 700), tip, font=f_tip, fill=(110, 130, 160))

img.save(f"{OUT}/grub_logo.png", "PNG")
print("[+] assets/grub_logo.png", os.path.getsize(f"{OUT}/grub_logo.png"), "bytes", img.size)

# ---- 控制台 ASCII 横幅（块字） ----
GLYPH = {
 "J": ["...##", "...##", "...##", "##.##", ".###."],
 "T": ["#####", "..#..", "..#..", "..#..", "..#.."],
 "E": ["#####", "#....", "####.", "#....", "#####"],
 "R": ["####.", "#...#", "####.", "#..#.", "#...#"],
 "M": ["#...#", "##.##", "#.#.#", "#...#", "#...#"],
 "O": [".###.", "#...#", "#...#", "#...#", ".###."],
 "S": [".####", "#....", ".###.", "....#", "####."],
 " ": ["..", "..", "..", "..", ".."],
}
def render(word, on="#", off=" "):
    rows = ["" for _ in range(5)]
    for ch in word:
        g = GLYPH.get(ch, GLYPH[" "])
        for i in range(5):
            rows[i] += g[i].replace("#", on).replace(".", off) + off
    return rows
lines = render("JTERMOS")
inner = max(len(l) for l in lines)
bar = "=" * (inner + 6)
art = ["+" + bar + "+"]
for l in lines:
    art.append("|  " + l.ljust(inner) + "  |")
art.append("+" + bar + "+")
open(f"{OUT}/banner.txt", "w").write("\n".join(art) + "\n")
print("[+] assets/banner.txt")
print("\n".join(art))
