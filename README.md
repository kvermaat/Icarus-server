# Icarus Dedicated Server Auto-Update & Backup Script

PowerShell startup script for **Icarus Dedicated Server** that automatically updates, backs up, and manages retention without external tools.

Designed for Windows servers running SteamCMD.

---

## Features

* Daily automatic Steam update (runs only once per day)
* Automatic full server backup on every start
* Date + time structured backups
  `D:\Back-up\icarus\YYYY-MM-DD\HH-MM-SS\`
* Configurable number of backups per day
* Configurable backup retention days
* Optional backup enable/disable switch
* Automatic cleanup of old backups
* Safe robocopy mirroring (reliable for large save worlds)
* No scheduled tasks required — just run `start.bat`

---

## Folder Example

```
D:\Back-up\icarus
 ├─ 2026-02-16
 │   ├─ 08-12-44
 │   ├─ 10-31-02
 │   ├─ 13-45-19
 │   ├─ 17-02-51
 │   └─ 21-18-03
 ├─ 2026-02-17
 │   ├─ 09-14-33
 │   └─ 18-55-09
```

Old backups are automatically removed based on your configured limits.

---

## Installation

1. Install SteamCMD and Icarus server normally
2. Place files inside your server folder:

```
C:\steamcmd\server-icarus\
    start.ps1
    start.bat
```

3. Run the server using `start.bat`

---

## Configuration

Open `start.ps1` and edit the configuration section:

```powershell
$SteamCmd   = "C:\steamcmd\steamcmd.exe"
$ServerDir  = "C:\steamcmd\server-icarus"
$BackupRoot = "D:\Back-up\icarus"

$ServerName = "SERVERNAME"
$Port       = 17777
$QueryPort  = 27015
$MaxPlayers = 8
$JoinPass   = "SUPERPASSWORD"
```

### Backup Settings

```powershell
$EnableBackup      = 1      # 1 = enabled, 0 = disabled
$MaxBackupsPerDay  = 5      # keep X backups per day
$MaxBackupDays     = 14     # delete days older than X
```

---

## How It Works

On every server start:

1. Checks if Steam update already ran today
2. Updates the server if needed
3. Creates a full backup snapshot
4. Removes excess backups for the same day
5. Removes backups older than X days
6. Starts the Icarus server

---

## Requirements

* Windows 10/11 or Windows Server
* PowerShell 5+ (default on Windows)
* SteamCMD
* Icarus Dedicated Server

No additional software required.

---

## Notes

* Backups are full mirrors, not incremental
* Safe for large save files
* Recommended to use SSD for server and HDD for backups
* Script is restart-safe
* if needed make bat file to run

## Bat file
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\steamcmd\server-icarus\start.ps1"


---

## License

Free to use and modify.
