# Host-Setup.ps1
# Setup and validation script for the Palworld Dedicated Server Host PC
[CmdletBinding()]
param()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }
$ConfigPath = Join-Path $ScriptDir "Config\connection.json"
$ServerDir = "H:\Games\Pirated\Palworld server"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         PALWORLD DEDICATED SERVER: HOST PC TAILSCALE SETUP" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "This script configures and validates your host laptop on Tailscale." -ForegroundColor Gray
Write-Host ""

# 1. Check Tailscale Installation
Write-Host "[1/6] Checking Tailscale on Host Machine..." -ForegroundColor Yellow
$tsCli = (Get-Command tailscale.exe -ErrorAction SilentlyContinue).Source
if (-not $tsCli) {
    $candidates = @(
        "$env:ProgramFiles\Tailscale\tailscale.exe",
        "${env:ProgramFiles(x86)}\Tailscale\tailscale.exe",
        "$env:LocalAppData\Tailscale\tailscale.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $tsCli = $c; break }
    }
}

if (-not $tsCli) {
    Write-Host "  Tailscale is not installed on this host laptop." -ForegroundColor Yellow
    $install = Read-Host "  Would you like to download and install official Tailscale now? (Y/N) [Y]"
    if ($install -notmatch "N|no") {
        $tempInstaller = Join-Path $env:TEMP "tailscale-setup-latest.exe"
        Write-Host "  Downloading official Tailscale installer..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe" -OutFile $tempInstaller
        Write-Host "  Launching installer with UAC elevation (please click YES)..." -ForegroundColor Yellow
        Start-Process -FilePath $tempInstaller -ArgumentList "/quiet /norestart" -Verb RunAs -Wait
        try { Remove-Item $tempInstaller -Force } catch {}
        
        # Re-check
        $tsCli = "$env:ProgramFiles\Tailscale\tailscale.exe"
    }
}

if (-not (Test-Path $tsCli)) {
    Write-Host "  Tailscale CLI could not be located. Please install Tailscale manually and rerun." -ForegroundColor Red
    exit 1
}
Write-Host "  Tailscale CLI verified: $tsCli" -ForegroundColor Green

# 2. Check Authentication
Write-Host "`n[2/6] Verifying Tailscale Authentication..." -ForegroundColor Yellow
$statusJson = $null
try {
    $statusJson = & $tsCli status --json | ConvertFrom-Json
} catch {}

$online = ($statusJson.Self.Online -eq $true) -or ($statusJson.BackendState -eq "Running")
if (-not $online) {
    Write-Host "  Host is not logged into Tailscale (Backend state: $($statusJson.BackendState))." -ForegroundColor Yellow
    Write-Host "  Opening Tailscale sign-in..." -ForegroundColor Yellow
    & $tsCli login
    Write-Host "  Please complete sign-in in your browser and press Enter when finished." -ForegroundColor Cyan
    Read-Host "Press Enter to continue"
    try {
        $statusJson = & $tsCli status --json | ConvertFrom-Json
    } catch {}
}

# 3. Obtain Host Tailscale Details
Write-Host "`n[3/6] Inspecting Host Network Identity..." -ForegroundColor Yellow
$hostName = $statusJson.Self.HostName
if (-not $hostName) { $hostName = $env:COMPUTERNAME.ToLower() }
$dnsName = $statusJson.Self.DNSName
$hostIp = (& $tsCli ip -4 2>$null)

Write-Host "  Host Device Name : $hostName" -ForegroundColor Green
Write-Host "  Host Tailscale IP: $hostIp" -ForegroundColor Green
Write-Host "  Host MagicDNS    : $(if($dnsName){$dnsName}else{'(MagicDNS not configured)'})" -ForegroundColor Green

# 4. Optional Unattended Mode (Host PC only)
Write-Host "`n[4/7] Optional Unattended Mode Setup..." -ForegroundColor Yellow
Write-Host "  Unattended mode allows this host laptop to remain accessible on Tailscale" -ForegroundColor Gray
Write-Host "  even if Windows logs off or no user is signed into the desktop." -ForegroundColor Gray

$supportsUnattended = $false
try {
    $helpOut = & $tsCli set --help 2>&1 | Out-String
    if ($helpOut -match "--unattended") {
        $supportsUnattended = $true
    }
} catch {}

if ($supportsUnattended) {
    $enableUnattended = Read-Host "  Enable Tailscale Unattended Mode on this server host? (Y/N) [N]"
    if ($enableUnattended -match "Y|yes") {
        Write-Host "  Enabling unattended mode (requires Administrator)..." -ForegroundColor Yellow
        Start-Process powershell.exe -ArgumentList "-NoProfile -Command `"`"$tsCli`" set --unattended`"" -Verb RunAs -Wait
        Write-Host "  Unattended mode configured." -ForegroundColor Green
    } else {
        Write-Host "  Unattended mode skipped (Standard mode retained)." -ForegroundColor Gray
    }
} else {
    $installedVer = (& $tsCli version 2>&1 | Out-String).Trim()
    Write-Host "  Notice: 'tailscale set --unattended' is not supported on this installed Tailscale version ($installedVer)." -ForegroundColor Yellow
    Write-Host "  Continuing without automatically enabling unattended mode." -ForegroundColor Gray
}

# 5. Tailscale Machine Share Guidance
Write-Host "`n[5/7] Machine Share Guidance (Restricted Access)..." -ForegroundColor Yellow
Write-Host "  To grant your friend access ONLY to this Palworld server (NOT your entire tailnet):" -ForegroundColor Cyan
Write-Host "  1. Visit the Tailscale Admin Console: https://login.tailscale.com/admin/machines" -ForegroundColor Gray
Write-Host "  2. Locate this machine ('$hostName')." -ForegroundColor Gray
Write-Host "  3. Click '...' -> 'Share...'." -ForegroundColor Gray
Write-Host "  4. Generate a single-use machine-share invitation URL." -ForegroundColor Gray
Write-Host "  5. Enter this URL into Build\Configure-Connection.ps1." -ForegroundColor Gray
Write-Host "  * Note: Send the invitation only to your intended friend." -ForegroundColor Gray
Write-Host "  * Unused single-use invitations expire if not accepted." -ForegroundColor Gray

# 6. Verify Palworld Dedicated Server Status
Write-Host "`n[6/7] Verifying Palworld Server..." -ForegroundColor Yellow
$serverExe = Join-Path $ServerDir "PalServer.exe"
if (Test-Path $serverExe) {
    Write-Host "  PalServer.exe verified: $serverExe" -ForegroundColor Green
} else {
    Write-Host "  WARNING: PalServer.exe not found at $serverExe" -ForegroundColor Yellow
}

$palSettings = Join-Path $ServerDir "Pal\Saved\Config\WindowsServer\PalWorldSettings.ini"
if (Test-Path $palSettings) {
    Write-Host "  PalWorldSettings.ini verified: $palSettings" -ForegroundColor Green
}

# 7. Update connection.json with actual host details
Write-Host "`n[7/7] Updating Configuration for Connection Setup..." -ForegroundColor Yellow
if (Test-Path $ConfigPath) {
    try {
        $cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        $cfg.serverDeviceName = $hostName
        if ($dnsName) { $cfg.serverMagicDnsName = $dnsName.TrimEnd('.') }
        if ($hostIp) { $cfg.serverTailscaleIp = $hostIp }
        $json = $cfg | ConvertTo-Json -Depth 5
        Set-Content -Path $ConfigPath -Value $json -Encoding UTF8
        Write-Host "  Updated connection.json with device: $hostName, IP: $hostIp" -ForegroundColor Green
    } catch {
        Write-Host "  Error updating connection.json: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  HOST SETUP SUMMARY" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  Server Device Name : $hostName"
Write-Host "  Host Tailscale IP  : $hostIp"
Write-Host "  Game Port          : 8211 (UDP)"
Write-Host "  Direct Connect String: ${hostIp}:8211"
Write-Host "  Access Model       : Tailscale Machine Share (Node-level restricted)"
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "You can now run Build\Configure-Connection.ps1 and Build\Build-Release.ps1." -ForegroundColor Green
