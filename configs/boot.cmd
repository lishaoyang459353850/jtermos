# U-Boot boot.cmd（备选启动方式）
# 由 mkimage 编译成 boot.scr

setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootfstype=squashfs ro rootwait loglevel=3 quiet

load mmc 0:1 ${kernel_addr_r} Image.gz
load mmc 0:1 ${fdt_addr_r} __BOARD_DTB__

booti ${kernel_addr_r} - ${fdt_addr_r}