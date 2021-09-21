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
[root@localhost ~]# firewall-cmd --reload  # 重启防火墙
[root@localhost ~]# firewall-cmd --zone=public --list-ports 查看防火墙所有开放的端口
```

