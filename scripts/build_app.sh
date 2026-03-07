#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/.."
APP="$ROOT/pomi.app"

echo "Building pomi..."
swift build -c release

echo "Creating app bundle..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp "$ROOT/.build/release/pomi" "$APP/Contents/MacOS/pomi"
cp "$ROOT/pomi.app.template/Contents/Info.plist" "$APP/Contents/Info.plist" 2>/dev/null \
  || cp "$SCRIPT_DIR/../pomi.app.template/Contents/Info.plist" "$APP/Contents/Info.plist"

echo "Generating app icon..."
swift "$SCRIPT_DIR/generate_icon.swift"
iconutil -c icns "$ROOT/AppIcon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ROOT/AppIcon.iconset"

echo "Done! pomi.app created at: $APP"
