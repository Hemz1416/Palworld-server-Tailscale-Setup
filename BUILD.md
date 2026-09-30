# Build and Compilation Guide

This document describes how to build, test, and publish **Hemz Palworld Connection Setup**.

---

## Prerequisites

1. **Operating System**: Windows 10 / Windows 11 (64-bit)
2. **.NET SDK**: .NET 10.0 SDK (or .NET 8.0 SDK) with Windows Desktop workload:
   ```cmd
   dotnet --info
   ```

---

## One-Click Build

To build a fresh release package, execute the PowerShell build script:

```powershell
powershell -ExecutionPolicy Bypass -File "H:\Games\Pirated\Palworld server\Connection Setup\Build\Build-Release.ps1"
```

### What `Build-Release.ps1` Does:
1. **Cleans Staging Directory**: Empties temporary staging folders in `%TEMP%`.
2. **Compiles Self-Contained Win-x64**:
   ```cmd
   dotnet publish App\HemzPalworldConnectionSetup.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
   ```
3. **Embeds Fallback Configuration**: Embeds `Config\connection.json` directly into the assembly resources so the EXE functions as a standalone zero-dependency binary.
4. **Outputs Single Executable**: Copies the final executable to:
   ```text
   Release\Hemz-Palworld-Connection-Setup.exe
   ```
5. **Generates Friend Documentation**: Automatically writes `Release\README-FOR-FRIEND.txt` with machine-share connection instructions.

---

## Command-Line Diagnostics & Verification

The published executable supports command-line execution for non-interactive automated validation:

```powershell
# Run automated CLI diagnostic verification
& ".\Release\Hemz-Palworld-Connection-Setup.exe" --diagnostics
```

The output tests:
- Windows OS version & 64-bit architecture
- Tailscale CLI and Windows service (`Tailscale`) status
- Tailscale daemon authentication
- Shared server machine discovery
- Server reachability and connection path classification (DIRECT / RELAYED / PEER RELAY)
- Palworld game client detection

All output is logged directly to:
```text
Release\Logs\connection.log
```
(Strictly sanitized: no passwords, tokens, or invitation URLs are ever logged).

---

## Password Security Notice

When configuring the build in `Config\connection.json`:
* Anyone possessing the compiled executable may potentially recover an embedded password.
* If preferred, leave `palworldServerPassword` blank in `connection.json` and share the password directly with your friend out-of-band.
