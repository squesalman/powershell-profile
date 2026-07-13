if (-not $PSScriptRoot) {
    throw 'This script must be run directly, not dot-sourced. Use: .\setprofile.ps1'
}

$profilePath = $PROFILE.CurrentUserCurrentHost
$profileDir = Split-Path -Path $profilePath -Parent
$sourcePath = Join-Path -Path $PSScriptRoot -ChildPath 'Microsoft.PowerShell_profile.ps1'

if (-not (Test-Path -Path $sourcePath -PathType Leaf)) {
    throw "Profile source file not found: $sourcePath"
}

if (-not (Test-Path -Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}

if (Test-Path -Path $profilePath -PathType Leaf) {
    $backupName = (Get-Date -Format 'yyMMdd') + '_oldprofile_Microsoft.PowerShell_profile.ps1'
    $backupPath = Join-Path $profileDir $backupName

    if (Test-Path -Path $backupPath -PathType Leaf) {
        Write-Warning "Backup already exists for today: [$backupPath]. Skipping backup to avoid overwrite."
    } else {
        try {
            Copy-Item -Path $profilePath -Destination $backupPath -Force -ErrorAction Stop
            Write-Host "Previous profile backed up to [$backupPath]."
        } catch {
            throw "Failed to back up existing profile: $_"
        }
    }
}

Copy-Item -Path $sourcePath -Destination $profilePath -Force
Write-Host "Profile installed to [$profilePath]."

try {
    [Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', [EnvironmentVariableTarget]::Machine)
    Write-Host 'PowerShell telemetry opt-out set.'
} catch {
    Write-Warning "Could not set telemetry opt-out (run as Administrator to apply): $_"
}
