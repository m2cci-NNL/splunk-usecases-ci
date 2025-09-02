#!/usr/bin/env bash
set -euo pipefail
APP_DIR="$1"
test -f "${APP_DIR}/default/app.conf" || { echo "Missing app.conf"; exit 1; }
echo "[OK] Validation passed"
