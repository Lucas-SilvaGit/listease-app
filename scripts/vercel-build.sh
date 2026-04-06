#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.6}"
FLUTTER_ROOT=".vercel/flutter-sdk"
FLUTTER_BIN="$FLUTTER_ROOT/bin/flutter"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"

API_BASE_URL="${API_BASE_URL:-https://listease-api.fly.dev/api/v1}"
GOOGLE_SERVER_CLIENT_ID="${GOOGLE_SERVER_CLIENT_ID:-237793101316-p1gdddkn6m7h9pn6cc9n4c2imf1v3rlj.apps.googleusercontent.com}"
FLUTTER_SAFE_DIRECTORY="$(pwd)/$FLUTTER_ROOT"

if [ ! -x "$FLUTTER_BIN" ]; then
  echo "Installing Flutter ${FLUTTER_VERSION} for Vercel build..."
  rm -rf "$FLUTTER_ROOT"
  mkdir -p .vercel
  curl -L "$FLUTTER_URL" -o /tmp/flutter.tar.xz
  tar -xf /tmp/flutter.tar.xz -C .vercel
  mv .vercel/flutter "$FLUTTER_ROOT"
fi

git config --global --add safe.directory "$FLUTTER_SAFE_DIRECTORY"
"$FLUTTER_BIN" --disable-analytics >/dev/null 2>&1 || true
"$FLUTTER_BIN" config --enable-web >/dev/null
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" build web --release \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=GOOGLE_SERVER_CLIENT_ID="$GOOGLE_SERVER_CLIENT_ID"
