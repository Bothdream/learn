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
date                       #显示日期和时间
cal                        #显示日历
bc                         #简易计算器
ls [-a -l -h ]             #显示目录
mkdir -p                   #递归创建目录或文件  
ll -lt                     #按更改时间降序显示文件或目录
cp                         #复制文件
rm                         #删除文件
mv                         #移动或重命名文件
rmdir                      #删除目录
touch                      #新建文件
2、文件操作
cat -b                     #由第一行开始显示文件的内容
nl                         #显示的文件加上行号
less                       #一页一页显示文件，支持前后翻页
head [-n number]           #只看前几行数据
tail [-n number]           #只看后几行数据
tail -f /var/auth.log      #实时打印日志
which -a(所有)              #查找可执行的文件
whereis <名字>              #在特定的目录中寻找文件或目录名
rpm -qa | grep java        #查看一个包是否安装
passwd [root]              #修改后台登录密码  
find / -name nginx.conf    #在根目录下查找名为nginx.conf的目录或文件
find /var | xargs grep 日志 #全局查找，并执行过滤
```

# 三、常用shell脚本整理

1、防火墙命令

```sh
# 查看并杀掉指定进程
ps -ef | grep 'nginx' | grep -v grep | awk '{print $2}' | xargs kill -s 9
# 防火墙相关命令
systemctl status firewalld    #查看防火墙的运行状态
systemctl start firewalld     #开启防火墙
systemctl stop firewalld      #暂时关闭防火墙
systemctl disable firewalld   #永久关闭防火墙
systemctl restart firewalld   #重启防火墙
firewall-cmd --query-port=3306/tcp  # 查看3306端口是否开启
firewall-cmd --zone=public --add-port=3306/tcp --permanent  # 开启3306端口
firewall-cmd --reload  # 重启防火墙
firewall-cmd --zone=public --list-ports #查看防火墙所有开放的端口
```

2、判断shell变量是否为空字符串

shell 中利用 -n 来判定字符串非空。

```shell
if [ str1 = str2 ]　　　　　  #当两个串有相同内容、长度时为真 
if [ str1 != str2 ]　　　　　 #当串str1和str2不等时为真 
if [ -n str1 ]　　　　　　    #当串的长度大于0时为真(串非空) 
if [ -z str1 ]　　　　　　　  #当串的长度为0时为真(空串) 
if [ str1 ]　　　　　　　　   #当串str1为非空时为真
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

5、远程拷贝命令(scp和rsync)

(1)scp

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

(2)rsync

用法：

A. **rsync [OPTION]... SRC [SRC]... DEST**      

本地将多个文件同步到本地目的目录

```
rsync -v ts.sh nginx.conf ./tmp/
```

B. **rsync [OPTION]... SRC [SRC]... [USER@]HOST:DEST**

推模式：将本地多个文件同步推到远程主机目的目录

```
rsync -v ts.sh nginx.conf root@192.168.137.13:~/tmp/
```

C.**rsync [OPTION]... [USER@]HOST:SRC [DEST]**

拉模式：将远程源文件拉到本地

```
rsync -avzt root@192.168.137.13:~/lsf ./zsq/
```

注意：

 **源路径如果是一个目录的话：**

**a.不带尾随斜线表示的是整个目录包括目录本身，**

**b.带上尾随斜线表示的是目录中的文件，不包括目录本身。** 

D.常用参数

-v  显示rsync过程中的详细信息

-P 显示文件传输的进度信息

-a 归档模式，表示递归传输并保持文件属性，等同于 “-rtopgDl”

-z 传输时进行压缩提高效率

-e 指定所使用的远程shell程序，默认为shell

**最常用选项组合是“-avz”，即压缩和显示部分信息，并以归档模式传输。**

(3)scp与rsync的区别

一般使用rsync进行远程同步或拷贝。rsync和scp的区别在于：

 		A.rsync只对差异文件做更新，可以做增量或全量备份；而scp只能做全量备份。rsync只传修改了的部分，如果改动较小就不需要全部重传，故rsync备份速度较快；默认情况下，rsync 通过比较文件的最后修改时间（mtime）和文件的大小（size）来确认哪些文件需要被同步过去。
 		B.rsync是分块校验+传输，scp是整个文件传输。rsync比scp有优势的地方在于单个大文件的一小部分存在改动时，只需传输改动部分，无需重新传输整个文件。 如果传输一个新的文件，理论上rsync没有优势；
 		C.rsync不是加密传输，而scp是加密传输，使用时可以按需选择。

6、JAVA打包命令

```shell
mvn clean                 #删除包
mvn formatter:format      # 格式化代码
mvn formatter：validate    # 校验代码格式
mvn clean package -T 2C    # 删除包，然后使用多核构建 -T 线程
mvn compile               # 编译代码
mvn test-compile          #编译测试代码
mvn test                  # 运行测试代码
# 安装包，并将包打包到本地maven仓库，跳过单元测试，跳过代码格式化，跳过pmd检测
mvn install -DskipTests -Dformatter.skip -Dpmd.skip
# 打包，并跳过单元测试，跳过代码格式化，跳过pmd检测
mvn package -am -DskipTests -Dformatter.skip -Dpmd.skip
# 打指定的包
mvn clean package -pl=ngsoc-common,ngsoc-auth -am -DskipTests -Dformatter.skip -Dpmd.skip
#将jar打包到本地仓库
mvn install:install-file -Dfile=test.jar -DgroupId=com -DartifactId=dingdindId -Dversion=1.0 -Dpackaging=jar
```

7、查看端口占用

```shell
#Linux 环境
lsof -i                             #查看所有端口占用情况
lsof -i:8080                        #查看8080端口占用情况
netstat -tunpl | grep 8080          #查看8080端口占用情况
#Window环境
tasklist                            #windows下查看所有进程
netstat -ano | findstr "8080"       #windows 查看端口占用情况
taskkill -t -f -im 3576             #windows下kill进程
```

8、服务管理命令

```shell
#基础命令
systemctl status [service-unit]         #查看服务运行状态
systemctl start [service-unit]          #开启服务
systemctl stop [service-unit]           #关闭服务
systemctl restart [service-unit]        #重启服务
#高级命令
systemctl list-units --all --type=service # 列出系统所有服务
# 过滤出某几个服务
systemctl list-units --all --type=service | grep 'auth \| portal'
journalctl -u futurex-auth-api.service   # 查看systemctl的启动日志
#如果新安装了一个服务，归属于systemctl管理，要使新服务的服务程序配置文件生效，需重新加载。
systemctl daemon-reload                  # 重新加载某个服务的配置文件
```

9、大小写互转

```shell
UPPERCASE=$(echo $VARIABLE | tr '[a-z]' '[A-Z]')  #VARIABLE变量的值小写转换成大写
LOWERCASE=$(echo $VARIABLE | tr '[A-Z]' '[a-z]')  #VARIABLE变量的值大写转换成小写
```

10、tar 解压时用户、用户组和时间改变

​		tar解压时会默认指定参数--same-owner，即打包的时候是谁的，解压后就给谁。如果在解压时指定参数（即tar --no-same-owner -zxvf xxxx.tar.gz），则会将执行该tar命令的用户作为解压后的文件目录的所有者。
-m或--modification-time 还原文件时，不变更文件的更改时间。
解决办法：

```shell
tar --no-same-owner -mzxvf xxxx.tar.gz
```

11、**#!／bin／sh   -e**  与  **#!／bin／sh**   的区别

​		shell脚本必须以**#!/bin/sh**开始，每条指令执行后，需要用**#?**去判断返回值，零执行正常，非零执行失败。故需要手动判断程序执行结果来决定程序是否退出。

​		**#!/bin/sh -e** 则不用去判读每个命令是否执行成功，系统会判断只要出现一个执行返回非零，则自动退出。

12、CentOS7 systemd Type=simple和 Type=forking的区别

​		(1)使用Type=forking时，要求ExecStart启动的命令自身就是以daemon模式运行的。而以daemon模式运行的进程都有一个特性：总是会有一个瞬间退出的中间父进程。
​		例如，nginx命令默认以daemon模式运行，所以可直接将其配置为forking类型。
​		(2)Type=simple是一种最常见的通过systemd服务系统运行用户自定义命令的类型，也是省略Type指令时的默认类型。Type=simple类型的服务只适合那些在shell下运行在前台的命令。也就是说，当一个命令本身会以daemon模式运行时，将不能使用simple，而应该使用Type=forking。比如ls命令、sleep命令、非daemon模式运行的nginx进程以及那些以前台调试模式运行的进程，在理论上都可以定义为simple类型的服务。

13、Linux下配置远程免密登录方式

(1).用户名+密码
(2).密钥验证
A.机器1生成密钥对并将公钥发给机器2，机器2将公钥保存。
B.机器1要登录机器2时，机器2生成随机字符串并用机器1的公钥加密后，发给机器1。
C.机器1用私钥将其解密后发回给机器2，验证成功后登录

配置成功以后则可以通过以下命令免密登录或执行脚本。

```shell
ssh -o StrictHostKeyChecking=no #SSH免密码登陆避免首次需要输入yes
ssh -o StrictHostKeyChecking=no root@$REMOTE "$DEPLOY_HOME/update.sh"
```

14、查看系统CPU个数

​		当平均负载大于系统CPU个数，则系统出现了负载。一般当系统负载高于系统CPU个数的70%时，就应该排查系统负载的问题。

```sh
grep 'model name' /proc/cpuinfo | wc -l    # 查看CPU个数
lscpu                                      # 查看CPU个数
uptime                                     # 查看平均负载
```

15、代码片段

(1)生效环境变量

```shell
. /usr/local/sir/deploy/env/$APP.env "$APP"
```

(2)判断上一条脚本执行是否报错

```shell
if [[ $? -ne 0 ]]; then
    echo "call fail"
    exit 1
fi
```

(3)判断目录是否存在

```shell
if [[ ! -d ./jenkins ]]; then
    mkdir -p ./jenkins
fi
```

(4) 判断文件是否存在

```shell
if [[ -f "./xjar" ]]; then
    mv ./xjar ./xjar.backup
fi
```

(5)建立软链接

```shell
ln -fs $NEW_JAR_NAME $ORIGIN_JAR_NAME
```

(6)生成模板脚本

```shell
#!/bin/bash

# 生效环境变量(APP_HOME、DEPLOY_HOME、ARTIFACT、APP_SERVICE)，从$APP.env文件中读取
. /usr/env/$APP.env "$APP"

# 生成文件，并执行相关脚本的命令，替换变量
cat <<EOF > update.sh
#!/bin/bash

APP_HOME=${APP_HOME}
APP_JAR=${DEPLOY_HOME}\`basename ${ARTIFACT}`
APP_SERVICE=${APP_SERVICE}

EOF
# 定义好模板文件update.sh.tpl，并将内容直接打印到update.sh
cat ./update.sh.tpl >> update.sh
# 查看最终生成的模板脚本
cat ./update.sh
# 执行生成的模板脚本，验证是否符合预期
sh update.sh
```

