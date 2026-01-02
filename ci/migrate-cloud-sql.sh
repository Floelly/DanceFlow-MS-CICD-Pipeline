#!/usr/bin/env bash
set -euo pipefail

if [ -z "${CLOUD_SQL_INSTANCE:-}" ]; then
  echo "ERROR: CLOUD_SQL_INSTANCE not set."
  exit 1
fi

PIPELINE_VERSION="${PIPELINE_VERSION:-unknown}"
BUILD_NUMBER="${BUILD_NUMBER:-0}"

DESCRIPTION="jenkins-${PIPELINE_VERSION}-build-${BUILD_NUMBER}"

echo "Erstelle Cloud SQL Backup für '${CLOUD_SQL_INSTANCE}' mit Beschreibung '${DESCRIPTION}'..."

gcloud sql backups create \
  --instance="${CLOUD_SQL_INSTANCE}" \
  --description="${DESCRIPTION}"

echo "Backup für '${CLOUD_SQL_INSTANCE}' erfolgreich erstellt."