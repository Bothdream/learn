#!/usr/bin/env bash
# 监控 100 台服务器磁盘利用率脚本
# /^[^#]/ 匹配非 # 开头的行
# /^\/dev/ 匹配以/dev开头的行
# $NF 代表最后一列
# BEGIN{OFS="="} 每一行输出的列用=拼接
# -v ip=$IP 将外部变量传入到awk表达式中
# ${变量#关键字} 如果变量内容从头向尾的数据符合"关键字"，则将符合的最短数据删除
# ${变量%关键字} 如果变量内容从尾向前的数据符合"关键字"，则将符合的最短数据删除

HOST_INFO=./host.info
for IP in $(awk '/^[^#]/{print $1}' $HOST_INFO); do
    USER=$(awk -v ip=$IP 'ip==$1{print $2}' $HOST_INFO)
    PORT=$(awk -v ip=$IP 'ip==$1{print $3}' $HOST_INFO)
    TMP_FILE=/tmp/disk.tmp
    ssh -p $PORT $USER@$IP 'df -h' >$TMP_FILE
    USE_RATE_LIST=$(awk 'BEGIN{OFS="="}/^\/dev/{print $NF,int($5)}' $TMP_FILE)
    for USE_RATE in $USE_RATE_LIST; do
        USE_NAME=${USE_RATE%=*}
        USE_RATE=${USE_RATE#*=}
        if [ $USE_RATE -gt 80 ]; then
            echo "Warning: $USE_NAME Partition usage $USE_RATE%!"
        fi
    done
done
