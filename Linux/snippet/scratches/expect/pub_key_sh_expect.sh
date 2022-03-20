#!/usr/bin/env bash
#!/usr/bin/env bash
### 远程推送公钥

>connect.log
# 判断ssh相关认证文件是否安装
if [ ! -f ~/.ssh/id_rsa ] || [ ! -f ~/.ssh/id_rsa.pub ]; then
    ssh-keygen -t rsa -q -P "" -f ~/.ssh/id_rsa
fi
# 判断expect是否安装
expect -v &>/dev/null
if [ $? -ne 0 ]; then
    yum -y install expect
fi
HOST_INFO=./host.info
IP_LIST=$(awk '/^[^#]/{print $1}' $HOST_INFO)
for IP in $IP_LIST; do
    {
        USER_NAME=$(awk -v ip=$IP 'ip==$1{print $2}' $HOST_INFO)
        PORT=$(awk -v ip=$IP 'ip==$1{print $4}' $HOST_INFO)
        PASSWORD=$(awk -v ip=$IP 'ip==$1{print $3}' $HOST_INFO)
        ping -c1 -W1 $IP &>/dev/null
        if [ $? -eq 0 ]; then
            echo $IP >>connect.log
            expect pub_key_expect.sh.sh $IP $USER_NAME $PORT $PASSWORD &>/dev/null
        fi
    } &
done
echo "公钥推送中..."
wait
echo "公钥推送结束"
