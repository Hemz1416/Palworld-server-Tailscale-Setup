# 🌐 Tailscale Setup — Universal Game Server Hosting & Connection Hub

A complete, self-contained suite of tools, scripts, and documentation for **hosting any game server or application on your Windows PC** and having **friends join you privately via Tailscale** with zero port forwarding, no router access needed, and direct peer-to-peer WireGuard speed.

Works seamlessly for **Minecraft (Java & Bedrock)**, **Palworld**, **Valheim**, **Terraria**, **Enshrouded**, **Factorio**, **Project Zomboid**, **Rust**, **7 Days to Die**, **ARK**, **Sons of the Forest**, **Web Dashboards**, or **any custom game/TCP/UDP port**.

---

## ⚡ Why Tailscale? (Replacing Hamachi & Port Forwarding)

Traditionally, self-hosting a game server requires either:
1. **Risky Port Forwarding:** Logging into your home Wi-Fi router, opening ports to the public Internet, and exposing your public IP to DDoS attacks and port scanners.
2. **Clunky Third-Party Apps (Hamachi / Radmin):** Slow relayed speeds, 5-player limits, intrusive ads, and broken network adapters.

**Tailscale solves this permanently:**
* **Encrypted WireGuard Mesh:** Friends connect directly to your PC over an authenticated, end-to-end encrypted WireGuard tunnel.
* **Direct Peer-to-Peer Latency:** Lowest possible in-game ping (LAN-like performance).
* **Machine Sharing Isolation:** Using Tailscale's **Machine Share** feature, friends receive private access **strictly to your game server PC**, never to your home router, family devices, or other computers on your network.
* **100% Free & Unlimited:** No player caps, no bandwidth throttling, no ads.

---

## 📂 Repository Structure

```text
Tailscale-Setup/
│
├── 🚀 Host Tools (For Server Owner / Hemz)
│   ├── Host-Dashboard.bat             # Universal Host Control Panel (game presets, auto-copies friend IP, status check)
│   ├── Setup-Firewall-Rule.bat        # 1-Click Windows Defender Firewall rule manager for any game port
│   └── Host-Setup.ps1                 # Host pre-flight setup & diagnostics (service status, IP, machine share guide)
│
├── 👥 Friend Tools (To Send to Players)
│   ├── Friend-Quick-Join.bat          # 1-Click zero-dependency script (auto-installs Tailscale, tests ping, copies IP:PORT)
│   ├── FRIEND-GUIDE.md                # 3-step Markdown guide ready to share in Discord / WhatsApp
│   └── Release/                       # Standalone friend distribution folder
│       ├── Tailscale-Connection-Setup.exe   # Modern single-file GUI app for friends
│       ├── Friend-Quick-Join.bat           # Lightweight batch launcher for friends
│       ├── README-FOR-FRIEND.txt          # Plaintext 3-step friend walkthrough
│       └── Tailscale-Connection-Setup.zip  # Ready-to-send ZIP archive
│
├── 🎮 Game Profiles & Reference
│   ├── Config/
│   │   ├── connection.json            # Host server configuration (Host IP: 100.97.56.52, default port, device name)
│   │   └── games-presets.json         # Pre-configured game database (ports, protocols, in-game connect hints)
│   └── GAMES-PORT-LIST.md             # Complete reference table for 25+ multiplayer games
│
├── 📱 GUI Application Source & Build
│   ├── App/                           # C# WPF (.NET 10) application source code
│   └── Build/
│       ├── Build-Release.ps1          # Automated single-file win-x64 release compiler
│       └── Configure-Connection.ps1   # Interactive CLI wizard to customize server settings
│
└── 📖 Guides & Architecture
    ├── TAILSCALE-MACHINE-SHARE.md     # In-depth guide on Tailscale Node Isolation & share links
    ├── FIREWALL-GUIDE.md              # Windows Defender Firewall troubleshooting & manual commands
    ├── BUILD.md                       # Building and compiling the C# WPF GUI binary
    ├── SECURITY.md                    # Security architecture & credential safety
    └── TROUBLESHOOTING.md             # Diagnostic audit, DERP relays, UDP NAT traversal
```

---

## 🎮 Host Quick Start (For Hemz)

### Step 1: Open the Host Control Panel
Double-click [`Host-Dashboard.bat`](file:///Host-Dashboard.bat):
1. **Service Watchdog:** Automatically verifies and starts the `Tailscale` Windows background service (elevating via UAC if stopped).
2. **Tray Client:** Ensures the Tailscale system tray icon (`tailscale-ipn.exe`) is running.
3. **Resolves Host IP:** Queries your assigned Tailscale IP (`100.97.56.52`).

### Step 2: Choose Your Game
Select your game from the interactive menu:
- `[1]` **Minecraft (Java Edition)** — Port `25565` (TCP)
- `[2]` **Minecraft (Bedrock Edition)** — Port `19132` (UDP)
- `[3]` **Palworld Dedicated Server** — Port `8211` (UDP)
- `[4]` **Valheim Dedicated Server** — Port `2456` (UDP)
- `[5]` **Terraria / tModLoader** — Port `7777` (TCP)
- `[6]` **Enshrouded** — Port `15636` (UDP)
- `[7]` **Factorio** — Port `34197` (UDP)
- `[8]` **Project Zomboid** — Port `16261` (UDP)
- `[9]` **Rust** — Port `28015` (UDP)
- `[10]` **7 Days to Die** — Port `26900` (TCP/UDP)
- `[11]` **ARK: Survival Evolved / Ascended** — Port `7777` (UDP)
- `[12]` **Satisfactory** — Port `7777` (UDP)
- `[13]` **Sons of the Forest** — Port `8766` (UDP)
- `[14]` **Web Server / Dashboard** — Port `8080` (TCP)
- `[C]` **Custom Game / Port** — Enter any port number and protocol!

### Step 3: Instant Clipboard Copy & Server Verification
- The dashboard automatically detects if the server is active on that port.
- **The Friend Join Address (`100.97.56.52:<PORT>`) is automatically copied to your Windows clipboard!**
- Simply paste it (`Ctrl+V`) to your friends in Discord or WhatsApp.

### Step 4: Unblock Windows Firewall (First Time Only)
In `Host-Dashboard.bat`, press `[3]` or run [`Setup-Firewall-Rule.bat`](file:///Setup-Firewall-Rule.bat) as Administrator to ensure Windows Defender Firewall permits incoming traffic over Tailscale for that port.

---

## 👥 Friend Quick Start (For Players Joining You)

You can send your friend either:
1. **Lightweight Batch Launcher:** Send [`Friend-Quick-Join.bat`](file:///Friend-Quick-Join.bat) (runs directly on any Windows PC).
2. **Graphical App:** Send [`Release/Tailscale-Connection-Setup.exe`](file:///Release/Tailscale-Connection-Setup.exe) (or the complete ZIP [`Release/Tailscale-Connection-Setup.zip`](file:///Release/Tailscale-Connection-Setup.zip)).
3. **Friend Guide:** Send [`FRIEND-GUIDE.md`](file:///FRIEND-GUIDE.md) or [`Release/README-FOR-FRIEND.txt`](file:///Release/README-FOR-FRIEND.txt).

### What Happens When Your Friend Runs It:
1. **Automated Install:** If Tailscale is not installed on their computer, it automatically downloads and installs the official Tailscale client.
2. **Machine Share Acceptance:** Prompts them to accept your Tailscale Machine Share link or sign in.
3. **Connection & Latency Test:** Pings your PC (`100.97.56.52`) and displays ping in milliseconds.
4. **1-Click Copy:** The server address (`100.97.56.52:<PORT>`) is **automatically copied to their clipboard**.
5. **Paste & Play:** Friend launches the game, goes to Multiplayer / Direct Connect, and presses `Ctrl+V`!

---

## 📋 Common Multiplayer Game Ports Cheat Sheet

| Game | Default Port | Protocol | Friend In-Game Connection Step |
| :--- | :--- | :--- | :--- |
| **Minecraft (Java)** | `25565` | **TCP** | Multiplayer -> Direct Connection -> `Ctrl+V` |
| **Minecraft (Bedrock)** | `19132` | **UDP** | Play -> Servers -> Add Server -> Enter IP and Port `19132` |
| **Palworld** | `8211` | **UDP** | Join Multiplayer Game -> Bottom bar -> `Ctrl+V` |
| **Valheim** | `2456` | **UDP** | Join Game -> Join IP -> `Ctrl+V` |
| **Terraria** | `7777` | **TCP** | Multiplayer -> Join via IP -> Enter IP and Port `7777` |
| **Enshrouded** | `15636` | **UDP** | Play -> Join -> Direct Connect or search server name |
| **Factorio** | `34197` | **UDP** | Multiplayer -> Connect to address -> `Ctrl+V` |
| **Project Zomboid** | `16261` | **UDP** | Join -> Direct Connect -> IP and Port `16261` |
| **Rust** | `28015` | **UDP** | Press `F1` in-game -> Type `client.connect 100.97.56.52:28015` |
| **7 Days to Die** | `26900` | **TCP/UDP** | Join a Game -> Connect to IP -> Enter IP and Port `26900` |
| **ARK** | `7777` | **UDP** | Steam Favorites / Direct Connect -> `100.97.56.52:7777` |
| **Web / HTTP Dashboard** | `8080` | **TCP** | Web browser: `http://100.97.56.52:8080` |

*(See [GAMES-PORT-LIST.md](file:///GAMES-PORT-LIST.md) for 25+ additional games).*

---

## 🔒 Security & Machine Share Isolation

Rather than inviting friends to your entire Tailnet, this setup uses **Tailscale Machine Sharing**:

```text
Host PC ('Hemz' Game Server)
         │
         ▼ (Single-Device Machine Share Invitation)
Friend's Personal Tailscale Account
         │
         └── Friend receives private access ONLY to Host PC
```

* **No Network Leaks:** Friends cannot see or access your home router, other family PCs, NAS storage, or local devices.
* **Revocable Anytime:** Revoke access instantly from [Tailscale Admin Machines](https://login.tailscale.com/admin/machines).
* **Single-Use Invitations:** Share links expire once accepted, establishing secure peer-to-peer node authentication.

---

## 🛠️ GitHub Repository Renaming

To reflect this universal setup on GitHub:

1. **Go to GitHub Repository Settings:**
   👉 [https://github.com/Hemz1416/Palworld-server-Tailscale-Setup/settings](https://github.com/Hemz1416/Palworld-server-Tailscale-Setup/settings)
2. In the **Repository name** box, change:
   `Palworld-server-Tailscale-Setup` ➔ `Tailscale-Setup`
3. Click **Rename**.
4. GitHub automatically preserves all commit history, releases, and creates automatic redirects from the old URL to the new URL!
5. In your local repository, update the remote URL:
   ```cmd
   git remote set-url origin https://github.com/Hemz1416/Tailscale-Setup.git
   ```

---

## 📜 License & Credits

- Built and configured by **Hemz** for private server hosting.
- Tailscale is a registered trademark of Tailscale Inc.
