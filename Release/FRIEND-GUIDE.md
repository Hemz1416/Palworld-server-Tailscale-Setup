# 🤝 Friend's Quick Guide: Joining Hemz via Tailscale

Welcome! You're connecting to Hemz's private, dedicated game server machine over Tailscale.

---

## ⚡ What is Tailscale? (And why is it safe?)
Tailscale is a zero-configuration, encrypted private mesh network built on WireGuard®.
- **Safe & Isolated**: You only connect directly to Hemz's PC. Hemz cannot see your private files, your home network, or your browsing history.
- **No Ads, No Software Bloat**: Unlike Hamachi or Radmin, Tailscale is an official, open-source enterprise tool that runs silently in the background with near-zero resource usage.
- **Fast & Direct**: It forms a direct peer-to-peer encrypted connection between you and Hemz with the lowest possible gaming ping.

---

## 🚀 How to Connect in 3 Simple Steps

### Step 1: Install Tailscale (If you don't have it yet)
You can install Tailscale using either method:
- **Automatic (Fastest)**: Double-click [`Friend-Quick-Join.bat`](file:///Friend-Quick-Join.bat) (it will download and install Tailscale for you automatically).
- **Manual**: Download the official Windows installer from [tailscale.com/download](https://tailscale.com/download).

### Step 2: Accept Hemz's Machine Share or Sign In
1. Hemz will give you a **Machine Share link** (e.g. `https://login.tailscale.com/a/...`) or Tailnet invite.
2. Click the link in your web browser.
3. Sign in with any free account (Google, Microsoft, GitHub, or Apple) and click **Accept**.
4. That's it! Hemz's PC will now show up as a connected device on your Tailscale network.

### Step 3: Copy Join Address & Play!
Double-click [`Friend-Quick-Join.bat`](file:///Friend-Quick-Join.bat):
1. The script will test your connection to Hemz's server and verify ping.
2. Select the game you are playing (e.g., Minecraft, Palworld, Valheim, etc.).
3. The server address (`100.x.y.z:PORT`) is **automatically copied to your clipboard**!
4. Launch your game, go to Multiplayer / Direct Connect, and press `Ctrl+V` to paste the address!

---

## 🕹️ In-Game Join Cheat Sheet

| Game | How to Paste & Join |
| :--- | :--- |
| **Minecraft (Java)** | Multiplayer -> Direct Connection -> `Ctrl+V` -> Join Server |
| **Minecraft (Bedrock)** | Play -> Servers -> Add Server -> Paste IP -> Port `19132` |
| **Palworld** | Join Multiplayer Game -> Bottom address bar -> `Ctrl+V` -> Connect |
| **Valheim** | Join Game -> Join IP -> `Ctrl+V` -> Connect |
| **Terraria** | Multiplayer -> Join via IP -> Enter IP -> Port `7777` |
| **Project Zomboid** | Join -> Direct Connect -> Enter IP and Port `16261` |
| **Rust** | In-game press `F1` -> Type: `client.connect 100.x.y.z:28015` |
| **Enshrouded** | Play -> Join -> Search server or Direct Connect |

---

## ❓ Need Help?
- **Cannot connect?** Make sure the Tailscale icon is visible in your Windows System Tray (bottom right near the clock) and shows "Connected".
- **Ask Hemz:** Hemz can run `Host-Dashboard.bat` to verify if the server is active and unblocked in Windows Firewall!
