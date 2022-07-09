#!/usr/bin/env bash
# $1 str       print string
# 0-黑色
# 1-红色
# 2-绿色
# 3-黄色
# 4-蓝色
# 5-洋红色
# 6-青色
# 7-白色
# $2 color     0-7 设置颜色
# $3 bgcolor   0-7 设置背景颜色
# $4 bold      0-1 设置粗体
# $5 underline 0-1 设置下划线

function format_output() {
    str=$1
    color=$2
    bgcolor=$3
    bold=$4
    underline=$5
    normal=$(tput sgr0)
    case "$color" in
        0 | 1 | 2 | 3 | 4 | 5 | 6 | 7)
            setcolor=$(tput setaf $color)
            ;;
        *)
            setcolor=""
            ;;
    esac
    case "$bgcolor" in
        0 | 1 | 2 | 3 | 4 | 5 | 6 | 7)
            setbgcolor=$(tput setab $bgcolor)
            ;;
        *)
            setbgcolor=""
            ;;
    esac
    if [ "$bold" = "1" ]; then
        setbold=$(tput bold)
    else
        setbold=""
    fi
    if [ "$underline" = "1" ]; then
        setunderline=$(tput smul)
    else
        setunderline=""
    fi
    printf "$setcolor$setbgcolor$setbold$setunderline$str$normal\n"
}
cur_time=$(date +"%Y-%m-%d %H:%M:%S")
function log_info() {
    format_output "[$cur_time INFO]$1" 2 9 0 0
}
function log_warn() {
    format_output "[$cur_time WARN]$1" 3 9 0 0
}
function log_error() {
    format_output "[$cur_time ERROR]$1" 1 9 0 0
}

# ---------------------------------------------------------------------------------
# 控制台颜色
BLACK="\033[1;30m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
RESET="$(tput sgr0)"
# ---------------------------------------------------------------------------------

printf "${BLUE}\n"
cat <<EOF
###################################################################################
# 安装常见 lib
# 如果不知道命令在哪个 lib，可以使用 yum search xxx 来查找
# lib 清单如下：
# gcc gcc-c++ kernel-devel libtool
# openssl openssl-devel
# zlib zlib-devel
# pcre
###################################################################################
EOF
printf "${RESET}\n"

printf "\n${GREEN}>>>>>>>>> 安装常见 lib 开始${RESET}\n"

log_info "1231231"
log_warn "asdfasfdG"
log_error "asfasfasffsad"
