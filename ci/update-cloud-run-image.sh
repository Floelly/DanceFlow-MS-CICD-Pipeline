#!/usr/bin/env bash
set -euo pipefail

: "${SERVICE_NAME:?SERVICE_NAME not set}"
: "${IMAGE:?IMAGE not set}"
: "${REGION:?REGION not set}"
: "${PROJECT_ID:?PROJECT_ID not set}"

echo "Updating Cloud Run service '${SERVICE_NAME}' with image '${IMAGE}' in project '${PROJECT_ID}' (${REGION})..."

gcloud run services update "${SERVICE_NAME}" \
  --image="${IMAGE}" \
  --region="${REGION}" \
  --project="${PROJECT_ID}" \
  --platform=managed \
  --quiet

echo "Update finished."