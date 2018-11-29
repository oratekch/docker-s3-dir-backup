#!/bin/bash

set -e

if [ "${AWS_ACCESS_KEY_ID}" == "**None**" ]; then
  echo "Warning: You did not set the S3_ACCESS_KEY_ID environment variable."
fi

if [ "${AWS_SECRET_ACCESS_KEY}" == "**None**" ]; then
  echo "Warning: You did not set the S3_SECRET_ACCESS_KEY environment variable."
fi

if [ "${AWS_BUCKET}" == "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

COMPARE_DIR="/compare_dir/"

echo "backup started at $(date +%Y-%m-%d_%H:%M:%S)"

echo "creating archive..."

# this has to be executed like this, because we have two level expansion in variables
eval "export BACKUP_DST_FULL_PATH=${BACKUP_TGT_DIR}${BACKUP_FILE_NAME}.tar.gz"
eval "export COMPARE_DST_FULL_PATH=${COMPARE_DIR}${BACKUP_FILE_NAME}.tar.gz"

BACKUP_DST_DIR=$(dirname "${BACKUP_DST_FULL_PATH}")
DUMP_START_TIME=$(date +"%Y-%m-%dT%H%M%SZ")

mkdir -p ${COMPARE_DIR}
echo "Gzipping ${BACKUP_SRC_DIR} into ${COMPARE_DST_FULL_PATH}"
tar -czf ${COMPARE_DST_FULL_PATH} -C ${BACKUP_SRC_DIR} .

if [ "${AWS_ENDPOINT}" == "**None**" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${AWS_ENDPOINT}"
fi

if cmp -s "$BACKUP_DST_FULL_PATH" "$COMPARE_DST_FULL_PATH"
then
   echo "Archive is the same of the old one, do nothing."
else
   echo "Archive is different from the old one, uploading to s3..."
   mkdir -p ${BACKUP_DST_DIR}
   mv "$COMPARE_DST_FULL_PATH" "$BACKUP_DST_FULL_PATH"
   #echo "archive created, uploading..."
   /usr/bin/aws $AWS_ARGS s3 cp ${BACKUP_TGT_DIR}${BACKUP_FILE_NAME}.tar.gz s3://${AWS_BUCKET}/${DUMP_START_TIME}.${BACKUP_FILE_NAME}.tar.gz
fi


echo "backup finished at $(date +%Y-%m-%d_%H:%M:%S)"
