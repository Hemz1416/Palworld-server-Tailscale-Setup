# Build-Release.ps1
# Automates the clean compilation and packaging of Hemz Palworld Connection Setup
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }
$RootDir = Split-Path -Parent $ScriptDir

$AppProj = Join-Path $RootDir "App\HemzPalworldConnectionSetup.csproj"
$ReleaseDir = Join-Path $RootDir "Release"
$StagingDir = Join-Path $env:TEMP "palworld_build_staging"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     BUILDING RELEASE: Hemz-Palworld-Connection-Setup.exe" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Clean previous build staging
Write-Host "[1/5] Cleaning old staging artifacts..." -ForegroundColor Yellow
if (Test-Path $StagingDir) {
    Remove-Item -Path $StagingDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $StagingDir -Force | Out-Null
New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null

# 2. Restore and Build Self-Contained Win-x64 Single File
Write-Host "[2/5] Compiling and publishing self-contained win-x64 single-file executable..." -ForegroundColor Yellow
$publishArgs = @(
    "publish",
    $AppProj,
    "-c", "Release",
    "-r", "win-x64",
    "--self-contained", "true",
    "-p:PublishSingleFile=true",
    "-p:IncludeNativeLibrariesForSelfExtract=true",
    "-p:EnableCompressionInSingleFile=true",
    "-o", $StagingDir
)

& dotnet @publishArgs
if ($LASTEXITCODE -ne 0) {
    Write-Error "dotnet publish failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

# 3. Locate published executable and copy to Release
Write-Host "[3/5] Moving binary to Release directory..." -ForegroundColor Yellow
$builtExe = Join-Path $StagingDir "Hemz-Palworld-Connection-Setup.exe"
if (-not (Test-Path $builtExe)) {
    $alt = Get-ChildItem -Path $StagingDir -Filter "*.exe" | Select-Object -First 1
    if ($alt) {
        $builtExe = $alt.FullName
    } else {
        Write-Error "Could not locate compiled .exe in $StagingDir."
        exit 1
    }
}

$destExe = Join-Path $ReleaseDir "Hemz-Palworld-Connection-Setup.exe"
Copy-Item -Path $builtExe -Destination $destExe -Force
Write-Host "Generated: $destExe ($([math]::Round((Get-Item $destExe).Length / 1MB, 2)) MB)" -ForegroundColor Green

# 4. Copy configuration template for friend distribution if external override desired
$releaseConfigDir = Join-Path $ReleaseDir "Config"
New-Item -ItemType Directory -Path $releaseConfigDir -Force | Out-Null
Copy-Item -Path (Join-Path $RootDir "Config\connection.json") -Destination (Join-Path $releaseConfigDir "connection.json") -Force

# 5. Generate README-FOR-FRIEND.txt
Write-Host "[4/5] Generating Release\README-FOR-FRIEND.txt..." -ForegroundColor Yellow
$readmeFriend = @"
================================================================================
                    HEMZ PALWORLD DEDICATED SERVER
                        PLAYER CONNECTION GUIDE
================================================================================

Welcome! This package allows you to connect securely to the shared Hemz Palworld
server machine through Tailscale.

--------------------------------------------------------------------------------
HOW TO CONNECT (SIMPLE 3-STEP GUIDE)
--------------------------------------------------------------------------------

STEP 1: Run the Connection App
  - Double-click: Hemz-Palworld-Connection-Setup.exe
  - If Tailscale is not installed on your PC, the app will ask to download and
    install official Tailscale automatically. Click YES when Windows asks for
    permission.

STEP 2: Sign in to Tailscale & Accept Machine Share
  - A browser window will open with the Tailscale machine-share invitation.
  - Sign in with your personal Google, Microsoft, Apple, or GitHub account and
    accept the invitation to access the shared Palworld server machine.
    (Note: This grants you private access only to the Palworld server machine,
    not any other devices or the host's entire tailnet).
  - Return to Hemz-Palworld-Connection-Setup.exe.
  - The status will turn GREEN ("Host PC: Reachable") automatically.

STEP 3: Launch Palworld and Play
  - Click the green button: [ CONNECT TO PALWORLD ]
  - This automatically copies the server address (e.g., 100.x.x.x:8211) to your
    Windows clipboard and launches Palworld (if safely detected).
  - If the server has a password, click [ COPY SERVER PASSWORD ] in the app
    to copy it when needed (it will not overwrite your clipboard silently).
  - In the Palworld main menu, click:
      "Join Multiplayer Game"
  - In the direct IP connection box at the bottom, paste (Ctrl+V):
      The server address (e.g., 100.x.x.x:8211)
  - If prompted for a password, paste the server password.
  - Click "Connect" and enjoy!

--------------------------------------------------------------------------------
NEED HELP?
--------------------------------------------------------------------------------
- Click the [ TROUBLESHOOT ] button inside the app to run an automated diagnostic
  check verifying Tailscale, the Tailscale Windows service, shared server
  discovery, and ping latency.
- Or click [ OPEN LOG ] to view the local diagnostic log.
================================================================================
"@

Set-Content -Path (Join-Path $ReleaseDir "README-FOR-FRIEND.txt") -Value $readmeFriend -Encoding UTF8

# 6. Create ZIP package for simple one-click GitHub distribution
$zipFile = Join-Path $ReleaseDir "Hemz-Palworld-Connection-Setup.zip"
if (Test-Path $zipFile) { Remove-Item -Path $zipFile -Force }
Compress-Archive -Path $destExe, (Join-Path $ReleaseDir "README-FOR-FRIEND.txt") -DestinationPath $zipFile -Force
Write-Host "Generated ZIP: $zipFile ($([math]::Round((Get-Item $zipFile).Length / 1MB, 2)) MB)" -ForegroundColor Green

# 7. Clean up temporary staging directory in TEMP
Write-Host "[5/5] Cleaning temporary staging files..." -ForegroundColor Yellow
Remove-Item -Path $StagingDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "======================================================================" -ForegroundColor Green
Write-Host "  SUCCESS! Release ready in: $ReleaseDir" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
