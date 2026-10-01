# 🎮 Game Server Port & Protocol Reference

Port reference guide for hosting dedicated servers over Tailscale.

When hosting games with Tailscale, your friends connect directly to your **Tailscale IPv4 Address** (`100.x.y.z`) combined with the game's server port (`<TAILSCALE_IP>:<PORT>`).

---

## ⚡ Active Games Supported Now

| Game | Default Port | Protocol | How Friends Connect |
| :--- | :--- | :--- | :--- |
| **Palworld Dedicated Server** | `8211` | **UDP** | Join Multiplayer Game -> Bottom address bar -> `100.x.y.z:8211` |
| **Minecraft (Java Edition)** | `25565` | **TCP** | Multiplayer -> Direct Connection (or Add Server) -> `100.x.y.z:25565` |

---

## 💡 Quick Tips

1. **Protocol Differences**:
   - **Minecraft Java** uses **TCP 25565** (reliable stream).
   - **Palworld** uses **UDP 8211** (low-latency datagrams).
   - Windows Defender Firewall rules must match the protocol. Run `Setup-Firewall-Rule.bat` to open both automatically.
2. **Finding Your Tailscale IP**:
   - Run `Host-Dashboard.bat` on your PC, or in Command Prompt type:
     ```cmd
     tailscale ip -4
     ```
3. **Future Games**:
   - Other games (Valheim, Terraria, Enshrouded, Rust, etc.) can still be hosted using the **Custom Port** option in `Host-Dashboard.bat` and will be added as dedicated presets in future updates.
