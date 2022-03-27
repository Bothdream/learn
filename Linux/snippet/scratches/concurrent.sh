#!/usr/bin/env bash
# shell 多进程并发
>connect.log
CONCURRENT_NUM=10
FIFO=/tmp/fifo.$$
mkfifo "$FIFO" && exec 8<> "$FIFO" && rm -f "$FIFO"
for i in $(seq $CONCURRENT_NUM) ; do
    echo "connect" 1>&8
done
for i in {1..200} ; do
    read -u 8
    {
        echo -e "-- current loop:[cmd id:$i ; fifo id: $REPLY]"
        IP=192.168.137.$i
        ping -c1 -W1 $IP &>/dev/null
        if [ $? -eq 0 ]; then
            echo $IP >>connect.log
            echo "$IP is up"
        else
            echo "$IP is down"
        fi
        sleep 1
        echo "connect" 1>&8
    } &
done
wait
exec 8<&-
echo "success"