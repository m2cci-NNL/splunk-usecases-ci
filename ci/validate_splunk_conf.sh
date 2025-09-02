#!/usr/bin/env bash
set -euo pipefail
APP_DIR="$1"
test -f "${APP_DIR}/default/app.conf" || { echo "Missing app.conf"; exit 1; }
echo "[INFO] Basic files OK"
if command -v splunk >/dev/null 2>&1; then
  echo "[INFO] Running btool sanity"
  splunk cmd btool savedsearches list >/dev/null || { echo "btool error"; exit 1; }
fi
echo "[OK] Validation passed"
