FROM alpine:latest
LABEL maintainer="Oratek <contact@oratek.ch>"

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ENV BACKUP_TGT_DIR /backup/
ENV BACKUP_SRC_DIR /data/
ENV BACKUP_FILE_NAME 'host_volumes'

ENV AWS_BUCKET **None**
ENV AWS_DEFAULT_REGION ch-dk-2
ENV AWS_ACCESS_KEY_ID **None**
ENV AWS_SECRET_ACCESS_KEY **None**
ENV AWS_ENDPOINT="**None**"
ENV AWS_S3V4 no
ENV SCHEDULE **None**

ADD run.sh run.sh
ADD backup.sh backup.sh
ADD restore.sh restore.sh

VOLUME $BACKUP_TGT_DIR
VOLUME $BACKUP_SRC_DIR

CMD ["sh", "run.sh"]
