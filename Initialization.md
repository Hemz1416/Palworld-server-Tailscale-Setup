# Hemz Palworld Server & Tailscale Initialization Guide

A complete, step-by-step operational manual for **Hemz** (Server Host) and **Friends** (Players) to start the dedicated server, establish private Tailscale machine sharing, and connect in Palworld.

---

## 📌 Architecture Quick Reference

```text
┌────────────────────────────────────────────────────────┐
│                   HEMZ (HOST LAPTOP)                   │
│  1. Run Palworld Dedicated Server (UDP 8211)           │
│  2. Tailscale Node active                              │
│  3. Machine Share Link generated for specific device   │
└───────────────────────────┬────────────────────────────┘
                            │  Encrypted WireGuard Mesh
                            │  (No Router Port Forwarding)
                            ▼
┌────────────────────────────────────────────────────────┐
│                    FRIEND (PLAYER)                     │
│  1. Downloads app from GitHub repository               │
│  2. Accepts single-use Machine Share link              │
│  3. App verifies private link to server                │
│  4. Connects in Palworld via 100.x.x.x:8211            │
└────────────────────────────────────────────────────────┘
```

> [!NOTE]
> **Isolated Access Policy**: Friends only receive access to the shared Palworld server machine (`hemz`), NOT to your home network or unrelated devices in your personal tailnet.

---

## 🚀 PHASE 1: Host Preparation (Hemz)

Complete these steps on your MSI host laptop before inviting friends.

### Step 1.1: Ensure Windows Does Not Sleep
Game servers require the host PC to stay active while hosting:
1. Press `Win + R`, type `powercfg.cpl`, and hit **Enter**.
2. On your current power plan, select **Change plan settings**.
3. Set **Put the computer to sleep** to **"Never"** (when plugged in).
4. Keep the laptop plugged into AC power.

### Step 1.2: One-Time Windows Firewall Setup
Ensure Windows permits incoming UDP game packets:
1. Open folder: `H:\Games\Pirated\Palworld server\`
2. Right-click **`Setup-Firewall.bat`** -> select **Run as administrator**.
3. Press any key to confirm firewall rules for port 8211 UDP.

### Step 1.3: Start & Validate Tailscale on Host
1. Open PowerShell and run the host setup script:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "H:\Games\Pirated\Palworld server\Connection Setup\Host-Setup.ps1"
   ```
2. The script will:
   - Confirm official Tailscale is installed on your laptop.
   - Ensure the Windows service named `"Tailscale"` is active and running.
   - Authenticate your host device.
   - Note your server device name (e.g., `hemz`) and your **Tailscale IPv4** (e.g., `100.x.x.x`).

### Step 1.4: Generate a Tailscale Machine Share Link
Rather than giving friends access to your whole account, create a machine-share invitation:
1. Open your browser and visit: **[https://login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines)**
2. Find your host laptop (`hemz` / MSI laptop) in the machine list.
3. Click the three dots `...` on the right side -> click **Share...**.
4. Click **Generate Share Link**.
5. Copy the generated single-use invitation URL (e.g. `https://login.tailscale.com/admin/invite/...`).

> [!IMPORTANT]
> **Single-Use Link**: Each share link can only be used by **one** friend. If inviting multiple friends, generate a separate share link for each friend from the same machine menu.

---

## 🎮 PHASE 2: Starting the Palworld Dedicated Server

### Starting the Server:
Choose any method from `H:\Games\Pirated\Palworld server\`:

* **Option 1 (One-Click Server & Tailscale Host Launcher - Recommended)**:
  * Double-click **`Start-Server-And-Tailscale.bat`** (or the **`Start Palworld Server & Tailscale`** shortcut on your Desktop).
  * Automatically verifies Tailscale is running, starts the dedicated server, copies your connect IP (`127.0.0.1:8211`) to your clipboard, and displays an interactive menu to copy passwords and friend IPs.
* **Option 2 (Standard Dedicated Server Console)**: Double-click **`Start-PalworldServer.bat`**
  * Launches `PalServer.exe` directly with multithreading performance optimizations (`-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS`).
* **Option 3 (With Crash Auto-Restart Supervisor)**: Double-click **`Run-PalworldServer.bat`**
  * Starts a monitoring supervisor that automatically restarts `PalServer.exe` if it crashes.
* **Option 4 (Full Interactive Server Menu)**: Double-click **`ServerMenu.bat`**
  * Full control panel for backups, configuration, and diagnostics.

### How to Verify the Server is Ready:
In the black console window that opens, you should see the engine initialize. When it stops outputting logs and remains open, the server is listening on UDP `8211`.

### Safe Server Shutdown (Prevent World Corruption):
> [!CAUTION]
> Never abruptly close the server console or kill it via Task Manager unless frozen.
* Double-click **`Stop-PalworldServer.bat`** or press `Ctrl + C` in the console window to allow the world database to flush safely to disk.

---

## 👥 PHASE 3: Helping Friends Connect (Player Guide)

Send your friend these simple steps:

### Step 3.1: Download the Connection App
Direct your friend to your GitHub repository:
* **Repository**: [https://github.com/Hemz1416/Palworld-server-Tailscale-Setup](https://github.com/Hemz1416/Palworld-server-Tailscale-Setup)
* Direct download options from the `Release` folder:
  * **[Hemz-Palworld-Connection-Setup.exe](https://github.com/Hemz1416/Palworld-server-Tailscale-Setup/raw/main/Release/Hemz-Palworld-Connection-Setup.exe)** (62 MB single file)
  * Or **[Hemz-Palworld-Connection-Setup.zip](https://github.com/Hemz1416/Palworld-server-Tailscale-Setup/raw/main/Release/Hemz-Palworld-Connection-Setup.zip)** (56 MB zip package)

### Step 3.2: Send the Machine Share Invitation
Send your friend the private Tailscale Share Link you generated in Step 1.4 via Discord/message.

### Step 3.3: Friend Runs the Connection App
1. The friend double-clicks **`Hemz-Palworld-Connection-Setup.exe`**.
2. **If Tailscale is not installed**:
   - The app asks to install Tailscale.
   - Friend clicks **YES** on the Windows UAC prompt.
3. **Accepting Machine Share**:
   - The app (or friend) opens the share link in their browser.
   - Friend logs in using their own Google, Microsoft, Apple, or GitHub account.
   - Friend clicks **Accept** on the Tailscale page to accept access to machine `hemz`.
4. **Automatic Detection**:
   - Returning to `Hemz-Palworld-Connection-Setup.exe`, the status indicator will turn **GREEN**:
   ```text
   HEMZ PALWORLD
   SERVER ONLINE
   Address: 100.x.x.x:8211
   Connection: DIRECT (or RELAYED)
   ```

---

## 🕹️ PHASE 4: Joining the Game in Palworld

### For Friends (Remote Players):
1. Inside `Hemz-Palworld-Connection-Setup.exe`, click **[ CONNECT TO PALWORLD ]**.
   - This copies the direct address (`100.x.x.x:8211`) to the Windows clipboard and launches Palworld.
2. If the server has a password, click **[ COPY SERVER PASSWORD ]** in the app.
3. In the Palworld main menu, click **Join Multiplayer Game**.
4. Scroll to the very bottom of the server browser.
5. In the input box at the bottom, press `Ctrl + V` to paste the address (e.g., `100.x.x.x:8211`).
6. Click **Connect**.
7. If prompted for a password, enter your server password (configured in `PalWorldSettings.ini`).
8. Click **Submit** to enter the world!

### For Hemz (Host Joining on Same Laptop):
Because you are hosting on the same machine, you can connect using either:
* **Tailscale Address**: Paste your Tailscale IP `100.x.x.x:8211`
* **Local Loopback**: Paste `127.0.0.1:8211`

---

## 🔧 PHASE 5: Troubleshooting & Quick Fixes

| Issue | Cause | Solution |
|---|---|---|
| **App shows "Server device not found in peer table"** | Friend hasn't accepted the machine share link, or link expired. | In Tailscale Admin Console, click `...` on machine `hemz` -> `Share...` -> generate a new single-use link and have the friend accept it. |
| **Status is "OFFLINE / TIMEOUT"** | Host laptop is asleep, disconnected from Wi-Fi, or Tailscale service stopped. | Ensure laptop is awake and plugged in. Check `Get-Service -Name Tailscale` on host. |
| **Connection Path shows "RELAYED / DERP"** | Residential routers cannot establish direct UDP hole punch. | **Normal behavior!** DERP relaying is a built-in fallback that enables full gameplay without opening router ports. |
| **App says "Tailscale Windows Service: Stopped"** | Windows service `Tailscale` is paused. | In Windows search, open `services.msc`, locate `Tailscale`, and click **Start**. |
| **Palworld says "Failed to Connect"** | `PalServer.exe` is not running on host laptop, or firewall is blocking. | Verify `PalServer.exe` is running on host. Run `Setup-Firewall.bat` as administrator. |

---

## 📋 Routine Daily Checklist

When starting a gaming session:
1. [ ] Plug in MSI host laptop and ensure sleep mode is disabled.
2. [ ] Verify Tailscale icon in Windows taskbar is active.
3. [ ] Run `Start-PalworldServer.bat` (wait for server console to initialize).
4. [ ] Have friends launch `Hemz-Palworld-Connection-Setup.exe`.
5. [ ] Friends click **[ CONNECT TO PALWORLD ]** and paste IP into the in-game direct connect box.
6. [ ] When finished, close server with `Stop-PalworldServer.bat` to save the game cleanly.
