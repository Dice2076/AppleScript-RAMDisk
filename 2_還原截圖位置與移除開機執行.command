#!/bin/zsh
# 不想再用 RAMDisk 時執行：截圖位置還原為原本設定、移除登入項目
BACKUP="$HOME/.ramdisk_screenshot_backup"

if [ -s "$BACKUP" ]; then
  OLD="$(cat "$BACKUP")"
  defaults write com.apple.screencapture location "$OLD"
  echo "↩ 截圖位置已還原為你原本的設定：$OLD"
else
  defaults delete com.apple.screencapture location 2>/dev/null || true
  echo "↩ 截圖位置已還原為系統預設（桌面）"
fi
rm -f "$BACKUP"
killall SystemUIServer >/dev/null 2>&1 || true

osascript -e 'tell application "System Events" to if exists login item "RAMDisk" then delete login item "RAMDisk"'

echo "✅ 已移除 RAMDisk 登入項目。"
echo "ℹ️  RAMDisk 目前仍佔用記憶體：請在 Finder 側邊欄對「RAMDisk」按退出鈕，或直接重新開機。"
echo "   （退出後，裡面的檔案會全部消失，請先搬走需要的檔案。）"
echo "   如需刪除 App，請將「應用程式」中的 RAMDisk.app 拖到垃圾桶。"
