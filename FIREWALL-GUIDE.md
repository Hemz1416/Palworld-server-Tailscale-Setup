# 🛡️ Windows Defender Firewall Guide for Game Servers on Tailscale

When your friends connect to your server over Tailscale, traffic arrives at your PC through the virtual **Tailscale Network Adapter**.

Windows Defender Firewall evaluates this traffic just like any local network connection. If a game port is blocked by Windows Firewall, friends will get connection timeouts even though Tailscale ping succeeds!

---

## ⚡ 1-Click Solution (Recommended)

Run [`Setup-Firewall-Rule.bat`](file:///Setup-Firewall-Rule.bat) as Administrator on your PC:
- Choose your game preset (Minecraft, Palworld, Valheim, etc.) or choose **Option 13** to open all common game ports in one click.

---

## 🛠️ Manual PowerShell Commands

If you prefer opening ports manually, open PowerShell as Administrator and run the corresponding command:

### Minecraft: Java Edition (Port 25565 TCP)
```powershell
New-NetFirewallRule -DisplayName "Tailscale - Minecraft Java Server" -Direction Inbound -LocalPort 25565 -Protocol TCP -Action Allow
```

### Minecraft: Bedrock Edition (Port 19132 UDP)
```powershell
New-NetFirewallRule -DisplayName "Tailscale - Minecraft Bedrock Server" -Direction Inbound -LocalPort 19132 -Protocol UDP -Action Allow
```

### Palworld Dedicated Server (Port 8211 UDP)
```powershell
New-NetFirewallRule -DisplayName "Tailscale - Palworld Dedicated Server" -Direction Inbound -LocalPort 8211 -Protocol UDP -Action Allow
```

### Valheim Dedicated Server (Port 2456-2458 UDP)
```powershell
New-NetFirewallRule -DisplayName "Tailscale - Valheim Server" -Direction Inbound -LocalPort 2456-2458 -Protocol UDP -Action Allow
```

### Terraria Server (Port 7777 TCP)
```powershell
New-NetFirewallRule -DisplayName "Tailscale - Terraria Server" -Direction Inbound -LocalPort 7777 -Protocol TCP -Action Allow
```

### Generic / Custom Game Port
Replace `PORT_NUMBER` and `TCP` or `UDP`:
```powershell
New-NetFirewallRule -DisplayName "Tailscale - Custom Game Server" -Direction Inbound -LocalPort PORT_NUMBER -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Tailscale - Custom Game Server UDP" -Direction Inbound -LocalPort PORT_NUMBER -Protocol UDP -Action Allow
```

---

## 🔍 How to Verify Port Listening

To check if your game server is actually running and listening on the expected port, run in PowerShell:

```powershell
# For TCP games (e.g. Minecraft Java 25565):
Get-NetTCPConnection -LocalPort 25565 -ErrorAction SilentlyContinue

# For UDP games (e.g. Palworld 8211):
Get-NetUDPEndpoint -LocalPort 8211 -ErrorAction SilentlyContinue
```

If it returns an object with `State: Listen` or an owning Process ID (`OwningProcess`), your server is running and ready for friends!
