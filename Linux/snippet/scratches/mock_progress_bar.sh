#!/usr/bin/env bash
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="$(tput sgr0)"
function progress_bar() {
    while true; do
        echo -n -e "${RED}#"
        sleep 0.1
    done
}
progress_bar &
# $! 获取前一个后台进程ID，即：[progress_bar &] 进程PID
pid=$!
##########################
#处理业务的脚本，放置此处
sleep 3
##########################
# 业务代码执行完成以后，便杀掉后台进程
kill -9 $pid
echo -e "${RESET}"
echo -e "${GREEN}操作成功${RESET}"