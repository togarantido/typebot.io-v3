#!/bin/bash
set -euxo pipefail

echo "===== DEBUG BUILDER START ====="
echo "DATABASE_URL_SET=${DATABASE_URL:+yes}"

export DATABASE_URL="$DATABASE_URL"

cd apps/builder
node -e "const { configureRuntimeEnv } = require('next-runtime-env/build/configure'); configureRuntimeEnv();"
cd ../..

echo "===== RUN MIGRATIONS ====="
./node_modules/.bin/prisma migrate deploy --schema=packages/prisma/postgresql/schema.prisma

echo "===== START SERVER ====="
NODE_OPTIONS=--no-node-snapshot HOSTNAME=0.0.0.0 PORT=${PORT:-3000} node apps/builder/server.js