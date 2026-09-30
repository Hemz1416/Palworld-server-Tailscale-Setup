# Hemz Palworld Connection Setup

A dedicated, self-contained Windows application built in C# (.NET 10 / WPF) that automates the client-side networking setup for the private **Hemz Palworld Dedicated Server** using Tailscale's machine sharing mechanism and the official Valve game ecosystem.

---

## 🎮 Quick Download for Players (Friends)

To connect to the Hemz Palworld Dedicated Server:

1. **Download the Connection App**:
   * Direct EXE: [**`Release/Hemz-Palworld-Connection-Setup.exe`**](https://github.com/Hemz1416/Palworld-server-Tailscale-Setup/raw/main/Release/Hemz-Palworld-Connection-Setup.exe) (Single-file executable)
   * Or ZIP Package: [**`Release/Hemz-Palworld-Connection-Setup.zip`**](https://github.com/Hemz1416/Palworld-server-Tailscale-Setup/raw/main/Release/Hemz-Palworld-Connection-Setup.zip) (Includes player guide)
2. **Double-Click to Run**:
   * No technical setup or port forwarding required.
   * If Tailscale is not installed on your PC, the app prompts to download and install official Tailscale automatically.
3. **Accept the Machine Share in Your Browser**:
   * Log in with your personal Google, Microsoft, Apple, or GitHub account.
   * This connects you privately to the Palworld server machine.
4. **Connect & Play**:
   * Click **[ CONNECT TO PALWORLD ]** to copy the server address and launch the game!

---

## 🔒 Tailscale Machine Share Model

Rather than inviting a friend into your entire personal tailnet, this project uses Tailscale's **Share Machine** mechanism:

```text
Host MSI Palworld Server
         ↓
Tailscale Machine Share (Node-Level Isolation)
         ↓
Friend's Personal Tailscale Account
         ↓
Friend accesses ONLY the shared Palworld server machine
```

* **Restricted Access**: The friend receives private network access strictly to the shared Palworld server machine (`hemz`), never to unrelated computers, NAS drives, or devices on your personal tailnet.
* **Single-Use Invitations**: Share invitations are single-use and sensitive. They are configured only on the host side prior to packaging, never logged, and never exposed in runtime diagnostics. Unused invitations expire. Once accepted, standard Tailscale node-to-node authentication is established.

---

## 🎯 The One-EXE Experience

Send your friend the single file from the `Release\` folder:
```text
Release\Hemz-Palworld-Connection-Setup.exe
```

When your friend double-clicks this executable:
1. **Checks Windows Compatibility**: Verifies 64-bit Windows environment.
2. **Automates Tailscale Installation**: If Tailscale is not present, downloads the official Windows installer and installs it with UAC elevation.
3. **Verifies Windows Service**: Ensures the `Tailscale` Windows service is active and running (`C:\Program Files\Tailscale\tailscale.exe`).
4. **Opens Machine-Share Invitation**: Opens the single-use machine-share invitation URL in the default web browser.
5. **Awaits Authentication**: Automatically detects when the friend signs in and accepts the shared node.
6. **Discovers Shared Server**: Robust 5-stage discovery locates the shared Palworld machine via MagicDNS, peer table sharee nodes, device matching, or configured fallback IP.
7. **Probes Reachability & Path**: Runs `tailscale ping` to evaluate visibility, latency, and connection path (`DIRECT`, `RELAYED / DERP`, or `PEER RELAY`). Note: DERP relays are a normal fallback path for symmetric NATs, not an error.
8. **Clarifies UDP 8211**: Accurately distinguishes Tailscale machine connectivity from Palworld gameplay port 8211 (reporting that UDP application-level reachability is tested upon game connection).
9. **Launches Palworld**: Clicking **[ CONNECT TO PALWORLD ]** copies the server address (`100.x.x.x:8211`) to the Windows clipboard and launches Palworld (if safely detected).
10. **Safe Password Copying**: If the server has a password configured, a dedicated **[ COPY SERVER PASSWORD ]** button allows copying the password without silently overwriting the clipboard.

---

## 📂 Project Directory Structure

```text
Connection Setup/
├── App/                            # C# WPF Application Source
│   ├── Models/                     # Data, status, and diagnostic models
│   ├── Services/                   # Tailscale, Network probe, Palworld detector, Logger
│   ├── Views/                      # Diagnostics and Connection instructions dialogs
│   ├── App.xaml / App.xaml.cs      # CLI diagnostics & application entry point
│   ├── MainWindow.xaml / .cs       # Dark-themed gaming UI with machine share support
│   └── HemzPalworldConnectionSetup.csproj
│
├── Build/                          # Build and Configuration Tools
│   ├── Build-Release.ps1           # Self-contained single-file win-x64 build script
│   └── Configure-Connection.ps1    # Interactive prompt for machine share & server settings
│
├── Release/                        # Ready-to-Distribute Friend Package
│   ├── Hemz-Palworld-Connection-Setup.exe  (Self-contained single-file binary)
│   ├── README-FOR-FRIEND.txt       # Clear 3-step instructions for player
│   └── Config/connection.json      # Optional external override
│
├── Config/                         # Primary Host Configuration
│   └── connection.json             # Device names, ports, machine-share URLs, passwords
│
├── Tools/                          # Diagnostics & Testing
│   └── Test-Connection.ps1         # CLI-based diagnostic tool matching runtime rules
│
├── Logs/                           # Diagnostic Log Storage
│   └── connection.log              # Strictly sanitized runtime trace (no secrets/URLs)
│
├── Host-Setup.ps1                  # Setup script for your Server Host PC
├── README.md                       # This document
├── BUILD.md                        # Compilation and publishing guide
├── SECURITY.md                     # Security & authentication architecture
└── TROUBLESHOOTING.md              # Automated diagnostic audit & troubleshooting guide
```

---

## 🚀 Quick Start for Server Owner (Hemz)

### Step 1: Run Host Setup on Your Server Laptop
Run the dedicated host setup script in PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File ".\Host-Setup.ps1"
```
This script will:
- Verify Tailscale on your host machine.
- Verify the `Tailscale` Windows service status.
- Authenticate your host laptop to Tailscale.
- Check version support before offering optional **Unattended Mode** (never enabled on friend PC).
- Provide guidance on generating a single-use **Machine Share** link in the Tailscale Admin Console.
- Verify dedicated server files and update `Config\connection.json`.

### Step 2: Configure & Generate the Friend Release
1. Open the interactive configuration builder:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\Build\Configure-Connection.ps1"
   ```
2. Enter your Tailscale Machine Share invitation URL (from [Tailscale Admin Console](https://login.tailscale.com/admin/machines) -> click machine `hemz` -> `Share...`).
3. Choose whether to embed the server password (`qSWqLRG4dLJd4QMk`).
   > **Security Notice**: Anyone possessing the compiled executable may potentially recover an embedded password. You may choose to omit the password from the package and send it separately.
4. The script will automatically trigger `Build\Build-Release.ps1` and output your finalized single-file executable into `Release\`.

### Step 3: Send to Your Friend
Send `Release\Hemz-Palworld-Connection-Setup.exe` and `Release\README-FOR-FRIEND.txt` to your friend (via Discord, Google Drive, LocalSend, or USB).
