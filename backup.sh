#!/bin/bash
[ -z "${MYSQL_USER}" ] && { echo "=> MYSQL_USER cannot be empty" && exit 1; }
[ -z "${MYSQL_PASS}" ] && { echo "=> MYSQL_PASS cannot be empty" && exit 1; }

DATE=`date +%Y%m%d%H%M`
echo "=> Backup started at $DATE"
databases=`mysql -u $MYSQL_USER -p$MYSQL_PASS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
for db in $databases; do
  if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
    echo "Dumping database: $db"
    FILENAME=/backup/$DATE.$db.sql
    if mysqldump -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS $db > $FILENAME ;then
      gzip -f $FILENAME
    else
      rm -rf $FILENAME
    fi
  fi
done

if [ -n "$MAX_BACKUPS" ]; then
  while [ `ls -1 /backup | wc -l` -gt "$MAX_BACKUPS" ];
  do
    TARGET=`ls -1 /backup | sort | head -n 1`
    echo "Backup \${TARGET} is deleted"
    rm -rf /backup/\${TARGET}
  done
fi

echo "=> Backup done"