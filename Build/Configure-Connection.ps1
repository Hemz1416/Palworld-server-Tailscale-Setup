# Configure-Connection.ps1
# Interactive configuration tool for Hemz Palworld Connection Setup
[CmdletBinding()]
param()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }
$RootDir = Split-Path -Parent $ScriptDir
$ConfigPath = Join-Path $RootDir "Config\connection.json"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "       PALWORLD CONNECTION SETUP - CONFIGURATION BUILDER" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Configure the network details and credentials to distribute to friends." -ForegroundColor Gray
Write-Host ""

# Load existing values if present
$existing = [PSCustomObject]@{
    appName = "Hemz Palworld Connection Setup"
    serverName = "Hemz Palworld"
    serverPort = 8211
    serverDeviceName = "hemz"
    serverMagicDnsName = ""
    serverTailscaleIp = ""
    tailscaleInviteUrl = ""
    palworldServerPassword = ""
    palworldExecutableHint = ""
    connectionTimeoutSeconds = 30
}

if (Test-Path $ConfigPath) {
    try {
        $loaded = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if ($loaded) { $existing = $loaded }
    } catch {}
}

# 1. Server Name
$sName = Read-Host "1. Palworld Server Name [$($existing.serverName)]"
if ([string]::IsNullOrWhiteSpace($sName)) { $sName = $existing.serverName }

# 2. Server Port
$sPortStr = Read-Host "2. Palworld Server Port [$($existing.serverPort)]"
$sPort = if ([string]::IsNullOrWhiteSpace($sPortStr)) { [int]$existing.serverPort } else { [int]$sPortStr }

# 3. Server Tailscale Device Name
$sDevice = Read-Host "3. Tailscale Server Device Name (e.g., hemz or msi-laptop) [$($existing.serverDeviceName)]"
if ([string]::IsNullOrWhiteSpace($sDevice)) { $sDevice = $existing.serverDeviceName }

# 4. Optional MagicDNS Hostname
$sDns = Read-Host "4. Optional MagicDNS Hostname (press Enter to skip) [$($existing.serverMagicDnsName)]"
if ([string]::IsNullOrWhiteSpace($sDns)) { $sDns = $existing.serverMagicDnsName }

# 5. Optional Fallback Server Tailscale IPv4
$sIp = Read-Host "5. Optional Fallback Server Tailscale IPv4 (e.g., 100.x.x.x, leave blank for dynamic discovery) [$($existing.serverTailscaleIp)]"
if ([string]::IsNullOrWhiteSpace($sIp)) { $sIp = $existing.serverTailscaleIp }

# 6. Tailscale Machine Share Invitation URL
Write-Host "   (Generate a single-use machine-share link from Tailscale Admin -> Machines -> Share)" -ForegroundColor DarkGray
$sInvite = Read-Host "6. Tailscale Machine Share Invitation URL (press Enter to skip) [$($existing.tailscaleInviteUrl)]"
if ([string]::IsNullOrWhiteSpace($sInvite)) { $sInvite = $existing.tailscaleInviteUrl }

# 7. Palworld Server Password
Write-Host "   SECURITY NOTE: Anyone possessing the compiled EXE may potentially recover the server password." -ForegroundColor DarkYellow
$sPwd = Read-Host "7. Palworld Server Password [$($existing.palworldServerPassword)]"
if ([string]::IsNullOrWhiteSpace($sPwd)) { $sPwd = $existing.palworldServerPassword }

# 8. Include password in friend distribution
$incPwd = Read-Host "8. Include server password in friend configuration package? (Y/N) [Y]"
if ($incPwd -match "N|no") {
    $sPwd = ""
    Write-Host "   -> Password will be omitted from distribution package." -ForegroundColor Yellow
}

$newConfig = [ordered]@{
    appName = "Hemz Palworld Connection Setup"
    serverName = $sName
    serverPort = $sPort
    serverDeviceName = $sDevice
    serverMagicDnsName = $sDns
    serverTailscaleIp = $sIp
    tailscaleInviteUrl = $sInvite
    palworldServerPassword = $sPwd
    palworldExecutableHint = ""
    connectionTimeoutSeconds = 30
}

$jsonOutput = $newConfig | ConvertTo-Json -Depth 5
Set-Content -Path $ConfigPath -Value $jsonOutput -Encoding UTF8

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "Configuration saved to: $ConfigPath" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""

$rebuild = Read-Host "Would you like to build the Release EXE now with these settings? (Y/N) [Y]"
if ($rebuild -notmatch "N|no") {
    & (Join-Path $ScriptDir "Build-Release.ps1")
}
