$ErrorActionPreference = "Stop"

# =========================
# Configuration (EDIT THESE)
# =========================

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

# Backup Settings
$EnableBackup      = 1          # 1 = enabled, 0 = disabled
$BackupMode        = "full"     # "full" or "save"
$MaxBackupsPerDay  = 5          # max backups kept per day
$MaxBackupDays     = 14         # days to keep backups

# =========================
# Internal
# =========================
$UpdateStamp = Join-Path $ServerDir "last_update.txt"
$Today       = Get-Date -Format "yyyy-MM-dd"

# =========================
# Update (once per day)
# =========================
$DoUpdate = $true
if (Test-Path $UpdateStamp) {
    $Last = (Get-Content $UpdateStamp -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
    if ($Last -eq $Today) { $DoUpdate = $false }
}

if ($DoUpdate) {
    Write-Host "[$(Get-Date)] Running daily update ($Today)..."
    & $SteamCmd +force_install_dir $ServerDir +login anonymous +app_update 2089300 validate +quit
    Set-Content -Path $UpdateStamp -Value $Today -Encoding ASCII
}
else {
    Write-Host "[$(Get-Date)] Update already ran today ($Today). Skipping Steam update."
}

# =========================
# Backup
# =========================
if ($EnableBackup -eq 1) {

    $DateFolder = Join-Path $BackupRoot $Today
    $TimeStamp  = Get-Date -Format "HH-mm-ss"
    $BackupDir  = Join-Path $DateFolder $TimeStamp
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

    if ($BackupMode -eq "save") {
        Write-Host "[$(Get-Date)] Running SAVE-ONLY backup..."

        # Default Icarus save location
        $SavePath = Join-Path $env:LOCALAPPDATA "Icarus\Saved"

        if (!(Test-Path $SavePath)) {
            Write-Warning "Save folder not found: $SavePath"
        } else {
            robocopy $SavePath $BackupDir /MIR /R:2 /W:2 /XJ | Out-Host
        }
    }
    else {
        Write-Host "[$(Get-Date)] Running FULL backup..."
        robocopy $ServerDir $BackupDir /MIR /R:2 /W:2 /XJ | Out-Host
    }

    # =========================
    # Limit backups per day
    # =========================
    if ($MaxBackupsPerDay -gt 0) {
        $DailyBackups = Get-ChildItem $DateFolder -Directory | Sort-Object Name
        if ($DailyBackups.Count -gt $MaxBackupsPerDay) {
            $ToDelete = $DailyBackups | Select-Object -First ($DailyBackups.Count - $MaxBackupsPerDay)
            foreach ($b in $ToDelete) {
                Write-Host "Removing old same-day backup $($b.FullName)"
                Remove-Item $b.FullName -Recurse -Force
            }
        }
    }

    # =========================
    # Cleanup old days
    # =========================
    if ($MaxBackupDays -gt 0) {
        $cutoff = (Get-Date).AddDays(-$MaxBackupDays)

        Get-ChildItem $BackupRoot -Directory |
        Where-Object {
            $_.Name -match '^\d{4}-\d{2}-\d{2}$' -and
            [datetime]$_.Name -lt $cutoff
        } |
        ForEach-Object {
            Write-Host "Deleting old backup day $($_.FullName)"
            Remove-Item $_.FullName -Recurse -Force
        }
    }
}
else {
    Write-Host "[$(Get-Date)] Backup disabled."
}

# =========================
# Start server
# =========================
Write-Host "[$(Get-Date)] Starting Icarus server..."
Set-Location $ServerDir
& ".\IcarusServer.exe" `
    "-SteamServerName=$ServerName" `
    "-Port=$Port" `
    "-QueryPort=$QueryPort" `
    "-Log" `
    "-maxplayers=$MaxPlayers" `
    "-JoinPassword=$JoinPass"
