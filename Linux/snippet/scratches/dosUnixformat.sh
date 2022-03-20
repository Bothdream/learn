#!/usr/bin/env bash
# 递归将文件转换为Unix格式的文件
# 在windows下执行
# 注意：
#      ls -l | awk '{if(NF>8){print $9;}}' 在Linux环境下正常执行，而在Windows则会有问题
dos2unixformat() {
    CUR_PATH=$1
    FILES=$(ls -l "$CUR_PATH" | awk 'NR!=1{print $9;}')
    for file_name in $FILES; do
        FILE="$CUR_PATH/$file_name"
        if [ -d "$FILE" ]; then
            dos2unixformat $FILE
        else
            dos2unix -k $FILE
            shfmt -w -i 4 -ci $FILE
        fi
    done
}
cur=$(pwd)
dos2unixformat $cur
