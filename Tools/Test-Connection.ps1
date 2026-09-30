# Test-Connection.ps1
# Comprehensive diagnostic script verifying Tailscale, server discovery, ping, and configuration
[CmdletBinding()]
param()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }
$RootDir = Split-Path -Parent $ScriptDir
$ConfigPath = Join-Path $RootDir "Config\connection.json"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         PALWORLD CONNECTION TEST & DIAGNOSTICS SUITE" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Configuration Check
Write-Host "[1/7] Validating Configuration..." -ForegroundColor Yellow
if (-not (Test-Path $ConfigPath)) {
    Write-Host "  FAIL: Config not found at $ConfigPath" -ForegroundColor Red
    exit 1
}
$cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json
Write-Host "  App Name       : $($cfg.appName)" -ForegroundColor Green
Write-Host "  Server Name    : $($cfg.serverName)" -ForegroundColor Green
Write-Host "  Server Device  : $($cfg.serverDeviceName)" -ForegroundColor Green
Write-Host "  Server Port    : $($cfg.serverPort)" -ForegroundColor Green
Write-Host "  MagicDNS Name  : $(if($cfg.serverMagicDnsName){$cfg.serverMagicDnsName}else{'(None)'})" -ForegroundColor Gray

# 2. Tailscale Installation & Windows Service Check
Write-Host "`n[2/7] Checking Tailscale Installation & Service..." -ForegroundColor Yellow
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

if ($tsCli) {
    Write-Host "  Tailscale CLI Found: $tsCli" -ForegroundColor Green
    $ver = & $tsCli version
    Write-Host "  Version: $ver" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Tailscale CLI is NOT installed on this machine." -ForegroundColor Red
}

# Check Windows Service "Tailscale"
$svc = Get-Service -Name "Tailscale" -ErrorAction SilentlyContinue
if ($svc) {
    Write-Host "  Tailscale Windows Service: $($svc.Status)" -ForegroundColor (if($svc.Status -eq 'Running'){"Green"}else{"Yellow"})
} else {
    Write-Host "  Tailscale Windows Service: NOT REGISTERED" -ForegroundColor Yellow
}

# 3. Tailscale Authentication & Status
Write-Host "`n[3/7] Checking Tailscale Authentication & Status..." -ForegroundColor Yellow
$serverIp = $null
if ($tsCli) {
    try {
        $statusJson = & $tsCli status --json | ConvertFrom-Json
        $self = $statusJson.Self
        $online = $self.Online -or ($statusJson.BackendState -eq "Running")
        Write-Host "  Backend State : $($statusJson.BackendState)" -ForegroundColor (if($online){"Green"}else{"Red"})
        Write-Host "  Authenticated : $online" -ForegroundColor (if($online){"Green"}else{"Red"})
        Write-Host "  Node Hostname : $($self.HostName)" -ForegroundColor Green
        Write-Host "  Node IP       : $($self.TailscaleIPs -join ', ')" -ForegroundColor Green

        # 4. Shared Server Machine Discovery
        Write-Host "`n[4/7] Discovering Shared Server Machine in Tailscale..." -ForegroundColor Yellow
        $target = $cfg.serverDeviceName
        $peers = @()
        if ($statusJson.Peer) {
            $peers = $statusJson.Peer.PSObject.Properties | ForEach-Object { $_.Value }
        }

        # 1. Exact match / ShareeNode match
        $match = $peers | Where-Object { 
            ($_.HostName -eq $target) -or ($_.DNSName -like "$target.*") -or ($_.ShareeNode -eq $true -and ($_.HostName -like "*$target*"))
        } | Select-Object -First 1

        # 2. Substring match
        if (-not $match) {
            $match = $peers | Where-Object { 
                ($_.HostName -like "*$target*") -or ($_.DNSName -like "*$target*")
            } | Select-Object -First 1
        }

        if ($match) {
            $serverIp = ($match.TailscaleIPs | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+' })[0]
            Write-Host "  Discovered Device : $($match.HostName)" -ForegroundColor Green
            Write-Host "  Device Tailscale IP: $serverIp" -ForegroundColor Green
            Write-Host "  Online Status     : $($match.Online)" -ForegroundColor (if($match.Online){"Green"}else{"Yellow"})
            Write-Host "  Shared Node       : $(if($match.ShareeNode){'Yes (Machine Share)'}else{'Direct Tailnet Node'})" -ForegroundColor Cyan
        } elseif (-not [string]::IsNullOrWhiteSpace($cfg.serverTailscaleIp)) {
            $serverIp = $cfg.serverTailscaleIp
            Write-Host "  Using configured fallback server IP: $serverIp" -ForegroundColor Yellow
        } else {
            Write-Host "  WARNING: Shared server machine '$target' not found in peer table." -ForegroundColor Yellow
            Write-Host "  (Ensure host laptop has accepted/created machine share, and friend accepted invite)." -ForegroundColor Gray
        }

        # 5. Tailscale Ping & Connection Path Test
        Write-Host "`n[5/7] Testing Tailscale Reachability & Connection Path..." -ForegroundColor Yellow
        if ($serverIp) {
            $pingOut = & $tsCli ping -c 2 $serverIp 2>&1 | Out-String
            Write-Host "  Ping Output: $($pingOut.Trim())" -ForegroundColor Gray
            if ($pingOut -match "via DERP\((.+?)\)") {
                Write-Host "  Connection Path: RELAYED / DERP ($($Matches[1]))" -ForegroundColor Yellow
                Write-Host "  (Note: Relay connections provide seamless connectivity without port forwarding)." -ForegroundColor Gray
            } elseif ($pingOut -match "peer relay") {
                Write-Host "  Connection Path: PEER RELAY" -ForegroundColor Yellow
            } elseif ($pingOut -match "via \d+\.\d+\.\d+\.\d+") {
                Write-Host "  Connection Path: DIRECT (Peer-to-Peer)" -ForegroundColor Green
            } else {
                Write-Host "  Connection Path: UNKNOWN / EVALUATING" -ForegroundColor Yellow
            }
            Write-Host "  Note: Tailscale ping establishes network visibility and path. It does NOT verify Palworld UDP 8211." -ForegroundColor DarkCyan
        } else {
            Write-Host "  Skipping ping test (No server IP discovered)." -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Tailscale status query returned error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  Skipping Tailscale network probe (CLI not present)." -ForegroundColor Gray
}

# 6. Separate Palworld UDP 8211 Verification
Write-Host "`n[6/7] Evaluating Palworld Game Port 8211..." -ForegroundColor Yellow
$palProcs = Get-Process | Where-Object { $_.ProcessName -match "PalServer" }
if ($palProcs) {
    Write-Host "  PalServer.exe is running LOCALLY on this host (Processes: $($palProcs.Count))." -ForegroundColor Green
} else {
    Write-Host "  Palworld UDP endpoint cannot be directly verified from this diagnostic mode." -ForegroundColor Cyan
    Write-Host "  (Game connectivity is tested when Palworld connects to the server)." -ForegroundColor Gray
}

# 7. Palworld Client Detection
Write-Host "`n[7/7] Palworld Client Check..." -ForegroundColor Yellow
$palClient = "H:\Games\Pirated\Palworld\Palworld.exe"
if (Test-Path $palClient) {
    Write-Host "  Palworld Client executable detected: $palClient" -ForegroundColor Green
} else {
    Write-Host "  Palworld Client not at standard test path (friend may install game anywhere)." -ForegroundColor Gray
}

Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "Diagnostics Complete." -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
