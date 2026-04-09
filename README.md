# detaroxzAutoDM
Unlock true native-style auto dark mode on Windows with a blazing-light PowerShell engine—no background bloat, no unnecessary RAM usage, just pure intelligent theme switching.

Unlike basic registry tweaks that leave your Taskbar and File Explorer stuck in a "zombie" state until you restart them, this script utilizes a C# system broadcast to instantly and seamlessly refresh your UI—mimicking the exact behavior of the native Windows Settings app.


## Features

- **All-in-One Installer:** A single script sets up the directory, generates the core files, and configures Windows Task Scheduler automatically.
- **Seamless UI Refresh:** Transitions themes instantly without needing to restart `explorer.exe` or flash your screen.
- **Interactive Settings Updater:** Easily change your scheduled times later without ever opening the clunky Task Scheduler interface.
- **Clean Uninstaller:** Includes a self-destruct script to completely remove the scheduled tasks and files if you ever want to revert.
- **Zero Background Footprint:** Uses standard Windows Task Scheduler to run the script for ~1 second twice a day. No background apps or memory hogs required.

## Installation

1. Download or copy the `setup.zip` file to your computer and extract it.
2. Open the setup folder and **Right-click** `setup.bat` and select **Run as adminirstrator** (or run it from an elevated Administrator PowerShell terminal).
3. When prompted, enter your desired times for Light and Dark mode (e.g., `7:00 AM` and `7:00 PM`) and select the Log-on settings as you like.
4. The installer will create the necessary directory, generate the scripts, and configure the background tasks.
5. You can safely delete the `setup.zip` file and the `setup` folder once setup is complete.

## How It Works

During setup, the installer creates a dedicated folder at `C:\Scripts\detaroxzautodarkmode` containing three perfectly packaged tools:

### 1. `Set-Theme.ps1` (The Engine)
This is the core script triggered invisibly by Windows Task Scheduler. It modifies the `HKCU` Personalize registry keys and broadcasts a `WM_SETTINGCHANGE` message to force all open applications to immediately paint the new theme. 

### 2. `Settings.ps1` (The Settings Editor)
If you want to adjust your schedule (e.g., earlier dark mode in the winter), simply **Right-click -> Run with PowerShell** on this file. It will ask for your new times and seamlessly update Task Scheduler for you.

### 3. `Uninstall-AutoTheme.ps1` (The Cleaner)
If you ever want to remove the program, **Right-click -> Run with PowerShell** on this file. It will safely unregister the background tasks from Windows and permanently delete the `C:\Scripts\detaroxzautodarkmode` folder, leaving zero trace on your system.

## Troubleshooting

- **Theme isn't changing?** Ensure that the tasks were created under your specific Windows User Account and that you are logged in at the time of the scheduled change. Task Scheduler isolates visual tasks to "Session 0" if set to run when the user is not logged in.
- **Red error text during install?** Make sure you are running the installer as an Administrator, as creating Scheduled Tasks requires elevated privileges.


Thanks for visiting this repo! I'm still learning:)

I'm a student, if you want to help me in study then I think you know what to do, UPI: architm193@okicici
