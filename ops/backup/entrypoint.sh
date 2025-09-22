#!/bin/sh
set -e
apk add --no-cache postgresql16-client aws-cli tzdata
cp /usr/share/zoneinfo/America/Fortaleza /etc/localtime || true
echo "0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1" > /etc/crontabs/root
exec crond -f -l 8
