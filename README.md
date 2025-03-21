Below is a sample README.md in English that you can include in your GitHub repository. It provides an overview, usage instructions, and the AppleScript code snippet for creating an APFS RAMDisk of 10% of your physical RAM. You can modify the text as needed.

```markdown
# AppleScript RAMDisk

This repository contains an AppleScript that creates an APFS-formatted RAMDisk on macOS. The RAMDisk automatically allocates **10% of your physical RAM** and sets up three directories (`TEMP`, `Downloads`, and `Screenshot`) inside it. This can be useful for speeding up temporary file access or keeping certain data off persistent storage.

## Overview

1. **Retrieve physical RAM size**  
   Uses `sysctl -n hw.memsize` to get the total RAM (in bytes).

2. **Calculate the 10% size**  
   Divides the retrieved RAM size by 10, then converts the result into units of 512-byte blocks (required by the `ram://` scheme).

3. **Create the RAMDisk**  
   Uses `hdiutil attach -nomount ram://<block_count>` to generate an unmounted disk device.

4. **Format as APFS**  
   Runs `diskutil eraseVolume APFS RAMDisk <device_name>` to format the device as APFS.

5. **Create directories**  
   Makes three directories inside `/Volumes/RAMDisk`: `TEMP`, `Downloads`, and `Screenshot`.

## AppleScript Code

```applescript
-- Get total physical RAM size in bytes
set memSize to do shell script "sysctl -n hw.memsize"

-- Calculate 10% of total RAM, convert to 512-byte blocks (for ram://)
set ramDiskBlockCount to (memSize / 10) / 512
set ramDiskBlockCount to round (ramDiskBlockCount)

-- Create the RAMDisk device (e.g., /dev/disk4)
set deviceInfo to do shell script ("hdiutil attach -nomount ram://" & ramDiskBlockCount)
set deviceName to paragraph 1 of deviceInfo

-- Format the RAMDisk as APFS and name it "RAMDisk"
do shell script "diskutil eraseVolume APFS RAMDisk " & deviceName

-- Create required directories
do shell script "mkdir /Volumes/RAMDisk/TEMP"
do shell script "mkdir /Volumes/RAMDisk/Downloads"
do shell script "mkdir /Volumes/RAMDisk/Screenshot"
```

## Usage Instructions

1. **Clone this Repository**  
   Clone or download this repository to have the `.applescript` file on your machine.

2. **Open in Script Editor**  
   - Open the Script Editor (or AppleScript Editor) on your Mac.
   - Copy and paste the script code into a new AppleScript document (or open the included `.applescript` file directly).

3. **Run the Script**  
   - Click the "Play" (Run) button in Script Editor to execute.
   - A new volume named `RAMDisk` will appear in Finder under "Locations."
   - Inside the volume, you should see the directories: `TEMP`, `Downloads`, and `Screenshot`.

4. **(Optional) Export as an App**  
   - In Script Editor, go to `File > Export...`.
   - Choose "Application" in the "File Format" dropdown.
   - Save the generated `.app` file wherever convenient. Launching it will immediately create the RAMDisk and folders.

## Important Notes

- **Volatile Storage**: A RAMDisk is temporary—its contents are lost when you unmount it or shut down/restart your Mac.
- **Adjustable Size**: You can edit the script to use a different percentage of RAM by changing the calculation.  
- **Folder Structure**: Feel free to add or remove folders by editing the script’s `mkdir` commands.
- **Compatibility**: Tested on modern macOS versions supporting APFS. Older systems might need to adjust formatting commands accordingly.
