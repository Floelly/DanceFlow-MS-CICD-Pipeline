#!/usr/bin/env bash
set -euo pipefail

: "${SERVICE_NAME:?SERVICE_NAME not set}"
: "${IMAGE:?IMAGE not set}"
: "${REGION:?REGION not set}"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID not set}"

echo "Updating Cloud Run service '${SERVICE_NAME}' with image '${IMAGE}' in project '${GCP_PROJECT_ID}' (${REGION})..."

gcloud run services update "${SERVICE_NAME}" \
  --image="${IMAGE}" \
  --region="${REGION}" \
  --project="${GCP_PROJECT_ID}" \
  --platform=managed \
  --quiet

echo "Update finished."