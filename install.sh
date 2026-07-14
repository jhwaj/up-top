#!/bin/bash
# 업무 캘린더 설치 (맥) — 받는 맥에서 앱을 직접 만들어 로컬 서명하므로
# 다른 맥에서 만든 서명/검역 문제 없이 항상 열린다. 아이콘은 투명 먼지.
#   curl -fsSL https://jhwaj.github.io/up-top/install.sh | bash
set -euo pipefail

APP_NAME="업무 캘린더"
BASE="https://jhwaj.github.io/up-top"

echo "▶ 업무 캘린더 설치를 시작합니다…"
if [ -w "/Applications" ]; then DEST="/Applications"; else DEST="$HOME/Applications"; fi
mkdir -p "$DEST"
APP="$DEST/$APP_NAME.app"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
echo "▶ 리소스 다운로드…"
curl -fsSL "$BASE/standalone.html" -o "$TMP/index.html"
curl -fsSL "$BASE/app.icns" -o "$TMP/app.icns"

echo "▶ 앱 생성…"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$TMP/index.html" "$APP/Contents/Resources/index.html"
cp "$TMP/app.icns"   "$APP/Contents/Resources/app.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>업무 캘린더</string>
<key>CFBundleDisplayName</key><string>업무 캘린더</string>
<key>CFBundleIdentifier</key><string>com.jhwaj.uptop</string>
<key>CFBundleVersion</key><string>1.0</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleExecutable</key><string>run</string>
<key>CFBundleIconFile</key><string>app</string>
<key>NSHighResolutionCapable</key><true/>
<key>LSMinimumSystemVersion</key><string>10.13</string>
</dict></plist>
PLIST

cat > "$APP/Contents/MacOS/run" <<'RUN'
#!/bin/bash
RES="$(cd "$(dirname "$0")/../Resources" && pwd)"
APPDIR="$HOME/.uptop-calendar"; mkdir -p "$APPDIR"
cp -f "$RES/index.html" "$APPDIR/index.html"
URL="file://$APPDIR/index.html"; PROFILE="$APPDIR/profile"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ -x "$CHROME" ]; then
  exec "$CHROME" --user-data-dir="$PROFILE" --app="$URL" --no-first-run --no-default-browser-check
else
  exec /usr/bin/open "$URL"
fi
RUN
chmod +x "$APP/Contents/MacOS/run"

# 받는 맥에서 로컬 ad-hoc 서명 → 이 기기에서 확실히 실행됨 (검역도 제거)
codesign --force --deep --sign - "$APP" 2>/dev/null || true
xattr -cr "$APP" 2>/dev/null || true

echo "✔ 설치 완료: $APP"
echo "▶ 실행합니다…"
open "$APP"
echo "다음부터는 런치패드/응용 프로그램에서 '업무 캘린더' 아이콘을 실행하세요."
