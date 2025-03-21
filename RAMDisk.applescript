-- 取得實體 RAM 大小 (單位：Byte)
set memSize to do shell script "sysctl -n hw.memsize"

-- 將實體 RAM 除以 10，取得 10% 的 Byte，再換算成可用於 ram:// 的「512 Bytes 區塊數」
-- ram:// 模式需要傳入「512 Bytes 區塊」總數才能建立對應大小的 RAM Disk
set ramDiskBlockCount to (memSize / 10) / 512
set ramDiskBlockCount to round (ramDiskBlockCount)

-- 透過 hdiutil attach -nomount 建立空白的 ram://，並回傳裝置名稱 (例如 /dev/disk4)
set deviceInfo to do shell script ("hdiutil attach -nomount ram://" & ramDiskBlockCount)
-- deviceInfo 可能會包含多行資訊，我們只需要第一行的裝置路徑部分
-- 通常第一行會是 /dev/diskX，但保險起見，先分行再取第一行
set deviceName to paragraph 1 of deviceInfo

-- 使用 diskutil 以 APFS 格式化該裝置，並指定 Volume 名稱為「RAMDisk」
do shell script "diskutil eraseVolume APFS RAMDisk " & deviceName

-- 在該 APFS RAMDisk 上建立 TEMP、Downloads、Screenshot 資料夾
do shell script "mkdir /Volumes/RAMDisk/TEMP"
do shell script "mkdir /Volumes/RAMDisk/Downloads"
do shell script "mkdir /Volumes/RAMDisk/Screenshot"
