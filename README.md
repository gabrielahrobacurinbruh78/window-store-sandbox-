# Local Microsoft Store and App Installer for Windows Sandbox

This project gets the **Microsoft Store** and your favorite default apps working inside **Windows Sandbox**. 

It runs entirely offline. There are no internet downloads, no web scraping, and no sketchy third-party sites. Instead, it temporarily links to your main computer's system files, copies the official app packages, and installs them directly into your sandbox.

## Why This Matters

Windows Sandbox usually loads a stripped-down version of Windows that has no Microsoft Store and missing default apps. 

Most online scripts fix this by downloading installation files from the internet, which can be slow unsafe or useless if offline. This script does everything locally. It looks inside your main computer's system folders, finds the required frameworks, installs them in the right order, and brings back the apps you actually use.

## What It Adds Back

Along with the **Microsoft Store**, this setup force-registers these essential apps so they show up right in your Start Menu:
* Windows Calculator
* Notepad
* Photos
* App Installer (WinGet foundation)
* Sticky Notes

## Key Features

* **Completely Offline:** You do not need an active internet connection inside the sandbox just in case you have no wifi.
* **100% Safe:** It only uses official, Microsoft-signed files already sitting on your hard drive.
* **No Crashing:** The code is smart enough to skip duplicate files and version mismatches without breaking.
* **Hardware Boost:** The setup file gives the sandbox 16GB of RAM and graphics acceleration so everything runs smoothly.

## Files in This Repo

1. **`OfflineStore.wsb`** - The setup configuration. It builds the sandbox, turns off the internet, boosts your hardware, and safely links your host folders.
2. **`DeployEngine.ps1`** - The muscle. This PowerShell script handles the heavy lifting, scans the folders, and registers the apps.

## How to Use It

1. Save both `OfflineStore.wsb` and `DeployEngine.ps1` to your main computer's desktop.
2. Double-click `OfflineStore.wsb` to launch your new sandbox.
3. Drag and drop the `DeployEngine.ps1` file from your main computer onto the sandbox desktop.
4. The sandbox will automatically open a command window and run the setup for you.
5. Once the script finishes, the Microsoft Store will open automatically, and your missing apps will be ready to use.
