#!/usr/bin/env bash
set -euo pipefail
APP_DIR="$1"; VERSION="${2:-0.0.1}"
mkdir -p dist
APP_NAME=$(basename "$APP_DIR")
tar -C "$(dirname "$APP_DIR")" -czf "dist/${APP_NAME}-${VERSION}.tgz" "${APP_NAME}"
echo "dist/${APP_NAME}-${VERSION}.tgz"
