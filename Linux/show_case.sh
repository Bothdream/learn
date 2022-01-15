#!/bin/bash


# ����ģ��ű�
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


# . ��Ч��������
. /usr/local/sir/deploy/env/$APP.env "$APP"


# �ж���һ���ű�ִ���Ƿ񱨴�
if [[ $? -ne 0 ]]; then
    echo "call fail"
    exit 1
fi

# �ж�Ŀ¼�Ƿ����
if [[ ! -d ./jenkins ]]; then
    mkdir -p ./jenkins
fi

# ����������
ln -fs $NEW_JAR_NAME $ORIGIN_JAR_NAME

# �ж��ļ��Ƿ����
if [[ -f "./xjar" ]]; then
    mv ./xjar ./xjar.backup
fi