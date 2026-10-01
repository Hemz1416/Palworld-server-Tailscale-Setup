# Build-Release.ps1
# Automates the clean compilation and packaging of Tailscale Connection Setup
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }
$RootDir = Split-Path -Parent $ScriptDir

$AppProj = Join-Path $RootDir "App\HemzPalworldConnectionSetup.csproj"
$ReleaseDir = Join-Path $RootDir "Release"
$StagingDir = Join-Path $env:TEMP "tailscale_build_staging"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     BUILDING RELEASE: Tailscale & Game Connection Setup" -ForegroundColor Cyan
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

# Generate both binary names for full compatibility
$destExePalworld = Join-Path $ReleaseDir "Hemz-Palworld-Connection-Setup.exe"
$destExeUniversal = Join-Path $ReleaseDir "Tailscale-Connection-Setup.exe"

Copy-Item -Path $builtExe -Destination $destExeUniversal -Force
Copy-Item -Path $builtExe -Destination $destExePalworld -Force
Write-Host "Generated: $destExeUniversal ($([math]::Round((Get-Item $destExeUniversal).Length / 1MB, 2)) MB)" -ForegroundColor Green

# 4. Copy Friend-Quick-Join.bat & configuration template to Release
$friendBatSource = Join-Path $RootDir "Friend-Quick-Join.bat"
if (Test-Path $friendBatSource) {
    Copy-Item -Path $friendBatSource -Destination (Join-Path $ReleaseDir "Friend-Quick-Join.bat") -Force
}

$releaseConfigDir = Join-Path $ReleaseDir "Config"
New-Item -ItemType Directory -Path $releaseConfigDir -Force | Out-Null
Copy-Item -Path (Join-Path $RootDir "Config\connection.json") -Destination (Join-Path $releaseConfigDir "connection.json") -Force
Copy-Item -Path (Join-Path $RootDir "Config\games-presets.json") -Destination (Join-Path $releaseConfigDir "games-presets.json") -Force

# 5. Copy README-FOR-FRIEND.txt and FRIEND-GUIDE.md
Write-Host "[4/5] Updating friend distribution guides..." -ForegroundColor Yellow
$friendGuideSource = Join-Path $RootDir "FRIEND-GUIDE.md"
if (Test-Path $friendGuideSource) {
    Copy-Item -Path $friendGuideSource -Destination (Join-Path $ReleaseDir "FRIEND-GUIDE.md") -Force
}

# 6. Create ZIP packages for distribution
$zipFileUniversal = Join-Path $ReleaseDir "Tailscale-Connection-Setup.zip"
$zipFilePalworld = Join-Path $ReleaseDir "Hemz-Palworld-Connection-Setup.zip"

if (Test-Path $zipFileUniversal) { Remove-Item -Path $zipFileUniversal -Force }
if (Test-Path $zipFilePalworld) { Remove-Item -Path $zipFilePalworld -Force }

$itemsToZip = @(
    $destExeUniversal,
    (Join-Path $ReleaseDir "Friend-Quick-Join.bat"),
    (Join-Path $ReleaseDir "README-FOR-FRIEND.txt")
)

Compress-Archive -Path $itemsToZip -DestinationPath $zipFileUniversal -Force
Copy-Item -Path $zipFileUniversal -Destination $zipFilePalworld -Force

Write-Host "Generated ZIP: $zipFileUniversal ($([math]::Round((Get-Item $zipFileUniversal).Length / 1MB, 2)) MB)" -ForegroundColor Green

# 7. Clean up temporary staging directory in TEMP
Write-Host "[5/5] Cleaning temporary staging files..." -ForegroundColor Yellow
Remove-Item -Path $StagingDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "======================================================================" -ForegroundColor Green
Write-Host "  SUCCESS! All Release packages ready in: $ReleaseDir" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
