#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pushd "$ROOT_DIR/app/frontend" > /dev/null

echo "Restoring frontend npm packages"
npm install

echo "Building frontend"
npm run build

popd > /dev/null

# Prepare backend Python dependencies for App Service zip deploy
PYTHON_CMD="${PYTHON:-python3}"
if ! command -v "$PYTHON_CMD" >/dev/null 2>&1; then
	PYTHON_CMD="python"
fi

pushd "$ROOT_DIR/app/backend" > /dev/null

echo "Preparing backend Python packages"
rm -rf .python_packages
"$PYTHON_CMD" -m pip install --target ".python_packages/lib/site-packages" -r requirements.txt

popd > /dev/null
