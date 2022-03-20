#!/usr/bin/expect
# 传参数
# 1、脚本的执行方法与bash shell不一样，比如：expect example.sh
# 2、向一个脚本传递参数时，bash shell是使用$1,$2...来接收参数的；而expect则将脚本的执行参数保存在数组$argv中，在脚本中一般将其赋值给变量：set 变量名 [lindex $argv 参数]
# 注意：若登陆后便退出远程终端，则写expect eof即可。
set IP [lindex $argv 0]
set USER_NAME [lindex $argv 1]
set PORT [lindex $argv 2]
set PASSWORD [lindex $argv 3]
set timeout 10
spawn ssh-copy-id -p $PORT $USER_NAME@$IP
expect {
   "(yes/no)" {send "yes\r"; exp_continue}
   "password:" {send "$PASSWORD\r";}
}
expect eof