#!/usr/bin/env bash
set -euo pipefail

PROJECT="BrowserSwitch.xcodeproj"
SCHEME="BrowserSwitch"
CONFIGURATION="Release"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/browserswitch-build.XXXXXX")"
INSTALL_DIR="$HOME/Applications"
APP_PATH="$BUILD_DIR/Build/Products/$CONFIGURATION/$SCHEME.app"

trap 'rm -rf "$BUILD_DIR"' EXIT

xcodebuild \
  -project "$ROOT_DIR/$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$BUILD_DIR" \
  build

rm -rf "$INSTALL_DIR/$SCHEME.app"
ditto "$APP_PATH" "$INSTALL_DIR/$SCHEME.app"

echo "Installed app: $INSTALL_DIR/$SCHEME.app"
