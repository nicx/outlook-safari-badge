#!/bin/bash
# Packt dist/OutlookSafariBadge.app in ein zip für die Verteilung.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
APP="$DIST_DIR/OutlookSafariBadge.app"

if [ ! -d "$APP" ]; then
  echo "Fehler: $APP nicht gefunden. Erst ./build-release.sh ausführen."
  exit 1
fi

cd "$DIST_DIR"
rm -f OutlookSafariBadge.zip

# ditto erhält Resource-Forks/Metadata besser als zip für macOS-Apps
ditto -c -k --sequesterRsrc --keepParent OutlookSafariBadge.app OutlookSafariBadge.zip

SIZE=$(du -sh OutlookSafariBadge.zip | awk '{print $1}')
echo "✓ $DIST_DIR/OutlookSafariBadge.zip ($SIZE)"
echo ""
echo "Verteilen: zip per Slack/Email/USB an Kollegen schicken."
echo "Sie folgen den Schritten im README, Abschnitt 'Für deine Kollegen'."
