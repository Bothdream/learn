# 一、CPU架构

```shell
CPU架构：精简指令集和复杂指令集
1、精简指令集
设计理念:每个指令集较为精简，每个指令的运行时间都很短，完成的动作很单纯，执行效能较佳；
但是要做复杂的事情，需要多个指令来完成。
应用领域:常用于学术领域的大型工作站。
典型案例：ARM架构
2、复杂指令集
设计理念:每个小指令可以执行一些较为低阶的硬件操作，指令数目多而且复杂。因为指令执行较为复杂
所以每条指令花费的时间较长，但每条个别指令可以处理的工作较为丰富。
应用领域:个人计算机
典型案例:x86架构
```

# 二、简单命令

```shell
1、常用命令
date     显示日期和时间
cal      显示日历
bc       简易计算器
ls [-a -l -h ] 显示目录
mkdir -p  递归创建目录或文件  
ll 
cp       复制文件
rm       删除文件
mv       移动或重命名文件
rmdir    删除目录
touch    新建文件
2、文件操作
cat -b                 由第一行开始显示文件的内容
nl                     显示的文件加上行号
less                   一页一页显示文件，支持前后翻页
head [-n number]       只看前几行数据
tail [-n number]       只看后几行数据
which -a(所有)          查找可执行的文件
whereis <名字>          在特定的目录中寻找文件或目录名
```

# 九十、常用shell脚本片段

```sh
1、查看并杀掉指定进程
ps -ef | grep 'nginx' | grep -v grep | awk '{print $2}' | xargs kill -s 9
2、防火墙相关命令
[root@localhost ~]# systemctl status firewalld    查看防火墙的运行状态
[root@localhost ~]# systemctl start firewalld     开启防火墙
[root@localhost ~]# systemctl stop firewalld      关闭防火墙
[root@localhost ~]# systemctl restart firewalld   重启防火墙
[root@localhost ~]# firewall-cmd --query-port=3306/tcp  # 查看3306端口是否开启
[root@localhost ~]# firewall-cmd --zone=public --add-port=3306/tcp --permanent  # 开启3306端口
[root@localhost ~]# firewall-cmd --reload  # 重启防火墙
[root@localhost ~]# firewall-cmd --zone=public --list-ports 查看防火墙所有开放的端口
```

2、判断shell变量是否为空字符串

shell 中利用 -n 来判定字符串非空。

```shell
if [ str1 = str2 ]　　　　　  当两个串有相同内容、长度时为真 
if [ str1 != str2 ]　　　　　 当串str1和str2不等时为真 
if [ -n str1 ]　　　　　　 当串的长度大于0时为真(串非空) 
if [ -z str1 ]　　　　　　　 当串的长度为0时为真(空串) 
if [ str1 ]　　　　　　　　 当串str1为非空时为真
```

注意：对于变量判断是否为空，需要用双引号包括判断。因为不加“”时该if语句等效于if [ -n ]，shell 会把它当成if [ str1 ]来处理，-n自然不为空，所以为正。

正确用法：if [ -n "$param"]

3、判断一个变量值或者字符串是否为整数

（1）利用expr做计算时变量或字符串必须是整数的规则，把一个变量或字符串和一个已知的整数（非0）相加，看命令返回的值是否为0.如果为0，就认为加法的变量或字符串为整数，否则就不是。

```shell
i=5
expr $I + 6 &>/dev/null
echo $?
```

如果输出的是0，那么表明i是整数，反之则表示为非整数。其中$?表示的是最后运行的代码的返回值

上述判断中，有&>表示的就是不管是什么，都重定向到/dev/null中。

（2）使用sed加正则表达式

思路：删除一个字符串中的所有数字，看字符串的长度是否为0，如果不为0，则不是整数。

```shell
if [ -n "`echo char | sed 's/[0-9]//g'`" ]  
then
	echo "char"
else
	echo "number"
fi
```

（3）用变量的子串替换

思路：如果num的长度不为0，并且把num中的非数字部分删除，然后看结果是不是等于num本身，如果两者成立，那么就是数字，反之亦然。

```shell
if [ -n "$num" -a "$num" = "${num//[^0-9]/}" ]
then
	echo "number"
else
	echo "char"
fi
```

4、ssh远程登录命令

```shell
# 远程登录
ssh root@192.168.137.12
# 远程登录并执行命令退出
ssh -v root@192.168.137.12 'script'
```

5、scp远程拷贝命令

scp [参数] [原路径] [目标路径]

-v 详细方式显示输出。显示出整个过程的调试信息。这些信息用于调试连接，验证和配置问题

-P 端口

-p 保留原文件的修改时间，访问时间和访问权限

-r 递归复制整个目录

-C 允许压缩

```shell
# 将远程文件下载到本地
scp -v -p -r -C root@192.168.137.12:~/pp ./  
# 将本地文件拷贝到远程目录
scp -v -p -r -C ./abc root@192.168.137.12:~/
```
