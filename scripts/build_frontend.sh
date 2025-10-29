#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pushd "$ROOT_DIR/app/frontend" > /dev/null

echo "Restoring frontend npm packages"
npm install

echo "Building frontend"
npm run build

popd > /dev/null
