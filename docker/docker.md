# 一、安装docker

```sh
1、卸载docker
yum list installed | grep docker 列出当前所有docker的包
yum -y remove docker的包名称 卸载docker包
rm -rf /var/lib/docker 删除docker的所有镜像和容器
2、安装必要的软件包
yum install -y yum-utils device-mapper-persistent-data lvm2
3、配置下载的镜像仓库
yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo
yum list docker-ce --showduplicates | sort –r 列出需要安装的版本列表
4、安装指定的版本
yum install docker-ce-18.06.1.ce
5、启动docker
systemctl start docker  启动docker
systemctl enable docker 设置开机自启
systemctl restart docker 重启docker
6、添加阿里云镜像下载地址
vi /etc/docker/daemon.json
{
"registry-mirrors": ["https://zydiol88.mirror.aliyuncs.com"]
}
```

# 二、docker的基本操作命令

```sh
1、镜像命令
镜像相当于应用的安装包，在docker部署的任何应用都需要先构建为镜像
docker images     查看本地所有镜像
docker search <镜像名称> 模糊查询镜像
docker pull <镜像名称>   拉取镜像
docker rmi -f <镜像ID> 删除镜像

2、容器名称
容器：容器由镜像创建而来，容器是Docker运行应用的载体，每个应用都分别运行在Docker的每个容器中。
docker ps 只查看运行中的容器，已经停止的容器查看不到
docker ps -a 查询所有的容器，运作中和已停止的容器
docker run -i <镜像名称:标签> 运行容器（默认是前台运行）
常用参数：
-i: 前台方式运行
-d: 后台方式运行（守护式）
--name：给容器添加名称
-p: 公开容器端口给当前宿主机
-v: 挂载目录
docker exec -it <容器ID> /bin/bash  进入容器内部
docker exec -it <容器ID> /bin/sh  进入容器内部
docker start/stop/restart  <容器ID>  启动/停止/重启容器
docker rm -f <容器ID>  强制删除容器
docker logs -f <容器ID> 查看容器的启动日志
docker inspect <容器ID> 查看容器的元信息
eg: 
docker run -id -p 9000:80  nginx  启动Nginx容器，并将宿主机的9000端口暴露给Nginx的80端口使用
docker run -d -p 127.0.0.1:5001:5000/tcp redis 只允许本机的127.0.0.1访问5001端口，用于安全策略

3.Docker load 命令
导入docker镜像的命令，常用于从本地压缩包中导入docker镜像。
docker load -i my-eureka.tar
4.docker save 命令
将制定镜像保存成归档文件(.tar或.tar.gz)
[root@localhost ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
eureka              v1                  840c79acf930        8 months ago        149MB
openjdk             8-jdk-alpine        a3562aa0b991        2 years ago         105MB
[root@localhost ~]#docker save -o my-eureka.tar 840c79acf930
注意：
(1)另外还可以使用export和import命令
export和import导出的是容器的快照, 不是镜像本身, 也就是说没有layer。dockerfile里的workdir, entrypoint之类的所有东西都会丢失，commit过的话也会丢失。快照文件将丢弃所有的历史记录和元数据信息（即仅保存容器当时的快照状态），而镜像存储文件将保存完整记录，体积也更大。
(2)docker save 保存的是镜像(image)，docker export 保存的是容器(container)
(3)docker load 用来载入镜像包，docker import 用来载入容器包，但两者都会恢复为镜像
(4)docker load 不能对载入的镜像重命名，而 docker import可以为镜像指定新名称。
```

# 三、Dockerfile指令详解

1、使用Dockerfile制作微服务镜像

```shell
(1)上传Eureka微服务jar包到Linux
(2)编写Dockerfile文件
	FROM openjdk:8-jdk-alpine
	ARG JAR_FILE
	COPY ${JAR_FILE} app.jar
	EXPOSE 10086
	ENTRYPOINT ["java","-jar","/app.jar"]
(3)构建镜像
    docker build --build-arg JAR_FILE=tensquare_eureka_server-1.0-SNAPSHOT.jar -t eureka:v1 .
(4)查看镜像是否创建成功
	docker images
(5)创建容器
	docker run -i --name=eureka -p 10086:10086 eureka:v1
(6)访问容器

```

2、Dockerfile常见命令

| 命令                                | 作用                                                         |
| ----------------------------------- | ------------------------------------------------------------ |
| FROM  <imageName:tag>               | 依赖的基础镜像                                               |
| MAINTAINER <userName>               | 声明镜像的作者                                               |
| ENV key value                       | 声明环境变量（可写多条）                                     |
| RUN <command>                       | 编译时运行的脚本（可写多条）                                 |
| CMD                                 | 设置容器的启动命令                                           |
| ENTRYPOINT                          | 设置容器的入口程序                                           |
| ADD source_dir/file   dest_dir/file | 将宿主机的文件复制到容器内，如果是一个压缩文件，将会在复制后自动解压 |
| COPY source_dir/file dest_dir/file  | 和ADD相似，但是如果有压缩文件并不能解压                      |
| WORKDIR  <pathDir>                  | 设置工作目录                                                 |
| ARG                                 | 编译镜像时加入的参数                                         |
| VOLUMN                              | 设置容器的挂载卷                                             |

RUN 、CMD、ENTRYPOINT的区别

RUN：用于指定 docker build 过程中要运行的命令，即是创建 Docker 镜像（image）的步骤。

CMD：设置容器的启动命令， Dockerfile 中只能有一条 CMD 命令，如果写了多条则最后一条生效，
CMD不支持接收docker run的参数。

ENTRYPOINT：入口程序是容器启动时执行的程序， docker run 中最后的命令将作为参数传递给入口
程序 ，ENTRYPOINY类似于 CMD 指令，但可以接收docker run的参数 。

# 四、容器数据卷

容器数据卷可以将容器内的数据挂载宿主机内，可以将数据持久化到宿主机，即使容器被删除。

```sh
1、-v 参数运行docker
# 将容器中/root/zsq目录与宿主机中/root/zsq目进行挂载，并进行同步
docker run -id -v /root/zsq:/root/zsq --name zsq centos
# 查看运行容器的具体信息
docekr inspect <容器ID>
# 可以查看到如下信息：
"Mounts": [
            {
                "Type": "bind",
                "Source": "/root/zsq",
                "Destination": "/root/zsq",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ]
2、具名卷和匿名卷
# 创建匿名卷
docker run -id -v /root/test --name zsq1 centos
# 查看卷的信息
docker volume ls
# DRIVER              VOLUME NAME
# local               49408542e72b4545758b148db104b8e59d4162cbc5828562211e39a83cd567d6
# inspect 名称查看的信息
docekr inspect <容器ID> 
"Mounts": [
            {
                "Type": "volume",
                "Name": "49408542e72b4545758b148db104b8e59d4162cbc5828562211e39a83cd567d6",
                "Source": "/var/lib/docker/volumes/49408542e72b4545758b148db104b8e59d4162cbc5828562211e39a83cd567d6/_data",
                "Destination": "/root/test",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
# 创建具名卷 -v  卷名：容器内的路径
docker run -id -v zsq:/root/zsq --name zsq01  centos
# 查看卷信息
docker volume ls
# DRIVER              VOLUME NAME
# local               49408542e72b4545758b148db104b8e59d4162cbc5828562211e39a83cd567d6
docekr inspect <容器ID> 
 "Mounts": [
            {
                "Type": "volume",
                "Name": "zsq",
                "Source": "/var/lib/docker/volumes/zsq/_data",
                "Destination": "/root/zsq",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            }
        ],
# 所有的docker容器内的卷，没有指定目录的情况下，都是在/var/lib/docker/volumes目录
2、区分匿名挂载、具名挂载以及路径挂载        
-v 容器内路径             # 匿名挂载
-v 卷名:容器内路径         # 具名挂载
-v /宿主机路径:容器内路径   # 路径挂载
3、数据卷之Dockerfile
    FROM centos
	VOLUME ["vol1","vol2"]
	CMD echo "-----"
	CMD /bin/bash
# 会在容器内定义两个匿名卷vol1,vol2
```

#   五、Docker网络

```sh
1、Linux 主机ping通内部docker容器
安装docker时，就会有一个网卡docker0（桥接模式）；每启动一个docker容器，docker就会给docker容器分配一个IP。
# 查看ip和网卡信息
ip addr 
虚拟机内：
[root@localhost zsq]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:ce:c6:0f brd ff:ff:ff:ff:ff:ff
    inet 192.168.137.12/24 brd 192.168.137.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a576:7324:b0fe:6ceb/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:dc:71:e5:8d brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:dcff:fe71:e58d/64 scope link
       valid_lft forever preferred_lft forever
37: veth9fc79e4@if36: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
    link/ether 6a:94:b3:26:00:b2 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::6894:b3ff:fe26:b2/64 scope link
       valid_lft forever preferred_lft forever
39: veth803d9a5@if38: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
    link/ether 36:ce:46:5e:73:36 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::34ce:46ff:fe5e:7336/64 scope link
       valid_lft forever preferred_lft forever
容器内：
[root@localhost zsq]# docker exec -it zsq1 ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
36: eth0@if37: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
通过发现：Linux内部和docker容器内部有成对出现的网络。
# 37: veth9fc79e4@if36 与 36: eth0@if37
故Linux和docker容器是可以ping通的，这种技术叫做evth-pair技术， 它充当一个桥梁，连接各种虚拟网络设备。

网络模型图：
   ------------------------------------------------------------------------
   -   ---------------------------          ---------------------------   -    
   -   -        docker1          -          -        docker2          -   -
   -   -       172.17.0.2        -          -       172.17.0.3        -   -
   -   --------evth-pair----------          --------evth-pair----------   -
   -               ^                                    ^                 -
   -               |                                    |                 -
   -               |                                    |                 -
   -               V                                    V                 -
   -   --------evth-pair----------------------------evth-pair-----------  -
   -   -                          172.17.0.1                           -  -
   -   -                      安装docker时网卡docker                    -  -
   -   -----------------------------------------------------------------  -
   ------------------------------------------------------------------------
2、docker容器之间的网络通信
(1)通过IP访问
[root@localhost zsq]# docker exec -it zsq1 ping 172.17.0.3
PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
64 bytes from 172.17.0.3: icmp_seq=1 ttl=64 time=0.046 ms
64 bytes from 172.17.0.3: icmp_seq=2 ttl=64 time=0.054 ms
64 bytes from 172.17.0.3: icmp_seq=3 ttl=64 time=0.057 ms
# 172.17.0.2 ping 172.17.0.3 == 172.17.0.2 => 172.17.0.1 => 172.17.0.3
# 并非直连，而是通过172.17.0.1转发。
3、通过容器名字访问
[root@localhost zsq]# docker exec -it zsq2 ping zsq1
ping: zsq1: Name or service not known
# 不能访问
查看网络信息：docker network ls
[root@localhost zsq]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
910c6af01c03        bridge              bridge              local
f3d806efe8eb        host                host                local
10b1b3187482        none                null                local
# 910c6af01c03 默认的网络，桥接模式，就是docker0
查看网络的详细信息：docker network inspect <网络ID>
[root@localhost zsq]# docker network inspect 910c6a
[
    {
        "Name": "bridge",
        "Id": "910c6af01c03924ffd8bf6f18134774247e7155a47665d15a8c3fc7671101d1e",
        "Created": "2021-06-13T15:06:47.242070154+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "e7b80e2d6bf7dbd44921b3744b1d691ee94a80a3a9387a83673fe84690332360": {
                "Name": "zsq1",
                "EndpointID": "bc7c9f68fc518921546a830138f6ff01397e15258a8967c762a5c29e4fc60fba",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "f06ce857901327d319789d3204a6fe10ea5f438d6b4db2de51452de9744e3f94": {
                "Name": "zsq2",
                "EndpointID": "5eb7a4ac93ae376982de8f52167710e9fab00017be3f3b0c6089152798c5a295",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
由于docker0是默认的网络，有很多限制和局限性，如：不能通过容器名（域名）进行网络通信;故需要自定义网络来通信。
3、自定义网络
(1) 查看所有的docker网络
docker network ls
网络模式：
bridge: 桥接模式（默认），如果未指定驱动程序，则使用此网络类型。当应用程序在需要通信的独立容器中运行时，通常会使用桥接网络。

none: 不配置网络，通常与自定义网络驱动程序一起使用。 none不适用于swarm服务。

host: 和宿主机共享网络，对于独立容器，容器和Docker主机之间的网络不需要隔离，直接使用主机的网络。

overlay: 覆盖网络将多个Docker后台程序连接在一起，并使swarn服务能够相互通信。还可以使用覆盖网络来促进swarn服务和独立容器之间的通信，或者在不同Docker后台程序上的两个独立容器之间进行通信。

(2) 创建网络
docekr network create <option> <params>
--driver  网络的驱动
--subnet  子网的范围
--gateway 主网的IP
[root@localhost zsq]# docker network create --driver bridge --subnet 198.137.0.0/16 --gateway 198.137.0.1 mynet
86b72e88006b21d337697c58e958f8a65232db3c690b7c74c2e6bf5cf67de0db

[root@localhost zsq]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
910c6af01c03        bridge              bridge              local
f3d806efe8eb        host                host                local
86b72e88006b        mynet               bridge              local
10b1b3187482        none                null                local
(3)将docekr容器加入到自定义网
[root@localhost zsq]# docker run -id --name zsq1 --network mynet centos
3abc307b6be9da40863568eb1abc29ef5b0d8320d68f7a44d55dabc7350d3d9c
查看docker zsq1的网络信息
[root@localhost ~]# docker inspect zsq1
"NetworkSettings": {
            "Bridge": "",
            "SandboxID": "9e2c78253285c9a2024cce7b05704db86611066e6c5c45f78da9df8c8befe657",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/run/docker/netns/9e2c78253285",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "",
            "Gateway": "",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
            "MacAddress": "",
            "Networks": {
                "mynet": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": [
                        "3abc307b6be9"
                    ],
                    "NetworkID": "86b72e88006b21d337697c58e958f8a65232db3c690b7c74c2e6bf5cf67de0db",
                    "EndpointID": "5bf0e42af79e7089c2a5e4122aead576ece4b6801c06496d4271e7da22aea201",
                    "Gateway": "198.137.0.1",
                    "IPAddress": "198.137.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:c6:89:00:02",
                    "DriverOpts": null
                }
            }
        }  "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "9e2c78253285c9a2024cce7b05704db86611066e6c5c45f78da9df8c8befe657",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/run/docker/netns/9e2c78253285",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "",
            "Gateway": "",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
            "MacAddress": "",
            "Networks": {
                "mynet": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": [
                        "3abc307b6be9"
                    ],
                    "NetworkID": "86b72e88006b21d337697c58e958f8a65232db3c690b7c74c2e6bf5cf67de0db",
                    "EndpointID": "5bf0e42af79e7089c2a5e4122aead576ece4b6801c06496d4271e7da22aea201",
                    "Gateway": "198.137.0.1",
                    "IPAddress": "198.137.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:c6:89:00:02",
                    "DriverOpts": null
                }
            }
        }
# 查看 docker 容器内的hosts文件        
[root@localhost etc]# docker exec -it zsq1 cat /etc/hosts
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
198.137.0.2     3abc307b6be9
原理：
通过对比发现： 198.137.0.2     3abc307b6be9  
3abc307b6be9 则为docker容器ID，即zsq1,故可以通过容器名进行网络访问。

# 新建另外一docker容器
[root@localhost ~]# docker run -id --name zsq2 --network mynet centos
# 相互访问
[root@localhost ~]# docker exec -it zsq1 ping zsq2
PING zsq2 (198.137.0.3) 56(84) bytes of data.
64 bytes from zsq2.mynet (198.137.0.3): icmp_seq=1 ttl=64 time=0.107 ms
64 bytes from zsq2.mynet (198.137.0.3): icmp_seq=2 ttl=64 time=0.041 ms
64 bytes from zsq2.mynet (198.137.0.3): icmp_seq=3 ttl=64 time=0.045 ms
[root@localhost ~]# docker exec -it zsq2 ping zsq1
PING zsq1 (198.137.0.2) 56(84) bytes of data.
64 bytes from zsq1.mynet (198.137.0.2): icmp_seq=1 ttl=64 time=0.032 ms
64 bytes from zsq1.mynet (198.137.0.2): icmp_seq=2 ttl=64 time=0.099 ms
64 bytes from zsq1.mynet (198.137.0.2): icmp_seq=3 ttl=64 time=0.103 ms
64 bytes from zsq1.mynet (198.137.0.2): icmp_seq=4 ttl=64 time=0.099 ms

4、网络连通
---------------------------------------------------------------------------------------
---------------------------------                  ------------------------------------
-   ----------      ----------  -                  -  -----------      -------------  -
-   - mysql1 -      - mysql2 -  -                  -  -  redis1 -      -  redis2 - -  -
-   -   0.2  -      -   0.3  -  -                  -  -   0.2   -      -   0.3   - -  -
-   ----------      ----------  -                  -  -----------      -------------  -
-             mynet1            -                  -             mynet2               -   
-           172.17.0.1          -                  -           192.172.0.1            -
---------------------------------                  ------------------------------------

---------------------------------------------------------------------------------------
以上存在两个网络mynet1 和 mynet2。
mynet1 里面启动了两个容器：mysql1、mysql2
mynet2 里面启动了两个容器：redis1、redis2
docekr中mynet1与mynet2不能通信，因为不属于同一网段。
mysql1 如何与 redis1 通信 ====> 将容器mysql1加入到mynet2网络 
redis1 如何与 mysql1 通信 ====> 将容器redis1加入到mynet1网络 
(1)将容器连接到其他网络
$ docker network connect [OPTIONS] NETWORK CONTAINER
[root@localhost ~]# docker network connect mynet redis1
[root@localhost ~]# docker network inspect mynet
[
    {
        "Name": "mynet",
        "Id": "86b72e88006b21d337697c58e958f8a65232db3c690b7c74c2e6bf5cf67de0db",
        "Created": "2021-06-18T23:46:11.399369367+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "198.137.0.0/16",
                    "Gateway": "198.137.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "17d04f7d8837697da14b6afe71140751bceca64079fbe0d07e1753c7b29e61c8": {
                "Name": "redis1",
                "EndpointID": "b064fabb71c23dc36bbbf05fedda33f7af3838ac0dca30fe9e11a230c1a67b51",
                "MacAddress": "02:42:c6:89:00:04",
                "IPv4Address": "198.137.0.4/16",
                "IPv6Address": ""
            },
            "2147549a0d028a40f79b9cedacf02397fcabb0696f09af3868ab87eaac2388b6": {
                "Name": "mysql1",
                "EndpointID": "b2118692dae208a23a2bcc7afe7b60f1ed1966a33961f81bda55cbfada6f4f72",
                "MacAddress": "02:42:c6:89:00:02",
                "IPv4Address": "198.137.0.2/16",
                "IPv6Address": ""
            },
            "7dc0d1cae238a484ca481d3502462c5f1843a00dea4262bedda6c6d67d7c15e5": {
                "Name": "mysql2",
                "EndpointID": "a97b115d41cf2c8b1b3fa2381a47ab5c605501107c39b9672c1f539322adade9",
                "MacAddress": "02:42:c6:89:00:03",
                "IPv4Address": "198.137.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
通过查看mynet网络信息，得出 redis1 加入到mynet网络中，IP：198.137.0.4。

# 同时查看容器redis1的网络信息，发现redis1 同时归属两个网络：mynet 和 mynet1。
[root@localhost ~]# docker inspect redis1
"Networks": {
                "mynet": {
                    "IPAMConfig": {},
                    "Links": null,
                    "Aliases": [
                        "17d04f7d8837"
                    ],
                    "NetworkID": "86b72e88006b21d337697c58e958f8a65232db3c690b7c74c2e6bf5cf67de0db",
                    "EndpointID": "b064fabb71c23dc36bbbf05fedda33f7af3838ac0dca30fe9e11a230c1a67b51",
                    "Gateway": "198.137.0.1",
                    "IPAddress": "198.137.0.4",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:c6:89:00:04",
                    "DriverOpts": null
                },
                "mynet1": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": [
                        "17d04f7d8837"
                    ],
                    "NetworkID": "e1a86b0cf74926704d7ad1bea89023b21089456cf8ed74e04deaf714856a24bd",
                    "EndpointID": "ec8873c4bdcd6b40404d6a8cf84e3e3bad53ffc514b0426aec94cd774198225e",
                    "Gateway": "192.176.0.1",
                    "IPAddress": "192.176.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:c0:b0:00:02",
                    "DriverOpts": null
                }
            }

总结：属于不同网络的容器，是不能进行通信。因此可以将容器加入到其他网络中，便可以与其他网络中的容器进行通信。一个容器可以加入到多个不同的网络中。
```

## 1、 bridge 

​		在网络术语中，桥接网络(bridge network)是在网络段之间转发流量的链路层设备。网桥(bridge)是可以硬件设备或在主机内核中运行的软件设备。

​		在Docker术语中，桥接网络使用软件桥接，允许连接到同一桥接网络的容器进行通信，同时提供与未连接到该桥接网络的容器的隔离。Docker桥接驱动程序自动在主机中安装规则，以便不同桥接网络上的容器无法直接相互通信。**桥接网络适用于在同一个Docker后台程序主机上运行的容器。**

**用户定义的桥接网络和默认桥接网络的区别**

(1)用户定义的桥接网络可在容器化应用程序之间提供更好的隔离和互操作性

(2)用户定义的桥接网络在容器之间提供自动DNS解析

(3)容器可以在运行中与用户定义的网络连接和分离

(4)每个用户定义的网络都会创建一个可配置的网桥

(5)默认桥接网络上链接的容器共享环境变量

```shell
# 列出所有的网络
docker network ls
# 创建一个自定义的网桥网络，--driver bridge 默认是bridge，可以不写这个选项
docker network create --driver bridge mynet
# 创建一个容器，并加入到mynet网络
docker run -dit --name nginx --network mynet nginx
#查看网络的详细信息(连接了那些容器) 
docker network inspect mynet
#docker run命令期间只能连接到一个网络,可以将connect将容器连接到其他网络
docker network connect mynet mysql
# 断开容器与用户定义的桥接网络
docker network disconnect mynet nginx
# 查看容器的详细信息
docker inspect nginx
注意：
Failed to Setup IP tables: Unable to enable SKIP DNAT rule
报这个是因为关闭防火墙，未重启docker。
```

## 2、host

​		 独立容器联网，这些容器直接绑定到Docker主机的网络，没有网络隔离。  主机模式网络对于优化性能以及在容器需要处理大量端口的情况下很有用，因为它不需要网络地址转换（NAT），并且不会为每个端口创建“userland-proxy”。

​		启动一个直接绑定到Docker主机上端口80的`nginx`容器。 从网络的角度来看，这与nginx进程是直接在Docker主机而不是在容器中运行的隔离级别相同。 然而，从其他方面看，例如存储，进程命名空间和用户命名空间，`nginx`进程与主机是隔离的。 

```shell
#首先查看网络接口
ip addr
______________________________________________________________________________________
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:ce:c6:10 brd ff:ff:ff:ff:ff:ff
    inet 192.168.137.13/24 brd 192.168.137.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::3542:be30:9896:abdc/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:e6:b1:5a:bc brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
# 创建一个host网络
docker run -dit --network host --name nginx_main nginx
# 验证查看网络接口，发现并没有创建新的接口
ip addr
______________________________________________________________________________________
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:ce:c6:10 brd ff:ff:ff:ff:ff:ff
    inet 192.168.137.13/24 brd 192.168.137.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::3542:be30:9896:abdc/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:e6:b1:5a:bc brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever

# 验证Docker主机和容器占用80端口的进程ID
netstat -tulpn | grep :80
________________________________________________________________________________________
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1893/nginx: master
tcp6       0      0 :::80                   :::*                    LISTEN      1893/nginx: master
```

## 3、overlay 

当初始化swarm或将Docker主机加入现有swarm时，会在该Docker主机上创建两个新网络：

a.称为`ingress`的覆盖网络，用于处理与swarm服务相关的控制和数据通信。**创建swarm服务并且不将其连接到用户定义的覆盖网络时，默认情况下它会连接到`ingress`网络。**

b.一个名为`docker_gwbridge`的桥接网络，它将各个Docker后台程序连接到参与swarm的其他后台程序。

创建覆盖网络的前提条件：

需要打开以下端口，这些端口用于在覆盖网络上与每个参与的Docker主机的通信：

**用于集群管理通信的TCP端口2377**

**TCP和UDP端口7946用于节点之间的通信**

**UDP端口4789用于覆盖网络通信**

创建用于swarm服务的覆盖网络的命令：

```shell
 docker network create -d overlay my-overlay
```

创建可由swarm服务或独立容器用于与在其他Docker后台程序上运行的其他独立容器通信的覆盖网络的命令：

```shell
docker network create -d overlay --attachable my-attachable-overlay
```

(1) 在初始化或加入群集时Docker自动为您设置的默认覆盖网络 , **该网络不是生产系统的最佳选择**。 

```
docker swarm leave --force
docker swarm init --advertise-addr=<IP-ADDRESS-OF-MANAGER>
docker swarm join --token <TOKEN> --advertise-addr <IP-ADDRESS-OF-WORKER-1> <IP-ADDRESS-OF-MANAGER>:2377
docker node ls
docker network ls
docker service create --name nginx --publish target=80,published=80 --replicas=2 nginx
```

(2)使用用户定义的覆盖网络来连接服务。建议将其用于生产中运行的服务。

```shell
docker network create --driver=overlay --attachable my-overlay
docker service create --name nginx --network my-overlay   --replicas 2   --publish published=80,target=80 nginx
```

(3覆盖网络可用于独立容器，在不同Docker后台程序上的独立容器之间建立关联。

```shell
docker network create --driver=overlay --attachable test-net
# 在主机1上运行
docker run -dit --name nginx --network test-net nginx
# 在主机2上运行
docker run -dit --name nginx1 --network test-net nginx
docker network ls
```

(4)容器与swarm群集服务之间的通信，使用覆盖网络在独立容器与swarm群集服务之间建立通信。

## 4、none

 如果要完全禁用容器上的网络堆栈，可以在启动容器时使用`--network none`标记。  

```shell
docker run --rm -dit --network none --name nginx nginx
# 在docker宿主机无法Nginx，只能在容器内才能访问Nginx
```

总结：

当需要多个容器在同一个 Docker 主机上进行通信时，**用户定义的桥接网络**是最佳选择。

当不需要隔离网络堆栈与Docekr主机，而需要隔离容器的其他方面时，**主机网络**是最佳选择。

当需要在不同Docekr主机上运行的容器进行通信时，或者当多个应用程序使用swarm服务协同工作时，**覆盖网络**是最佳选择

## 5、docker容器内命令安装问题

```shell
#更新apt依赖
apt update

#安装ipaddr
apt install -y iproute2

#安装ifconfig
apt install -y net-tools

#安装ping
apt install -y iputils-ping
```



# 六、附录

**Docker 命令大全**

## 容器生命周期管理

- run

  创建一个容器并运行一个命令

- start/stop/restart

  对一个或多个容器进行启动/停止/重启

- kill

  杀掉一个运行中的容器

- rm

  删除一个或多个容器

- create

  创建一个新的容器但不启动它

- exec

  在运行的容器中执行命令

## 容器操作

- ps

  列出容器

- inspect

   获取容器/镜像的元数据

- logs

    获取容器的日志 

- port

   列出指定的容器的端口映射，或者查找将PRIVATE_PORT NAT到面向公众的端口 

- top

   查看容器中运行的进程信息，支持 ps 命令参数

## 容器rootfs命令

- commit

   从容器创建一个新的镜像

- cp

   用于容器与主机之间的数据拷贝 

- diff

   检查容器里文件结构的更改 

## 镜像仓库

- login/logout

   登陆/登出一个Docker镜像仓库 

- pull

   从镜像仓库中拉取或者更新指定镜像

- push

   将本地的镜像上传到镜像仓库,要先登陆到镜像仓库

- search

   从Docker Hub查找镜像

## 本地镜像管理

- images

   列出本地镜像

- rmi

   删除本地一个或多个镜像

- tag

   标记本地镜像，将其归入某一仓库

- build

   用于使用 Dockerfile 创建镜像

- history

   查看指定镜像的创建历史

- save

   将指定镜像保存成 tar 归档文件

- load

   导入使用 [docker save]命令导出的镜像

## 版本信息

- info

   显示 Docker 系统信息，包括镜像和容器数

- version

   显示 Docker 版本信息
   
   

# 七、MySQL是否需要容器化

容器的定义：容器是为了解决“在切换运行环境时，如何保证软件能够正常运行”这一问题。

## 数据安全问题

不要将数据储存在容器中，这也是Docker官方容器使用技巧中的一条。容器可以随时可以停止或者删除。当容器被删除掉，容器里面的数据将会丢失。为了避免数据丢失，用户可以使用数据卷挂载来储存数据。

但是容器的 Volumes 设计是围绕 Union FS 镜像层提供持久存储，数据安全缺乏保证。**如果容器突然崩溃，数据库未正常关闭，可能会损坏数据。另外，容器里共享数据卷组，对物理机硬件损伤也比较大。**

## 性能问题

​		MySQL 属于关系型数据库，对IO要求较高。当一台物理机跑多个时，IO就会累加，导致IO瓶颈，大大降低 MySQL 的读写性能。
​		数据库的性能瓶颈一般出现在IO上面，如果按 Docker 的思路，那么多个docker最终IO请求又会出现在存储上面。现在互联网的数据库多是share nothing的架构，可能这也是不考虑迁移到 Docker 的一个因素吧。
其实也有相对应的一些策略来解决这个问题，比如：
1）数据库程序与数据分离
​		如果使用Docker 跑 MySQL，数据库程序与数据需要进行分离，将数据存放到共享存储，程序放到容器里。**如果容器有异常或 MySQL 服务异常，自动启动一个全新的容器**。另外，**建议不要把数据存放到宿主机里，宿主机和容器共享卷组，对宿主机损坏的影响比较大。**
2）跑轻量级或分布式数据库
​		Docker 里部署轻量级或分布式数据库，**Docker 本身就推荐服务挂掉，自动启动新容器，而不是继续重启容器服务。**
3）合理布局应用
​		对于IO要求比较高的应用或者服务，将数据库部署在物理机或者KVM中比较合适。目前腾讯云的TDSQL和阿里的Oceanbase都是直接部署在物理机器，而非Docker 。

## 状态问题

​		在 Docker 中水平伸缩只能用于无状态计算服务，而不是数据库。**Docker 快速扩展的一个重要特征就是无状态，具有数据状态的都不适合直接放在 Docker 里面**，如果 Docker 中安装数据库，存储服务需要单独提供。
​		目前，腾讯云的TDSQL（金融分布式数据库）和阿里云的Oceanbase（分布式数据库系统）都直接运行中在物理机器上，并非使用便于管理的 Docker 上。

## 资源隔离问题

​		资源隔离方面，Docker 确实不如虚拟机KVM，**Docker是利用Cgroup实现资源限制的，只能限制资源消耗的最大值，而不能隔绝其他程序占用自己的资源。如果其他应用过渡占用物理机资源，将会影响容器里 MySQL 的读写效率。**
​		需要的隔离级别越多，获得的资源开销就越多。相比专用环境而言，容易水平伸缩是Docker的一大优势。然而在 Docker 中水平伸缩只能用于无状态计算服务，数据库并不适用。



## 难道 MySQL 不能跑在容器里

MySQL 也不是完全不能容器化。
1）对数据丢失不敏感的业务就可以容器化，利用数据库分片来增加实例数，从而增加吞吐量。
2）**docker适合跑轻量级或分布式数据库，当docker服务挂掉，会自动启动新容器，而不是继续重启容器服务。**
3）数据库利用中间件和容器化系统能够自动伸缩、容灾、切换、自带多个节点，也是可以进行容器化的。

# 八、Swarm集群

```
docker swarm init --advertise-addr=192.168.137.12   # 初始化集群配置信息
docker swarm leave --force # 强制离开集群
docker swarm join-token worker # 生成worker节点加入集群的token
docker swarm join-token manager # 生成manager节点加入集群的token
docker node ls # 查看集群中所有节点信息
docker service ls
docker service create --name my_web nginxdocker 
service scale my_web=3docker 
service create --name my_web --replicas 3 --publish published=8080,target=80 nginx
docker service rm my_web

查看docker集群中节点的实际IP
docker node ls | awk '{print $1}'
docker node inspect 5qvwo7uqboojhhwnt9rtqmeb6
# manager节点
docker inspect xnxgf8edwjkhqqe6b588rwpxf | jq -r '.[0].ManagerStatus.Addr'
# work节点
docker inspect 5qvwo7uqboojhhwnt9rtqmeb6 | jq -r '.[0].Status.Addr'
```





# **九、实际遇到的问题**

## 1.不删容器生效容器配置信息

需要考虑的条件：

a.宿主机上docker的service服务本身不能重启，影响其他线上容器。

b.该容器A不能删除，因为有数据存在。

方案一：修改容器A配置文件，重启容器A
			宿主机上默认存放所有容器的配置目录是在/var/lib/docker/containers/目录下，在该目录下有许多个容器ID的目录，每一个ID表示一个容器。因此要找到容器A的配置文件那么需要先查询出容器A的ID号即可。得到容器A的ID号之后再去/var/lib/docker/containers/目录下的对应的容器目录，然后就可以看到容器A的配置文件。
(1).修改之前一定要停止容器，否则修改完之后又被改回去了
(2).修改完之后先重启docker服务（而不是重新启动容器，否则你的配置文件就变回之前的了）

方案二：使用docker commit新构镜像
			docker commit把一个容器的文件改动和配置信息commit到一个新的镜像中，然后用这个新的镜像重启一个容器，这对之前的容器不会有影响。主要是三步骤：
1、先stop容器A
2、commit容器A
　　docker commit old_container  new_image:tag
3、使用前一步新生成的镜像重新启动一个容器。
　　docker run --name container_name02 -p 9202:9200 new_image:tag

## 2.docker 内部docker0网段与主机网段冲突

