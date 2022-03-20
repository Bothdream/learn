#!/usr/bin/expect
# ping 多个主机是否通
# &>/dev/null 把输出定位到垃圾池
# >connect.log 清除文件
# {}& 将for循环体放在后台执行
# wait 会等待所有后台程序执行完以后才继续往后执行
>connect.log
HOST_INFO=./host.info
IP_LIST=$(awk '/^[^#]/{print $1}' $HOST_INFO)
for IP in $IP_LIST; do
    {
        ping -c1 -W1 $IP &>/dev/null
        if [ $? -eq 0 ]; then
            echo $IP >>connect.log
            echo -e "$IP is up"
        fi
    } &
done
wait
echo "success"
