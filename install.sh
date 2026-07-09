#!/bin/bash
# 업무 캘린더 설치 스크립트
#   curl -fsSL https://jhwaj.github.io/up-top/install.sh | bash
set -euo pipefail

APP_NAME="업무 캘린더"
ZIP_URL="https://github.com/jhwaj/up-top/releases/latest/download/uptop-mac.zip"

echo "▶ 업무 캘린더 설치를 시작합니다…"

# 관리자 권한 없이 되도록 /Applications 쓰기 가능하면 거기, 아니면 ~/Applications
if [ -w "/Applications" ]; then
  DEST="/Applications"
else
  DEST="$HOME/Applications"
fi
mkdir -p "$DEST"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "▶ 다운로드 중…"
curl -fsSL "$ZIP_URL" -o "$TMP/uptop-mac.zip"

echo "▶ 압축 해제 중…"
ditto -x -k "$TMP/uptop-mac.zip" "$TMP/out"

echo "▶ 설치 중… ($DEST)"
rm -rf "$DEST/$APP_NAME.app"
cp -R "$TMP/out/$APP_NAME.app" "$DEST/"

# 터미널(curl) 설치는 검역이 안 붙지만, 혹시 모를 Gatekeeper 경고 방지용으로 제거
xattr -cr "$DEST/$APP_NAME.app" 2>/dev/null || true

echo "✔ 설치 완료: $DEST/$APP_NAME.app"
echo "▶ 실행합니다…"
open "$DEST/$APP_NAME.app"
echo "다음부터는 런치패드/응용 프로그램에서 '업무 캘린더' 아이콘을 실행하세요."
