#!/usr/bin/env bash
set -e
docker exec -d portal_web bash -c "find /usr/local/portal_web/log/ -mtime +180 -name \"*\" -exec rm -rf {} \;"
sleep 3
FILENAME=$(docker exec -it portal_web ls -lt /usr/local/portal_web/log/ | grep -v "tar.gz" | grep -v "portal_web.log" | grep "^[^total]" | awk '{print $NF}' | head -n 20)
for i in $FILENAME ; do
    file=$(echo $i | sed s/\\s//g)
    docker exec -d portal_web bash -c "cd /usr/local/portal_web/log/ && tar -cvzf $file.tar.gz $file --remove-files"
done