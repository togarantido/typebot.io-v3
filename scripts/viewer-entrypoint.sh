#!/bin/bash
set -euxo pipefail

echo "===== DEBUG VIEWER START ====="
pwd
ls -la
find . -maxdepth 3 \( -name server.js -o -name "*.js" \) | sed -n '1,80p'
echo "PORT=$PORT HOSTNAME=${HOSTNAME:-}"
node -v

cd apps/viewer
node -e "const { configureRuntimeEnv } = require('next-runtime-env/build/configure'); configureRuntimeEnv();"
cd ../..

echo "===== START TRY 1 ====="
if [ -f apps/viewer/server.js ]; then
  exec env NODE_OPTIONS=--no-node-snapshot HOSTNAME=${HOSTNAME:-0.0.0.0} PORT=${PORT:-3000} node apps/viewer/server.js
fi

echo "===== START TRY 2 ====="
if [ -f server.js ]; then
  exec env NODE_OPTIONS=--no-node-snapshot HOSTNAME=${HOSTNAME:-0.0.0.0} PORT=${PORT:-3000} node server.js
fi

echo "===== NO SERVER FILE FOUND ====="
find . -maxdepth 4 -name server.js
exit 1