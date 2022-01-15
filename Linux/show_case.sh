#!/bin/bash


# 生成模板脚本
cat <<EOF > update.sh
#!/bin/bash

#APP_HOME=${APP_HOME}
#APP_JAR=${DEPLOY_HOME}\`basename ${ARTIFACT}`
#APP_SERVICE=${APP_SERVICE}

APP_HOME=123
APP_JAR=234
APP_SERVICE=456

EOF

cat ./update.sh.tpl >> update.sh

cat ./update.sh

sh update.sh


# . 生效环境变量
. /usr/local/sir/deploy/env/$APP.env "$APP"


# 判断上一条脚本执行是否报错
if [[ $? -ne 0 ]]; then
    echo "call fail"
    exit 1
fi

# 判断目录是否存在
if [[ ! -d ./jenkins ]]; then
    mkdir -p ./jenkins
fi

# 建立软连接
ln -fs $NEW_JAR_NAME $ORIGIN_JAR_NAME

# 判断文件是否存在
if [[ -f "./xjar" ]]; then
    mv ./xjar ./xjar.backup
fi