#!/usr/bin/env bash
# Build PureFinance for the web.
#
# Usage:
#   ./scripts/build_web.sh                # build for site root  (/)
#   ./scripts/build_web.sh /finance/      # build for sub-path   (/finance/)
#
# The output goes to build/web/ . Upload the entire contents of that
# directory (not the parent) to your web server.
set -euo pipefail

BASE_HREF="${1:-/}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter not found in PATH." >&2
  exit 1
fi

# Ensure base href starts and ends with '/'
case "$BASE_HREF" in
  /*) ;;
  *) BASE_HREF="/$BASE_HREF" ;;
esac
case "$BASE_HREF" in
  */) ;;
  *) BASE_HREF="$BASE_HREF/" ;;
esac

echo "==> flutter pub get"
flutter pub get

echo "==> Installing sqflite web worker assets (sqflite_sw.js + sqlite3.wasm)"
dart run sqflite_common_ffi_web:setup

echo "==> flutter build web --release --base-href=$BASE_HREF"
flutter build web --release --base-href="$BASE_HREF"

echo
echo "Build complete: build/web/"
echo "Deploy by serving build/web/ as the document root (or under $BASE_HREF)."
