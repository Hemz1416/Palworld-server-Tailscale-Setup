# Configure-Connection.ps1
# Interactive configuration tool for Tailscale Game Connection Setup
[CmdletBinding()]
param()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }
$RootDir = Split-Path -Parent $ScriptDir
$ConfigPath = Join-Path $RootDir "Config\connection.json"
$PresetsPath = Join-Path $RootDir "Config\games-presets.json"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         TAILSCALE CONNECTION SETUP - CONFIGURATION BUILDER" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Configure server details, game presets, and credentials to distribute to friends." -ForegroundColor Gray
Write-Host ""

# Load existing values
$existing = [PSCustomObject]@{
    appName = "Hemz Tailscale Connection Setup"
    serverName = "Hemz Dedicated Game Server"
    serverPort = 25565
    serverDeviceName = "hemz"
    serverMagicDnsName = ""
    serverTailscaleIp = "100.97.56.52"
    tailscaleInviteUrl = ""
    serverPassword = ""
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

# 1. Select Game Preset or Custom
Write-Host "Select Target Game / Service:" -ForegroundColor Yellow
Write-Host "  [1] Minecraft: Java Edition (Port 25565)"
Write-Host "  [2] Minecraft: Bedrock Edition (Port 19132)"
Write-Host "  [3] Palworld Dedicated Server (Port 8211)"
Write-Host "  [4] Valheim Dedicated Server (Port 2456)"
Write-Host "  [5] Terraria / tModLoader (Port 7777)"
Write-Host "  [6] Enshrouded Dedicated Server (Port 15636)"
Write-Host "  [7] Custom Game / Custom Port"
$gameChoice = Read-Host "Choose preset [1-7, Default: 1]"

$selectedName = "Minecraft: Java Edition"
$selectedPort = 25565

switch ($gameChoice) {
    "1" { $selectedName = "Minecraft: Java Edition"; $selectedPort = 25565 }
    "2" { $selectedName = "Minecraft: Bedrock Edition"; $selectedPort = 19132 }
    "3" { $selectedName = "Palworld Dedicated Server"; $selectedPort = 8211 }
    "4" { $selectedName = "Valheim Dedicated Server"; $selectedPort = 2456 }
    "5" { $selectedName = "Terraria Server"; $selectedPort = 7777 }
    "6" { $selectedName = "Enshrouded Server"; $selectedPort = 15636 }
    "7" {
        $selectedName = Read-Host "Enter Game / Service Name [$($existing.serverName)]"
        if ([string]::IsNullOrWhiteSpace($selectedName)) { $selectedName = $existing.serverName }
        $portInput = Read-Host "Enter Server Port [$($existing.serverPort)]"
        $selectedPort = if ([string]::IsNullOrWhiteSpace($portInput)) { [int]$existing.serverPort } else { [int]$portInput }
    }
    Default {
        if (-not [string]::IsNullOrWhiteSpace($existing.serverName)) { $selectedName = $existing.serverName }
        if ($existing.serverPort -gt 0) { $selectedPort = [int]$existing.serverPort }
    }
}

# 2. Server Tailscale Device Name
$sDevice = Read-Host "Tailscale Server Device Name [$($existing.serverDeviceName)]"
if ([string]::IsNullOrWhiteSpace($sDevice)) { $sDevice = $existing.serverDeviceName }

# 3. Server Tailscale IPv4
$sIp = Read-Host "Server Tailscale IPv4 Address [$($existing.serverTailscaleIp)]"
if ([string]::IsNullOrWhiteSpace($sIp)) { $sIp = $existing.serverTailscaleIp }

# 4. Tailscale Machine Share Invitation URL
Write-Host "  (Generate from Tailscale Admin -> Machines -> Share)" -ForegroundColor DarkGray
$sInvite = Read-Host "Tailscale Machine Share Invitation URL (press Enter to skip) [$($existing.tailscaleInviteUrl)]"
if ([string]::IsNullOrWhiteSpace($sInvite)) { $sInvite = $existing.tailscaleInviteUrl }

# 5. Optional Server Password
$sPwd = Read-Host "Optional Server Password (press Enter if none) [$($existing.serverPassword)]"
if ([string]::IsNullOrWhiteSpace($sPwd)) { $sPwd = $existing.serverPassword }

$newConfig = [ordered]@{
    appName = "Hemz Tailscale Connection Setup"
    serverName = $selectedName
    serverPort = $selectedPort
    serverDeviceName = $sDevice
    serverMagicDnsName = ""
    serverTailscaleIp = $sIp
    tailscaleInviteUrl = $sInvite
    serverPassword = $sPwd
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

$rebuild = Read-Host "Would you like to build the Release package now with these settings? (Y/N) [Y]"
if ($rebuild -notmatch "N|no") {
    & (Join-Path $ScriptDir "Build-Release.ps1")
}
