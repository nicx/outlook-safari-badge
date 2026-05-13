#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXT_DIR="$SCRIPT_DIR/Extension"
PROJ_DIR="$SCRIPT_DIR/OutlookSafariBadge"

if ! xcrun --find safari-web-extension-converter &>/dev/null; then
  echo "Fehler: safari-web-extension-converter nicht gefunden."
  echo "Bitte Xcode aus dem App Store installieren:"
  echo "  https://apps.apple.com/app/xcode/id497799835"
  exit 1
fi

if [ -d "$PROJ_DIR" ]; then
  echo "Projekt existiert bereits unter $PROJ_DIR"
  echo "Zum Neu-Erstellen zuerst löschen: rm -rf '$PROJ_DIR'"
  exit 1
fi

echo "Erstelle Xcode-Projekt aus Extension-Quellen..."
xcrun safari-web-extension-converter \
  "$EXT_DIR/" \
  --app-name OutlookSafariBadge \
  --bundle-identifier app.outlookbadge \
  --project-location "$SCRIPT_DIR/" \
  --no-open

echo ""
echo "Fertig! Nächste Schritte:"
echo ""
echo "  1. Xcode öffnen:"
echo "     open '$PROJ_DIR/OutlookSafariBadge.xcodeproj'"
echo ""
echo "  2. In Xcode: Scheme 'OutlookSafariBadge' wählen → ⌘R"
echo ""
echo "  3. Safari → Einstellungen → Erweiterungen → 'Outlook Unread Badge' aktivieren"
echo ""
echo "  4. Outlook-PWA öffnen → Zugriff auf outlook.cloud.microsoft erlauben"
