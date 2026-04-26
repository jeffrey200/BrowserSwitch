#!/usr/bin/env bash
set -euo pipefail

PROJECT="BrowserSwitch.xcodeproj"
SCHEME="BrowserSwitch"
CONFIGURATION="Release"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/browserswitch-build.XXXXXX")"
RELEASE_DIR="$ROOT_DIR/release"
INSTALL_DIR="$HOME/Applications"
APP_PATH="$BUILD_DIR/Build/Products/$CONFIGURATION/$SCHEME.app"

trap 'rm -rf "$BUILD_DIR"' EXIT

xcodebuild \
  -project "$ROOT_DIR/$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$BUILD_DIR" \
  build

mkdir -p "$RELEASE_DIR"
rm -rf "$RELEASE_DIR/$SCHEME.app"
ditto "$APP_PATH" "$RELEASE_DIR/$SCHEME.app"

rm -rf "$INSTALL_DIR/$SCHEME.app"
ditto "$RELEASE_DIR/$SCHEME.app" "$INSTALL_DIR/$SCHEME.app"

echo "Exported release app: $RELEASE_DIR/$SCHEME.app"
echo "Installed app: $INSTALL_DIR/$SCHEME.app"
