#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_ASSETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/app/src/main/assets"

cp "$ROOT_DIR/index.html" "$APP_ASSETS_DIR/index.html"
cp "$ROOT_DIR/client.html" "$APP_ASSETS_DIR/client.html"

echo "Synced index.html and client.html into Android assets."
