# Icarus Dedicated Server Auto-Update & Backup Script

PowerShell startup script for **Icarus Dedicated Server** that automatically updates, backs up, and manages retention without external tools.

Designed for Windows servers running SteamCMD.

---

## Features

* Daily automatic Steam update (runs only once per day)
* Automatic backup on every start
* **Selectable backup mode: full server OR save-only**
* Date + time structured backups
  `BACKUP_PATH\YYYY-MM-DD\HH-MM-SS\`
* Configurable number of backups per day
* Configurable backup retention days
* Optional backup enable/disable switch
* Automatic cleanup of old backups
* Reliable robocopy mirroring (handles large worlds safely)
* No scheduled tasks required — just run `start.bat`

---

## Backup Modes

The script supports two backup types:

### Full Backup (`full`)

Creates a complete mirror of the entire server folder.

Backs up:

* World save data
* Player data
* Config files
* Mods
* Binaries
* Everything needed to fully restore the server

Recommended if you want maximum safety or run mods.

---

### Save-Only Backup (`save`)

Backs up only the persistent world data.

Best for:

* Frequent restarts
* Saving disk space
* Faster backups

*(You can still restore the world, but not server configs/mod installs)*

---

## Folder Example

```
BACKUP_PATH
 ├─ 2026-02-16
 │   ├─ 08-12-44
 │   ├─ 10-31-02
 │   ├─ 13-45-19
 │   ├─ 17-02-51
 │   └─ 21-18-03
```

Old backups are automatically removed based on your configured limits.

---

## Installation

1. Install SteamCMD and the Icarus dedicated server normally
2. Place files inside your server folder:

```
YOUR_SERVER_FOLDER\
    start.ps1
    start.bat
```

3. Run the server using `start.bat`

---

## Configuration

Open `start.ps1` and fill in your own values:

```powershell
# Paths
$SteamCmd   = "PATH_TO_STEAMCMD_EXE"
$ServerDir  = "PATH_TO_SERVER_FOLDER"
$BackupRoot = "PATH_TO_BACKUP_FOLDER"

# Server Settings
$ServerName = "YOUR_SERVER_NAME"
$Port       = YOUR_GAME_PORT
$QueryPort  = YOUR_QUERY_PORT
$MaxPlayers = PLAYER_COUNT
$JoinPass   = "SERVER_PASSWORD"
```

### Backup Settings

```powershell
$EnableBackup      = 1          # 1 = enabled, 0 = disabled
$BackupMode        = "full"     # "full" or "save"
$MaxBackupsPerDay  = 5          # keep X backups per day
$MaxBackupDays     = 14         # delete days older than X
```

---

## How It Works

On every server start:

1. Checks if Steam update already ran today
2. Updates the server if needed
3. Creates a backup (full or save-only depending on mode)
4. Removes excess backups for the same day
5. Removes backups older than X days
6. Starts the Icarus server

---

## Requirements

* Windows 10/11 or Windows Server
* PowerShell 5+
* SteamCMD
* Icarus Dedicated Server

No additional software required.

---

## Notes

* Full backups allow complete server restore
* Sav
* was made and tested on Win 2025 std
