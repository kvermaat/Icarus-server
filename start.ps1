# C:\steamcmd\server-icarus\start.ps1
$ErrorActionPreference = "Stop"

# =========================
# Configuration
# =========================
$SteamCmd   = "C:\steamcmd\steamcmd.exe"
$ServerDir  = "C:\steamcmd\server-icarus"
$BackupRoot = "D:\Back-up\icarus"

$ServerName = "Server"
$Port       = 17777
$QueryPort  = 27015
$MaxPlayers = 8
$JoinPass   = "SUPERPASSWORD"

# =========================
# Backup settings (NEW)
# =========================
$EnableBackup      = 1      # 1 = enable backups, 0 = disable backups
$MaxBackupsPerDay  = 5      # keep at most this many backups per day
$MaxBackupDays     = 14     # delete day folders older than this many days

$UpdateStamp = Join-Path $ServerDir "last_update.txt"
$Today       = Get-Date -Format "yyyy-MM-dd"

# =========================
# Update (only once per day)
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
} else {
    Write-Host "[$(Get-Date)] Update already ran today ($Today). Skipping Steam update."
}

# =========================
# Backup full server folder (DATE\TIME)
# =========================
if ($EnableBackup -eq 1) {

    $DateFolder = Join-Path $BackupRoot $Today
    $TimeStamp  = Get-Date -Format "HH-mm-ss"
    $BackupDir  = Join-Path $DateFolder $TimeStamp

    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

    Write-Host "[$(Get-Date)] Backing up '$ServerDir' -> '$BackupDir'..."
    & robocopy $ServerDir $BackupDir /MIR /R:2 /W:2 /XJ | Out-Host
    $rc = $LASTEXITCODE
    if ($rc -ge 8) { Write-Warning "Backup FAILED (robocopy exit code $rc)" }
    else { Write-Host "Backup complete (robocopy exit code $rc)" }

    # =========================
    # Keep max X backups per day
    # =========================
    if ($MaxBackupsPerDay -gt 0) {
        $DailyBackups = Get-ChildItem -Path $DateFolder -Directory -ErrorAction SilentlyContinue | Sort-Object Name
        if ($DailyBackups.Count -gt $MaxBackupsPerDay) {
            $ToDelete = $DailyBackups | Select-Object -First ($DailyBackups.Count - $MaxBackupsPerDay)
            foreach ($b in $ToDelete) {
                Write-Host "Removing old same-day backup $($b.FullName)"
                Remove-Item $b.FullName -Recurse -Force
            }
        }
    }

    # =========================
    # Cleanup backup DAYS older than X days
    # =========================
    if ($MaxBackupDays -gt 0) {
        Write-Host "[$(Get-Date)] Cleaning backups older than $MaxBackupDays days in '$BackupRoot'..."
        $cutoff = (Get-Date).AddDays(-$MaxBackupDays)

        Get-ChildItem -Path $BackupRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -match '^\d{4}-\d{2}-\d{2}$' -and
                [datetime]$_.Name -lt $cutoff
            } |
            ForEach-Object {
                Write-Host "Deleting old backup day $($_.FullName)"
                Remove-Item $_.FullName -Recurse -Force
            }
    }

} else {
    Write-Host "[$(Get-Date)] Backup is disabled (EnableBackup=$EnableBackup)."
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
