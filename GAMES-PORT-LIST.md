# 🎮 Dedicated Game Server Port & Protocol Reference

Comprehensive reference guide for hosting game servers over Tailscale.

When hosting games with Tailscale, your friends connect directly to your **Tailscale IPv4 Address** (`100.x.y.z`) combined with the game's server port (`<TAILSCALE_IP>:<PORT>`).

---

## 📋 Common Multiplayer Game Ports

| Game | Default Port | Protocol | How Friends Connect |
| :--- | :--- | :--- | :--- |
| **Minecraft (Java Edition)** | `25565` | **TCP** | Multiplayer -> Direct Connection -> `100.x.y.z:25565` |
| **Minecraft (Bedrock Edition)** | `19132` | **UDP** | Play -> Servers -> Add Server -> IP `100.x.y.z`, Port `19132` |
| **Palworld** | `8211` | **UDP** | Join Multiplayer Game -> Bottom bar -> `100.x.y.z:8211` |
| **Valheim** | `2456 - 2458` | **UDP** | Join Game -> Join IP -> `100.x.y.z:2456` |
| **Terraria / tModLoader** | `7777` | **TCP** | Multiplayer -> Join via IP -> `100.x.y.z` -> Port `7777` |
| **Enshrouded** | `15636 - 15637` | **UDP** | Play -> Join -> Search server name or Direct IP |
| **Factorio** | `34197` | **UDP** | Multiplayer -> Connect to address -> `100.x.y.z:34197` |
| **Project Zomboid** | `16261` | **UDP** | Join -> Direct Connect -> IP `100.x.y.z`, Port `16261` |
| **Rust** | `28015` | **UDP** | In-game console (`F1`): `client.connect 100.x.y.z:28015` |
| **7 Days to Die** | `26900` | **TCP & UDP** | Join a Game -> Connect to IP -> `100.x.y.z:26900` |
| **ARK: Survival Evolved / Ascended** | `7777, 27015` | **UDP** | Steam Favorites -> Add Server `100.x.y.z:27015` or in-game |
| **Satisfactory** | `7777` | **UDP** | Server Manager -> Add Server -> `100.x.y.z:7777` |
| **Sons of the Forest** | `8766, 27016` | **UDP** | Multiplayer -> Dedicated -> Search server name |
| **Garry's Mod / Source Engine** | `27015` | **UDP** | In-game console (~): `connect 100.x.y.z:27015` |
| **Counter-Strike 2 / CS:GO** | `27015` | **UDP** | In-game console (~): `connect 100.x.y.z:27015` |
| **Left 4 Dead 2** | `27015` | **UDP** | In-game console (~): `connect 100.x.y.z:27015` |
| **Team Fortress 2** | `27015` | **UDP** | In-game console (~): `connect 100.x.y.z:27015` |
| **Assetto Corsa** | `9600` | **TCP & UDP** | Content Manager -> Direct Connect -> `100.x.y.z:9600` |
| **Starbound** | `21025` | **TCP** | Join Multiplayer -> IP `100.x.y.z:21025` |
| **Don't Starve Together** | `10999` | **UDP** | Direct connect or Steam invite |
| **Space Engineers** | `27016` | **UDP** | Join Game -> Direct Connect -> `100.x.y.z:27016` |
| **V Rising** | `9876` | **UDP** | Play -> Online Play -> Direct Connect -> `100.x.y.z:9876` |
| **Conan Exiles** | `7777` | **UDP** | Play Online -> Direct Connect -> `100.x.y.z:7777` |
| **Web Server / Dashboard / API** | `8080 / 3000` | **TCP** | Browser: `http://100.x.y.z:8080` |

---

## 💡 Quick Tips for Game Hosting

1. **Protocol Matters**:
   - **TCP** games (like Minecraft Java and Terraria) establish persistent, reliable streams.
   - **UDP** games (like Palworld, Valheim, and Rust) use low-latency datagrams. When adding Windows Firewall rules, make sure UDP is allowed!
2. **Finding Your Tailscale IP**:
   - Run `Host-Dashboard.bat` on your PC, or in Command Prompt type:
     ```cmd
     tailscale ip -4
     ```
3. **No Port Forwarding Required**:
   - Unlike public IP hosting where you must log into your home Wi-Fi router to configure NAT port forwarding, **Tailscale handles NAT traversal automatically using encrypted WireGuard tunnels**.
