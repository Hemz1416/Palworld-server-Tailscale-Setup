# Host-Setup.ps1
# Tailscale Host Environment Preparation & Diagnostics for Game Server Hosting
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         TAILSCALE HOST SETUP & PRE-FLIGHT DIAGNOSTICS" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "This script configures and verifies your Windows host PC for hosting" -ForegroundColor Gray
Write-Host "game servers (Minecraft, Palworld, Valheim, etc.) over Tailscale." -ForegroundColor Gray
Write-Host ""

# 1. Check Administrator Elevation
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] Note: Running without Administrator privileges." -ForegroundColor Yellow
    Write-Host "    Some actions (like setting service to Automatic or modifying firewall) require elevation." -ForegroundColor DarkGray
    Write-Host ""
}

# 2. Check Tailscale Installation
$tsExe = "C:\Program Files\Tailscale\tailscale.exe"
$tsFound = $false
if (Get-Command tailscale.exe -ErrorAction SilentlyContinue) {
    $tsFound = $true
    $tsCmd = "tailscale.exe"
} elseif (Test-Path $tsExe) {
    $tsFound = $true
    $tsCmd = $tsExe
}

if (-not $tsFound) {
    Write-Host "[-] Tailscale is not installed on this PC." -ForegroundColor Red
    Write-Host "    Please download and install Tailscale from: https://tailscale.com/download" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "[OK] Tailscale CLI detected at: $tsCmd" -ForegroundColor Green
}

# 3. Check Windows Background Service
$svc = Get-Service -Name "Tailscale" -ErrorAction SilentlyContinue
if ($null -eq $svc) {
    Write-Host "[-] Tailscale Windows service not registered." -ForegroundColor Red
} else {
    Write-Host "[OK] Tailscale Service Status: $($svc.Status) (StartupType: $($svc.StartType))" -ForegroundColor Green
    if ($svc.Status -ne "Running") {
        Write-Host "    Starting Tailscale service..." -ForegroundColor Yellow
        try {
            Start-Service -Name "Tailscale" -ErrorAction Stop
            Write-Host "    [OK] Tailscale service started successfully." -ForegroundColor Green
        } catch {
            Write-Host "    [!] Could not start service directly: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "    Run PowerShell as Administrator or launch Host-Dashboard.bat." -ForegroundColor DarkGray
        }
    }
    
    if ($svc.StartType -ne "Automatic" -and $isAdmin) {
        $setOpt = Read-Host "Would you like to set Tailscale service to start automatically on Windows boot? (Y/N) [Y]"
        if ($setOpt -notmatch "N|no") {
            try {
                Set-Service -Name "Tailscale" -StartupType Automatic
                Write-Host "[OK] Tailscale service startup set to Automatic." -ForegroundColor Green
            } catch {
                Write-Host "[!] Failed to set startup type: $($_.Exception.Message)" -ForegroundColor DarkGray
            }
        }
    }
}

# 4. Check Tailscale Connection & Host IP
Write-Host ""
Write-Host "[*] Querying Tailscale IP and node details..." -ForegroundColor Cyan
$tsIp = & $tsCmd ip -4 2>$null
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($tsIp)) {
    Write-Host "[OK] Your Host Tailscale IPv4: $tsIp" -ForegroundColor Green
} else {
    Write-Host "[!] Could not query Tailscale IP. Tailscale may be logged out." -ForegroundColor Yellow
    Write-Host "    Run 'tailscale up' or launch the Tailscale GUI to sign in." -ForegroundColor DarkGray
    $tsIp = "100.97.56.52"
}

# 5. Check Windows Defender Firewall Rules for Game Ports
Write-Host ""
Write-Host "[*] Auditing Windows Defender Firewall for game hosting..." -ForegroundColor Cyan
$mcRule = Get-NetFirewallRule -DisplayName "Tailscale - Minecraft Java*" -ErrorAction SilentlyContinue
$palRule = Get-NetFirewallRule -DisplayName "Tailscale - Palworld*" -ErrorAction SilentlyContinue

if ($mcRule) {
    Write-Host "[OK] Minecraft Java firewall rule active: $($mcRule.DisplayName)" -ForegroundColor Green
} else {
    Write-Host "[!] Minecraft Java firewall rule is missing." -ForegroundColor Yellow
}

if ($palRule) {
    Write-Host "[OK] Palworld Dedicated Server firewall rule active: $($palRule.DisplayName)" -ForegroundColor Green
} else {
    Write-Host "[!] Palworld Dedicated Server firewall rule is missing." -ForegroundColor Yellow
}

if ((-not $mcRule -or -not $palRule) -and $isAdmin) {
    $addFw = Read-Host "Would you like to automatically configure Windows Firewall for Palworld & Minecraft Java (restricted strictly to Tailscale 100.64.0.0/10)? (Y/N) [Y]"
    if ($addFw -notmatch "N|no") {
        if (-not $mcRule) {
            New-NetFirewallRule -DisplayName "Tailscale - Minecraft Java (25565 TCP)" -Direction Inbound -LocalPort 25565 -Protocol TCP -Action Allow -RemoteAddress "100.64.0.0/10" | Out-Null
            Write-Host "[OK] Added Minecraft Java rule (TCP 25565 restricted to Tailscale)." -ForegroundColor Green
        }
        if (-not $palRule) {
            New-NetFirewallRule -DisplayName "Tailscale - Palworld (8211 UDP)" -Direction Inbound -LocalPort 8211 -Protocol UDP -Action Allow -RemoteAddress "100.64.0.0/10" | Out-Null
            Write-Host "[OK] Added Palworld rule (UDP 8211 restricted to Tailscale)." -ForegroundColor Green
        }
    }
}

# 6. Tailscale Machine Share Guide
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                 HOW TO INVITE FRIENDS VIA TAILSCALE" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Tailscale provides two methods for friends to connect to your PC:" -ForegroundColor White
Write-Host ""
Write-Host "METHOD 1: Machine Share (RECOMMENDED - Most Secure & Isolated)" -ForegroundColor Green
Write-Host "  - Isolates friend's access ONLY to this server PC (never your other devices)." -ForegroundColor Gray
Write-Host "  - Friend does NOT need to join your full tailnet." -ForegroundColor Gray
Write-Host "  - How to create a link:" -ForegroundColor Yellow
Write-Host "    1. Open Tailscale Admin: https://login.tailscale.com/admin/machines" -ForegroundColor DarkCyan
Write-Host "    2. Find your PC node (e.g. 'hemz')" -ForegroundColor DarkCyan
Write-Host "    3. Click the three dots (...) on the right -> Click 'Share...'" -ForegroundColor DarkCyan
Write-Host "    4. Generate a Share Link and send it to your friend!" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "METHOD 2: Tailnet Invite (For trusted close friends)" -ForegroundColor Green
Write-Host "  - Send an invite to your Tailnet from: https://login.tailscale.com/admin/users" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                 READY TO HOST!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "To manage your servers and auto-copy friend addresses, run:" -ForegroundColor White
Write-Host "  -> Host-Dashboard.bat" -ForegroundColor Yellow
Write-Host ""
