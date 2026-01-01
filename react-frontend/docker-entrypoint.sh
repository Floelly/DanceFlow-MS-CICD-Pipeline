#!/bin/sh

: "${VITE_DANCEFLOW_MS_API_URL:=http://localhost:8080}"

cat > /usr/share/nginx/html/env.js <<EOF
window.__RUNTIME_CONFIG__ = {
  API_BASE_URL: "${VITE_DANCEFLOW_MS_API_URL}"
};
EOF

exec "$@"
