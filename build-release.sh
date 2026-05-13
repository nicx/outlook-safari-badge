#!/bin/bash
# Builds an ad-hoc-signed Release .app for distribution.
# - Does NOT expire (unlike Personal-Team-signed Debug builds)
# - Runs on any Mac after a one-time Gatekeeper bypass
# - Safari still requires "Allow Unsigned Extensions" each Safari restart
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_DIR="$SCRIPT_DIR/OutlookSafariBadge"
DIST_DIR="$SCRIPT_DIR/dist"

if [ ! -d "$PROJ_DIR" ]; then
  echo "Fehler: $PROJ_DIR existiert nicht. Erst ./setup.sh ausführen."
  exit 1
fi

echo "→ Baue Release-Konfiguration (ad-hoc signed)..."
cd "$PROJ_DIR"

xcodebuild \
  -project OutlookSafariBadge.xcodeproj \
  -scheme OutlookSafariBadge \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY=- \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGNING_ALLOWED=YES \
  DEVELOPMENT_TEAM="" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  -quiet

APP_BUILT="$PROJ_DIR/build/Build/Products/Release/OutlookSafariBadge.app"

if [ ! -d "$APP_BUILT" ]; then
  echo "Fehler: Build-Ergebnis nicht gefunden unter $APP_BUILT"
  exit 1
fi

mkdir -p "$DIST_DIR"
rm -rf "$DIST_DIR/OutlookSafariBadge.app"
cp -R "$APP_BUILT" "$DIST_DIR/"

# Remove quarantine flag so the app doesn't get marked as downloaded
xattr -cr "$DIST_DIR/OutlookSafariBadge.app" 2>/dev/null || true

echo ""
echo "✓ Fertig: $DIST_DIR/OutlookSafariBadge.app"
echo ""
echo "Test lokal:"
echo "  open '$DIST_DIR/OutlookSafariBadge.app'"
echo ""
echo "Zur Verteilung packen:"
echo "  ./package.sh"
