#!/usr/bin/env bash
set -euo pipefail
PKG="$1"; HOST="$2"; AUTH="$3"
TMP="/tmp/shc_$$"
mkdir -p "$TMP"
tar -xzf "$PKG" -C "$TMP"
APP_NAME=$(ls "$TMP")
sudo rm -rf "$SPLUNK_HOME/etc/shcluster/apps/${APP_NAME}" || true
sudo mv "$TMP/$APP_NAME" "$SPLUNK_HOME/etc/shcluster/apps/"
"$SPLUNK_HOME/bin/splunk" apply shcluster-bundle -target "$HOST" -auth "$AUTH"
