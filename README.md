# AppleScript RAMDisk

An AppleScript that creates an APFS-formatted RAMDisk on macOS. It allocates **10% of your physical RAM**, creates three folders (`TEMP`, `Downloads`, `Screenshot`) inside it, and sends macOS screenshots to `RAMDisk/Screenshot`. It can be packaged as an app that runs automatically at every login.

> Traditional Chinese step-by-step guide: see [`使用說明.txt`](使用說明.txt).

## Files

| File | Purpose |
| --- | --- |
| `RAMDisk.applescript` | The main script. |
| `1_一鍵打包並設定開機自動執行.command` | Compiles the script into `RAMDisk.app`, signs it locally, and adds it to Login Items. |
| `2_還原截圖位置與移除開機執行.command` | Restores your previous screenshot location and removes the Login Item. |
| `使用說明.txt` | Step-by-step guide (Traditional Chinese). |

## What the script does

1. **Skips if already created.** If `/Volumes/RAMDisk` exists, it shows a notification and stops, so memory is not allocated twice.
2. **Calculates the size.** Reads `sysctl -n hw.memsize`, takes 10% (`ramPercent`), and converts it to 512-byte blocks using shell integer math.
3. **Creates the RAM device.** `hdiutil attach -nomount ram://<blocks>`; only the device path (e.g. `/dev/disk4`) is kept.
4. **Formats it as APFS.** `diskutil eraseVolume APFS RAMDisk <device>`.
5. **Creates folders.** `mkdir -p` for `TEMP`, `Downloads`, `Screenshot`.
6. **Backs up the screenshot location (first run only).** Your previous setting is saved to `~/.ramdisk_screenshot_backup`.
7. **Redirects screenshots.** `defaults write com.apple.screencapture location /Volumes/RAMDisk/Screenshot`.
8. **Cleans up on failure.** If formatting or folder creation fails, the RAM device is detached so memory is not left allocated, and an error dialog is shown.

## Quick start

1. Download or clone this repository.
2. Right-click `1_一鍵打包並設定開機自動執行.command` → **Open** → **Open** (needed the first time because the file is not notarized).
3. If macOS asks whether Terminal may control System Events, click **OK**.
4. `RAMDisk` appears in the Finder sidebar with the three folders. It is recreated automatically at each login.

Manual alternative: open `RAMDisk.applescript` in Script Editor, then **File → Export… → Application**.

## Uninstall / restore

Run `2_還原截圖位置與移除開機執行.command` (right-click → Open). It restores your previous screenshot location and removes the Login Item. To free the memory right away, eject `RAMDisk` in Finder (or restart). Move anything you want to keep out of it first.

## Important notes

- **Volatile storage.** Everything in the RAMDisk is lost when you eject it, shut down, or restart. Screenshots are saved there too, so move important ones elsewhere.
- **Memory use.** The RAMDisk reserves 10% of physical RAM (about 1.6 GB on a 16 GB Mac). Change `ramPercent` at the top of the script to adjust.
- **`TEMP` and `Downloads` are only created.** Only screenshots are redirected automatically; point your browser or apps at these folders yourself if you want to use them.
- **If the RAMDisk was not created** (for example right after a restart), the screenshot location may point to a folder that does not exist. Launch `RAMDisk.app` again, or run the restore script.
- **Compatibility.** Requires macOS with APFS. The helper scripts use `zsh`, `osacompile`, `codesign`, and `osascript`, which ship with macOS.
