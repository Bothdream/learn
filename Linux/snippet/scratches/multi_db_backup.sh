#!/usr/bin/env bash
# MySQL 数据库备份多循环
DATE=$(date +%F_%H-%M-%S)
HOST=127.0.0.1
USER=backup
PASS=123456
BACKUP_DIR=/data/db_backup
DB_LIST=$(mysql -h"$HOST" -u"$USER" -p"$PASS" -s -e "show databases;" 2>/dev/null | egrep -v "Database|information_schema|mysql|performance_schema|sys")
for DB in $DB_LIST; do
    BACK_DB_DIR=${BACKUP_DIR}/${DB}_${DATE}
    [ ! -d "${BACK_DB_DIR}" ] && mkdir -p "${BACK_DB_DIR}" &>/dev/null
    TABLE_LIST=$(mysql -h"$HOST" -u"$USER" -p"$PASS" -s -e "use ${DB};show tables;" 2>/dev/null)
    for TABLE in $TABLE_LIST; do
        BACKUP_NAME="${BACK_DB_DIR}/${TABLE}.sql"
        if [ ! mysqldump -h"$HOST" -u"$USER" -p"$PASS" "$DB" "$TABLE" ] >$BACKUP_NAME 2>dev/null; then
            echo "$BACKUP_NAME 备份失败！"
        fi
    done
done
