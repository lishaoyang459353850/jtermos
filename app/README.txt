# 把你的 Java 应用 jar 放到这里，命名为 app.jar

构建前：
  cp /path/to/your-app.jar app/app.jar

build.sh 会自动：
  1. 用 jdeps 分析它的模块依赖
  2. 用 jlink 裁剪出只含所需模块的 JRE
  3. 把 app.jar 安装到 rootfs/opt/jterm/app/
  4. 由 /etc/init.d/S99jterm 自动启动