-- ==========================================================
-- RAMDisk.app（改良自 Dice2076/AppleScript-RAMDisk）
-- 功能：建立「實體記憶體 10%」大小的 APFS RAMDisk，
--       建立 TEMP / Downloads / Screenshot 資料夾，
--       並把 macOS 截圖自動存到 RAMDisk/Screenshot。
--       （第一次執行時，會先把原本的截圖位置備份到
--         ~/.ramdisk_screenshot_backup，還原時使用）
-- ==========================================================

property volName : "RAMDisk"
property ramPercent : 10
property subFolders : {"TEMP", "Downloads", "Screenshot"}
property backupFile : "$HOME/.ramdisk_screenshot_backup"

on run
	set volPath to "/Volumes/" & volName

	-- 1. 已存在就提示並結束（避免重複佔用記憶體）
	if (do shell script "[ -d " & quoted form of volPath & " ] && echo yes || echo no") is "yes" then
		display notification "RAMDisk 已存在，無需重複建立。" with title "RAMDisk"
		return
	end if

	-- 2. 在 shell 內以整數計算區塊數（避免 AppleScript 大數字變成科學記號）
	set blockCount to do shell script "echo $(( $(sysctl -n hw.memsize) * " & ramPercent & " / 100 / 512 ))"

	-- 3. 建立未掛載的記憶體磁碟，只取第一欄的裝置路徑（例如 /dev/disk4）
	set deviceName to do shell script "hdiutil attach -nomount ram://" & blockCount & " | head -n 1 | awk '{print $1}'"

	try
		-- 4. 格式化為 APFS 並命名
		do shell script "diskutil eraseVolume APFS " & quoted form of volName & " " & deviceName

		-- 5. 建立資料夾（-p：已存在也不報錯）
		repeat with f in subFolders
			do shell script "mkdir -p " & quoted form of (volPath & "/" & f)
		end repeat

		-- 6. 第一次執行時，備份原本的截圖位置（備份檔已存在就不再覆蓋）
		--    若原本位置就是 RAMDisk（舊版留下的設定），則記為空白＝系統預設
		set shotPath to volPath & "/Screenshot"
		do shell script "f=\"" & backupFile & "\"; [ -f \"$f\" ] || { p=$(defaults read com.apple.screencapture location 2>/dev/null) || p=\"\"; [ \"$p\" = " & quoted form of shotPath & " ] && p=\"\"; printf '%s' \"$p\" > \"$f\"; }"

		-- 7. 截圖存放位置導向 RAMDisk/Screenshot
		do shell script "defaults write com.apple.screencapture location " & quoted form of shotPath & "; killall SystemUIServer >/dev/null 2>&1 || true"

		display notification "已建立 RAMDisk（實體記憶體 " & ramPercent & "%）。" with title "RAMDisk"
	on error errMsg
		-- 失敗時釋放剛才佔用的記憶體，避免殘留
		try
			do shell script "hdiutil detach " & deviceName & " -force"
		end try
		display dialog "建立 RAMDisk 失敗：" & return & errMsg buttons {"好"} default button 1 with icon stop
	end try
end run
