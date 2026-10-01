# 🌐 Tailscale Setup — Palworld & Minecraft Java Server Hosting

A streamlined, self-contained suite of tools and scripts for **hosting Palworld and Minecraft Java Edition dedicated servers on your Windows PC** and having **friends join you privately via Tailscale** with zero port forwarding, no router access needed, and direct peer-to-peer WireGuard speed.

---

## ⚡ Why Tailscale? (Replacing Hamachi & Port Forwarding)

Traditionally, self-hosting a game server requires either:
1. **Risky Port Forwarding:** Logging into your home Wi-Fi router, opening ports to the public Internet, and exposing your public IP to DDoS attacks and port scanners.
2. **Clunky Third-Party Apps (Hamachi / Radmin):** Slow relayed speeds, 5-player limits, intrusive ads, and broken virtual network adapters.

**Tailscale solves this permanently:**
* **Encrypted WireGuard Mesh:** Friends connect directly to your PC over an authenticated, end-to-end encrypted WireGuard tunnel.
* **Direct Peer-to-Peer Latency:** Lowest possible in-game ping (LAN-like performance).
* **Machine Sharing Isolation:** Using Tailscale's **Machine Share** feature, friends receive private access **strictly to your game server PC**, never to your home router, family devices, or other computers on your network.
* **100% Free & Unlimited:** No player caps, no bandwidth throttling, no ads.

---

## 🎮 Active Game Profiles

| Game | Port | Protocol | In-Game Connection |
| :--- | :--- | :--- | :--- |
| **Palworld Dedicated Server** | `8211` | **UDP** | Join Multiplayer Game -> Bottom bar -> `100.97.56.52:8211` |
| **Minecraft (Java Edition)** | `25565` | **TCP** | Multiplayer -> Direct Connection -> `100.97.56.52:25565` |

*(Custom ports can also be hosted on demand via the Custom Port option).*

---

## 📂 Repository Structure

```text
Tailscale-Setup/
│
├── 🚀 Host Tools (For Server Owner / Hemz)
│   ├── Host-Dashboard.bat             # Host Control Panel (Palworld/Minecraft selector, auto-copies friend IP, status check)
│   ├── Setup-Firewall-Rule.bat        # 1-Click Windows Defender Firewall rule manager for Palworld & Minecraft
│   └── Host-Setup.ps1                 # Host pre-flight setup & diagnostics (service status, IP, machine share guide)
│
├── 👥 Friend Tools (To Send to Players)
│   ├── Friend-Quick-Join.bat          # 1-Click zero-dependency script (auto-installs Tailscale, tests ping, copies IP:PORT)
│   ├── FRIEND-GUIDE.md                # 3-step Markdown guide ready to share in Discord / WhatsApp
│   └── Release/                       # Standalone friend distribution folder
│       ├── Tailscale-Connection-Setup.exe   # Single-file GUI app for friends
│       ├── Friend-Quick-Join.bat           # Lightweight batch launcher for friends
│       ├── README-FOR-FRIEND.txt          # Plaintext 3-step friend walkthrough
│       └── Tailscale-Connection-Setup.zip  # Ready-to-send ZIP archive
│
├── 🎮 Configuration
│   ├── Config/
│   │   ├── connection.json            # Host server configuration (Host IP: 100.97.56.52, device name)
│   │   └── games-presets.json         # Presets for Palworld and Minecraft Java
│   └── GAMES-PORT-LIST.md             # Game port and protocol reference
│
└── 📖 Guides & Architecture
    ├── TAILSCALE-MACHINE-SHARE.md     # In-depth guide on Tailscale Node Isolation & share links
    ├── FIREWALL-GUIDE.md              # Windows Defender Firewall troubleshooting & manual commands
    ├── BUILD.md                       # Building and compiling the GUI binary
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
Select your game from the menu:
- `[1]` **Palworld Dedicated Server** — Port `8211` (UDP)
- `[2]` **Minecraft: Java Edition** — Port `25565` (TCP)

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

To reflect this setup on GitHub:

1. **Go to GitHub Repository Settings:**
   👉 [https://github.com/Hemz1416/Palworld-server-Tailscale-Setup/settings](https://github.com/Hemz1416/Palworld-server-Tailscale-Setup/settings)
2. In the **Repository name** box, change:
   `Palworld-server-Tailscale-Setup` ➔ `Tailscale-Setup`
3. Click **Rename**.
4. Update your local git remote URL:
   ```cmd
   git remote set-url origin https://github.com/Hemz1416/Tailscale-Setup.git
   ```
