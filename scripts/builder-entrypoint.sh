#!/bin/bash
set -euxo pipefail

echo "===== DEBUG BUILDER START ====="

pwd
ls -la
ls -la apps || true
ls -la apps/builder || true
ls -la apps/builder/.next || true
node -v

echo "===== CONFIG RUNTIME ENV ====="
cd apps/builder
node -e "const { configureRuntimeEnv } = require('next-runtime-env/build/configure'); configureRuntimeEnv();"
cd ../..

echo "===== RUN MIGRATIONS ====="
./node_modules/.bin/prisma migrate deploy --schema=packages/prisma/postgresql/schema.prisma || true

echo "===== START SERVER ====="
NODE_OPTIONS=--no-node-snapshot HOSTNAME=${HOSTNAME:-0.0.0.0} PORT=${PORT:-3000} node apps/builder/server.js