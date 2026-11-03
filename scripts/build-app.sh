#!/bin/zsh
# Builds, signs and installs "Butcher Hero.app" (native collector + statistics).
# Usage: scripts/build-app.sh [--no-install]
set -euo pipefail
cd "${0:A:h}/.."

APP_NAME="Butcher Hero"
BUNDLE_ID="com.dankhazipeter.butcherhero"
DIST="dist"
APP="$DIST/$APP_NAME.app"
INSTALL_DIR="$HOME/Applications"

swift build -c release --product ButcherHeroApp
BIN=".build/release"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN/ButcherHeroApp" "$APP/Contents/MacOS/ButcherHeroApp"
# SwiftPM resource bundles are looked up in Contents/Resources inside an app.
cp -R "$BIN/ButcherHeroBot_RewardAutomationCore.bundle" "$BIN/ButcherHeroBot_ButcherHeroApp.bundle" "$APP/Contents/Resources/"

ICONSET="$DIST/AppIcon.iconset"
rm -rf "$ICONSET" && mkdir -p "$ICONSET"
swift scripts/make-app-icon.swift "$DIST/icon-1024.png"
for s in 16 32 128 256 512; do
  sips -z $s $s "$DIST/icon-1024.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) "$DIST/icon-1024.png" --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>ButcherHeroApp</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleDisplayName</key><string>$APP_NAME</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>$(git rev-list --count HEAD 2>/dev/null || echo 1)</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>CFBundleDevelopmentRegion</key><string>hu</string>
</dict></plist>
PLIST

# A stable signing identity keeps the Accessibility / Screen Recording grants across rebuilds.
IDENTITY=$(security find-identity -v -p codesigning | awk -F'"' '/Apple Development/{print $2; exit}')
if [[ -n "$IDENTITY" ]]; then
  codesign --force --sign "$IDENTITY" --identifier "$BUNDLE_ID" "$APP"
else
  echo "Nincs Apple Development tanúsítvány; ad-hoc aláírás (az engedélyeket minden build után újra kell adni)." >&2
  codesign --force --sign - --identifier "$BUNDLE_ID" "$APP"
fi
codesign --verify --strict "$APP"

if [[ "${1:-}" != "--no-install" ]]; then
  mkdir -p "$INSTALL_DIR"
  rm -rf "$INSTALL_DIR/$APP_NAME.app"
  cp -R "$APP" "$INSTALL_DIR/"
  echo "Telepítve: $INSTALL_DIR/$APP_NAME.app"
fi
