#!/bin/zsh
# 將 RAMDisk.applescript 編譯成 RAMDisk.app，並加入「登入項目」
set -e
cd "$(dirname "$0")"

# 目的地：/Applications 可寫就用它，否則用個人的 ~/Applications
if [ -w /Applications ]; then DEST="/Applications"; else DEST="$HOME/Applications"; mkdir -p "$DEST"; fi
APP="$DEST/RAMDisk.app"

echo "▶ 1/4 編譯 App 到 $APP"
rm -rf "$APP"
osacompile -o "$APP" RAMDisk.applescript

echo "▶ 2/4 本機簽章（ad-hoc），確保 Apple 晶片 Mac 可正常開啟"
codesign --force --deep --sign - "$APP"

echo "▶ 3/4 移除下載隔離標記"
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

echo "▶ 4/4 加入登入項目（首次會詢問是否允許「終端機」控制「系統事件」，請按「好」）"
osascript <<OSA
tell application "System Events"
	if exists login item "RAMDisk" then delete login item "RAMDisk"
	make login item at end with properties {path:"$APP", hidden:true}
end tell
OSA

echo ""
echo "✅ 完成！App 位置：$APP"
echo "   現在將立即執行一次以建立 RAMDisk…"
open "$APP"
