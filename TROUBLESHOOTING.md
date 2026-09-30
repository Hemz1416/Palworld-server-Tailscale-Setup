# Troubleshooting & Diagnostic Guide

This guide covers the automated health audit engine and resolves connectivity scenarios between player clients and the shared **Hemz Palworld Dedicated Server**.

---

## 🔍 The Automated Health Audit

Clicking **[ TROUBLESHOOT ]** inside `Hemz-Palworld-Connection-Setup.exe` executes the following sequential checks:

| # | Check | Healthy State | Details & Resolution |
|---|---|---|---|
| **1** | **Tailscale Installed** | CLI found at `C:\Program Files\Tailscale\tailscale.exe` | If missing, the app prompts to download and install official Tailscale. |
| **2** | **Tailscale Windows Service** | Service `"Tailscale"` is `Running` | Queryable via `Get-Service -Name Tailscale`. Check `services.msc` if stopped. |
| **3** | **Tailscale Authentication** | Backend state: `Running` | Ensure the user has completed browser authentication. |
| **4** | **Shared Machine Access Policy** | Server node visible in peer table | Ensure the single-use machine-share invitation was accepted by the friend. |
| **5** | **Shared Server Machine Discovery** | Shared node resolved | 5-step discovery hierarchy (MagicDNS → Peer table → Substring match → Visible IPv4 → Configured Fallback IP). |
| **6** | **Tailscale Server Reachability** | ICMP / DERP replies received | Verifies device visibility and network latency. (*Note: Does not probe UDP 8211*). |
| **7** | **Palworld UDP 8211 Service Check** | Host configured on port 8211 | UDP application-level reachability cannot be directly verified from diagnostic mode. Verifies host configuration and game launch readiness. |
| **8** | **Palworld Dedicated Server Process** | `PalServer.exe` active on host | Ensure the server host has launched `PalServer.exe` (or `Start-PalworldServer.bat`). |
| **9** | **Host Machine Power State** | Host responding actively | Ensure the host laptop does not enter Windows Sleep or Hibernate while hosting. |
| **10** | **Firewall & Traffic Policy** | WireGuard traffic allowed | Ensure host Windows Firewall permits `PalServer.exe` / UDP port 8211. |
| **11** | **Connection Path Evaluation** | `DIRECT`, `RELAYED / DERP`, or `PEER RELAY` | DERP relays are not errors; they provide transparent fallback across restrictive NATs. Direct connections offer lowest latency. |
| **12** | **Palworld Client Installation** | `Palworld.exe` detected | Friend can click browse or launch the game manually from Steam/desktop. |

---

## 🛠️ Common Scenarios & Solutions

### 1. "Shared server machine not visible"
* **Mechanism**: Machine sharing grants access exclusively to the shared server node (`hemz`).
* **Causes**:
  1. The friend has not yet accepted the single-use machine-share link in their browser.
  2. The invitation link expired before acceptance.
  3. The machine share was revoked in the Tailscale Admin Console.
* **Resolution**:
  1. Open [Tailscale Admin Machines](https://login.tailscale.com/admin/machines).
  2. Locate machine `hemz` -> click `...` -> **Share...**.
  3. Generate a new single-use machine share link and provide it to the friend.

### 2. "Tailscale ping succeeds, but cannot connect in Palworld"
* **Key Distinction**: `tailscale ping` only verifies that the host machine is awake and reachable over the Tailscale WireGuard mesh. It does **not** prove that `PalServer.exe` is running or listening on UDP 8211.
* **Checks on Host Machine**:
  1. Verify `PalServer.exe` is currently running in Windows Task Manager.
  2. Verify Windows Defender Firewall has an Inbound Rule allowing UDP port 8211 for `PalServer-Win64-Shipping.exe`.
  3. Verify the game is running on port 8211 in `PalWorldSettings.ini`.

### 3. Connection Path: "RELAYED / DERP"
* **What it means**: Direct peer-to-peer UDP hole-punching could not be established between the two residential routers (often due to symmetric NAT or carrier-grade NAT). Tailscale is routing packets through its closest encrypted DERP relay server.
* **Is this an error?**: **No.** DERP relaying is an intentional fallback mechanism designed to guarantee connectivity where normal peer-to-peer networks fail.
* **Optimization**: If latency is high, playing on Ethernet and ensuring UPnP is enabled on the residential router can help establish a DIRECT peer-to-peer path.

### 4. How to Connect in Palworld
1. In Palworld main menu, select **Join Multiplayer Game**.
2. Scroll to the very bottom of the server browser.
3. Paste the server address (`100.x.x.x:8211`) into the direct connection text box.
4. If a password is required, click **[ COPY SERVER PASSWORD ]** in the setup app and paste it when prompted.
5. Click **Connect**.
