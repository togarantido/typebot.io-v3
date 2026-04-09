#!/bin/bash

cd apps/builder;
node  -e "const { configureRuntimeEnv } = require('next-runtime-env/build/configure'); configureRuntimeEnv();"
cd ../..;

if [ -n "${DATABASE_URL:-}" ]; then
  ./node_modules/.bin/prisma migrate deploy --schema=packages/prisma/postgresql/schema.prisma
else
  echo "DATABASE_URL is not set, skipping prisma migrate deploy"
fi

NODE_OPTIONS=--no-node-snapshot HOSTNAME=0.0.0.0 PORT=${PORT:-3000} node apps/builder/server.js;
