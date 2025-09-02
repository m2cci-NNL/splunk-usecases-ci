#!/usr/bin/env bash
set -euo pipefail
PKG="$1"; HOST="$2"; AUTH="$3"
curl -sk -u "$AUTH" "$HOST/services/apps/local" -d name="@${PKG}" -d update=1 -X POST
curl -sk -u "$AUTH" "$HOST/services/server/control/restart" -X POST || true
