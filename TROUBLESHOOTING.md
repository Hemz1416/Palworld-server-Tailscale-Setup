# 🔍 Troubleshooting & Diagnostic Guide

This guide covers troubleshooting connectivity and game server discovery over Tailscale for both the **Host (Hemz)** and **Connecting Friends**.

---

## 🛠️ Step-by-Step Diagnostic Checklist

| # | Check Item | How to Verify | Solution |
| :--- | :--- | :--- | :--- |
| **1** | **Tailscale Installed & Running** | Check Windows system tray for Tailscale icon | Run `Host-Dashboard.bat` (Host) or `Friend-Quick-Join.bat` (Friend) to start the service. |
| **2** | **Tailscale Login / Authentication** | Run `tailscale status` | Sign in with your Google/Microsoft account in your browser. |
| **3** | **Machine Share Accepted** | Look for Host in `tailscale status` | Friend must click and accept the single-use Machine Share link sent by Hemz. |
| **4** | **Tailscale Ping Check** | Run `tailscale ping 100.97.56.52` | If ping replies, Tailscale WireGuard mesh is 100% active and healthy! |
| **5** | **Game Server Port Listening** | Run `Host-Dashboard.bat` or PowerShell | Ensure game server is launched and listening on the designated port (TCP or UDP). |
| **6** | **Windows Defender Firewall** | Run `Setup-Firewall-Rule.bat` | Windows Firewall can block game ports even when ping succeeds. Run firewall helper. |
| **7** | **Host PC Sleep / Hibernate** | Check Windows power settings | Ensure the host PC does not sleep or shut down while hosting. |

---

## 🚨 Common Scenarios & Solutions

### 1. "Friend cannot see host machine in Tailscale"
* **Cause**: Friend has not accepted the Machine Share invitation, or the invitation expired.
* **Fix**:
  1. Open [Tailscale Admin Machines](https://login.tailscale.com/admin/machines).
  2. Locate your machine (e.g. `hemz`) -> click `...` -> **Share...**.
  3. Generate a new link and send it to your friend.
  4. Friend opens the link in their browser and clicks **Accept**.

### 2. "Tailscale ping succeeds, but friend cannot join the game server"
* **Key Distinction**: `tailscale ping` only verifies that your computer is awake and reachable over the Tailscale WireGuard mesh. It does **not** prove that the game server is listening or unblocked in Windows Firewall.
* **Fix**:
  1. **Check if server is running**: In `Host-Dashboard.bat`, verify if the port status displays `[ACTIVE (Listening)]`.
  2. **Unblock Windows Firewall**: Run [`Setup-Firewall-Rule.bat`](file:///Setup-Firewall-Rule.bat) as Administrator and choose your game to open its port on Windows Defender Firewall.
  3. **Verify Port & Protocol**:
     - Minecraft Java uses **TCP 25565**.
     - Palworld uses **UDP 8211**.
     - Minecraft Bedrock uses **UDP 19132**.
     - Valheim uses **UDP 2456-2458**.
     - Terraria uses **TCP 7777**.

### 3. Connection Path: "RELAYED / DERP"
* **What it means**: Direct peer-to-peer UDP hole punching was not possible between the two home routers (common with cellular hotspot internet, CGNAT, or strict symmetric NATs). Tailscale is routing traffic through its encrypted DERP relay.
* **Is this broken?**: **No.** DERP relaying is an intentional fallback that ensures you can still play together even when direct connection is blocked by ISPs.
* **How to improve**:
  - Connect via Ethernet cable instead of Wi-Fi where possible.
  - Enable UPnP on your home Wi-Fi router if available.

### 4. Tailscale Windows Service is Stopped
* **Symptom**: `failed to connect to local tailscaled process; is the Tailscale service running?`
* **Fix**:
  - Run `Host-Dashboard.bat` — it automatically checks `sc query Tailscale` and starts `net start Tailscale` with UAC elevation.
  - Or in PowerShell as Administrator:
    ```powershell
    Start-Service -Name Tailscale
    Set-Service -Name Tailscale -StartupType Automatic
    ```
