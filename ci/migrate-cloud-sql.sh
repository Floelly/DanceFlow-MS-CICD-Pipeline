#!/usr/bin/env bash
set -euo pipefail

: "${CLOUD_SQL_INSTANCE:?CLOUD_SQL_INSTANCE not set}"

PIPELINE_VERSION="${PIPELINE_VERSION:-unknown}"
BUILD_NUMBER="${BUILD_NUMBER:-0}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-danceflow-ms}"

DESCRIPTION="jenkins-${PIPELINE_VERSION}-build-${BUILD_NUMBER}"

echo "Backup Cloud SQL instance '${CLOUD_SQL_INSTANCE}' with description '${DESCRIPTION}'..."

#gcloud sql backups create \
#  --instance="${CLOUD_SQL_INSTANCE}" \
#  --project="${GCP_PROJECT_ID}" \
#  --description="${DESCRIPTION}"

echo "Backup for '${CLOUD_SQL_INSTANCE}' successful."
echo "Start Flyway migration..."

if bash ci/flyway-migration.sh; then
  echo "Migration successful."
else
  echo "Migration not successful, try to restore backup '${DESCRIPTION}'..."

#  BACKUP_ID="$(gcloud sql backups list \
#    --instance="${CLOUD_SQL_INSTANCE}" \
#    --filter="description:${DESCRIPTION}" \
#    --sort-by="~startTime" \
#    --format="value(id)" | head -n1)"
#
#  if [ -z "${BACKUP_ID}" ]; then
#    echo "No backup with description '${DESCRIPTION}' found. Restoration not successful. Please restore manually!."
#    exit 1
#  fi
#
#  echo "Restore backup id '${BACKUP_ID}' for instance '${CLOUD_SQL_INSTANCE}'..."
#  gcloud sql backups restore "${BACKUP_ID}" \
#    --restore-instance="${CLOUD_SQL_INSTANCE}" \
#    --project="${GCP_PROJECT_ID}" \
#    --quiet

  echo "Restoration successful. Please verify integrity of Cloud SQL instance."
  exit 1
fi