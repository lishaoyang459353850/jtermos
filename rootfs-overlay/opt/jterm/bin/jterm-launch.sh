#!/bin/sh
# /opt/jterm/bin/jterm-launch.sh
echo $$ > /run/jterm.pid

JAVA=/opt/jterm/jre/bin/java
APP_JAR=/opt/jterm/app/app.jar
LOG_DIR=/var/log/jterm
mkdir -p "$LOG_DIR"

JAVA_OPTS="
  -Xms32m
  -Xmx96m
  -XX:+UseSerialGC
  -XX:MaxMetaspaceSize=48m
  -XX:CompressedClassSpaceSize=16m
  -XX:MaxDirectMemorySize=16m
  -XX:TieredStopAtLevel=1
  -XX:ReservedCodeCacheSize=16m
  -Djava.io.tmpdir=/tmp
  -Duser.timezone=Asia/Shanghai
  -Dfile.encoding=UTF-8
  -Djava.security.egd=file:/dev/./urandom
"

MAX_RESTART=5
RESTART_WINDOW=60
BACKOFF=60

count=0
window_start=$(date +%s)

while true; do
    now=$(date +%s)
    if [ $((now - window_start)) -gt $RESTART_WINDOW ]; then
        window_start=$now
        count=0
    fi
    count=$((count+1))
    if [ $count -gt $MAX_RESTART ]; then
        echo "[$(date)] too many restarts, sleep ${BACKOFF}s" >> "$LOG_DIR/crash.log"
        sleep $BACKOFF
        count=0
    fi
    echo "[$(date)] starting java ..." >> "$LOG_DIR/stdout.log"
    $JAVA $JAVA_OPTS -jar "$APP_JAR" >> "$LOG_DIR/stdout.log" 2>&1
    rc=$?
    echo "[$(date)] java exited code=$rc" >> "$LOG_DIR/crash.log"
    if [ $rc -eq 143 ] || [ $rc -eq 0 ]; then
        exit 0
    fi
    sleep 1
done