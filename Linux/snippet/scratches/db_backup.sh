#!/usr/bin/env bash
# MySQL 数据库备份单循环
DATE=$(date +%F_%H-%M-%S)
HOST=127.0.0.1
USER=backup
PASS=123456
BACKUP_DIR=/data/db_backup
DB_LIST=$(mysql -h"$HOST" -u"$USER" -p"$PASS" -s -e "show databases;" 2>/dev/null | egrep -v "Database|information_schema|mysql|performance_schema|sys")
for DB in $DB_LIST; do
    BACKUP_NAME="${BACKUP_DIR}/${DB}_${DATE}.sql"
    if [ ! mysqldump -h"$HOST" -u"$USER" -p"$PASS" -B "$DB" ] >$BACKUP_NAME 2>dev/null; then
        echo "$BACKUP_NAME 备份失败！"
    fi
done
