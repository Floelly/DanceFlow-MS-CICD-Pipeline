#!/usr/bin/env bash
set -euo pipefail

: "${DB_INSTANCE_CONNECTION_NAME:?DB_INSTANCE_CONNECTION_NAME not set}"
: "${DATABASE_SCHEMA_NAME:?DATABASE_SCHEMA_NAME not set}"
: "${FLYWAY_CREDS_USR:?FLYWAY_CREDS_USR not set}"
: "${FLYWAY_CREDS_PSW:?FLYWAY_CREDS_PSW not set}"

FLYWAY_URL="jdbc:mysql://google/${DATABASE_SCHEMA_NAME}?cloudSqlInstance=${DB_INSTANCE_CONNECTION_NAME}&socketFactory=com.google.cloud.sql.mysql.SocketFactory&useSSL=false"

echo "Run Flyway migrations in Maven Docker container..."

set +e
docker run --rm \
  -v "$PWD:/workspace" \
  -w /workspace/springboot-backend \
  -e FLYWAY_URL="${FLYWAY_URL}" \
  -e FLYWAY_USER="${FLYWAY_CREDS_USR}" \
  -e FLYWAY_PASSWORD="${FLYWAY_CREDS_PSW}" \
  maven:3.9.9-eclipse-temurin-17 \
  bash -c 'mvn -B -ntp flyway:migrate \
           -Dflyway.url=$FLYWAY_URL \
           -Dflyway.user=$FLYWAY_USER \
           -Dflyway.password=$FLYWAY_PASSWORD'
MIGRATION_EXIT=$?
set -e

exit "${MIGRATION_EXIT}"