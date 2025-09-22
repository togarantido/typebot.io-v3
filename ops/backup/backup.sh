#!/usr/bin/env sh
set -euo pipefail

KEEP="${S3_KEEP:-3}"

NOW="$(date +%F_%H-%M-%S)"
OUT="/backups/typebot_${NOW}.sql.gz"

PGPASSWORD="${PGPASSWORD:-typebot}" pg_dump -h typebot-db -U postgres typebot | gzip > "$OUT"

HOSTNAME="$(hostname)"
aws s3 cp "$OUT" "s3://${S3_BUCKET}/${HOSTNAME}/$(basename "$OUT")"

# Retenção local (mantém só os N mais novos)
ls -1t /backups/*.sql.gz 2>/dev/null | tail -n +$((KEEP+1)) | xargs -r rm -f

# Retenção S3 (mantém só os N mais novos por hostname)
keys="$(aws s3api list-objects-v2 \
  --bucket "${S3_BUCKET}" \
  --prefix "${HOSTNAME}/" \
  --query 'reverse(sort_by(Contents,&LastModified))[*].Key' \
  --output text 2>/dev/null || true)"

i=0
for k in $keys; do
  i=$((i+1))
  [ "$i" -le "$KEEP" ] && continue
  aws s3 rm "s3://${S3_BUCKET}/${k}" || true
done
