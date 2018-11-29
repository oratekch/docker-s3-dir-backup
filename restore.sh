#!/bin/bash

if [ -z "$RESTORE_FILE_PATH" ]; then
	echo "finding last backup..."
	# find last object in bucket
	LAST_OBJ=`/usr/bin/aws s3 ls s3://${AWS_BUCKET}/ --recursive | grep ".gz" | sort | tail -n 1 | awk '{print $4}'`
else
	echo "restoring requested backup..."
	LAST_OBJ=$RESTORE_FILE_PATH
fi

# make full path for last backup object, is necessary because bucket name may have path inside
LAST_OBJ=`echo ${AWS_BUCKET} | sed -e 's/\/.*//g'`/${LAST_OBJ}

echo "backup file to resotre: s3://${LAST_OBJ}"

echo "downloading backup from S3..."

/usr/bin/aws s3 cp s3://${LAST_OBJ} ${BACKUP_TGT_DIR}

echo "backup download finished"

BCK_FILE=${BACKUP_TGT_DIR}`echo ${LAST_OBJ} | sed -e 's/\(.*\/\)*//g'`

tar -xzvf ${BCK_FILE} -C ${BACKUP_SRC_DIR}

rm ${BCK_FILE}

if [ -z "$RESTORE_RESUME_BACKUP" ]; then
	echo "restore finished, exiting"
else
	echo "continuing with backup corn job..."
	/opt/cron.sh
fi
