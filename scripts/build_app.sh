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

# Code signing and notarization (optional)
# Set these environment variables to enable:
#   POMI_SIGN_IDENTITY  - your Developer ID Application identity
#   POMI_NOTARIZE_PROFILE - your notarytool keychain profile name
IDENTITY="${POMI_SIGN_IDENTITY:-}"
NOTARIZE_PROFILE="${POMI_NOTARIZE_PROFILE:-}"

if [ -n "$IDENTITY" ]; then
    echo "Code signing..."
    codesign --force --options runtime --sign "$IDENTITY" "$APP/Contents/MacOS/pomi"
    codesign --force --options runtime --sign "$IDENTITY" "$APP"

    if [ -n "$NOTARIZE_PROFILE" ]; then
        echo "Creating zip for notarization..."
        ditto -c -k --sequesterRsrc --keepParent "$APP" "$ROOT/pomi.app.zip"

        echo "Submitting for notarization (this may take a few minutes)..."
        xcrun notarytool submit "$ROOT/pomi.app.zip" --keychain-profile "$NOTARIZE_PROFILE" --wait

        echo "Stapling notarization ticket..."
        xcrun stapler staple "$APP"

        rm "$ROOT/pomi.app.zip"
        echo "Done! pomi.app is signed and notarized at: $APP"
    else
        echo "Done! pomi.app is signed (not notarized) at: $APP"
    fi
else
    echo "Done! pomi.app created at: $APP"
    echo "(To sign and notarize, set POMI_SIGN_IDENTITY and POMI_NOTARIZE_PROFILE)"
fi
