# 🤝 Friend's Quick Guide: Joining Hemz via Tailscale

Welcome! You're connecting to Hemz's private, dedicated game server machine over Tailscale for **Palworld** and **Minecraft (Java Edition)**.

---

## ⚡ What is Tailscale? (And why is it safe?)
Tailscale is a zero-configuration, encrypted private mesh network built on WireGuard®.
- **Safe & Isolated**: You only connect directly to Hemz's server PC. Hemz cannot see your private files, your home network, or your browsing history.
- **No Ads, No Bloat**: Unlike Hamachi or Radmin, Tailscale runs silently in the background with near-zero CPU and memory usage.
- **Fast & Direct**: It creates a direct peer-to-peer encrypted tunnel between you and Hemz with low ping.

---

## 📥 Download Connection Tools

Download either file directly from the [Latest GitHub Release](https://github.com/Hemz1416/Tailscale-Setup/releases/latest):
* **[Download `Tailscale-Connection-Setup.exe`](https://github.com/Hemz1416/Tailscale-Setup/releases/latest/download/Tailscale-Connection-Setup.exe)** (Recommended GUI App)
* **[Download `Friend-Quick-Join.bat`](https://github.com/Hemz1416/Tailscale-Setup/releases/latest/download/Friend-Quick-Join.bat)** (Lightweight 1-Click Script)
* **[Download `Tailscale-Connection-Setup.zip`](https://github.com/Hemz1416/Tailscale-Setup/releases/latest/download/Tailscale-Connection-Setup.zip)** (Complete ZIP package)

---

## 🚀 How to Connect in 3 Simple Steps

### Step 1: Install Tailscale (If you don't have it yet)
- **Automatic**: Run `Tailscale-Connection-Setup.exe` or `Friend-Quick-Join.bat` (they will download and install official Tailscale for you automatically).
- **Manual**: Download the official Windows installer from [tailscale.com/download](https://tailscale.com/download).

### Step 2: Accept Hemz's Machine Share or Sign In
1. Hemz will send you a **Machine Share link** (e.g. `https://login.tailscale.com/a/...`) or Tailnet invite.
2. Open the link in your web browser.
3. Sign in with any free account (Google, Microsoft, GitHub, or Apple) and click **Accept**.
4. Hemz's PC will now show up as a connected device on your Tailscale network.

### Step 3: Copy Join Address & Play!
Double-click [`Friend-Quick-Join.bat`](file:///Friend-Quick-Join.bat):
1. The script verifies Tailscale and pings Hemz's PC (`100.97.56.52`).
2. Select:
   - `[1]` **Palworld Dedicated Server** (Port `8211`)
   - `[2]` **Minecraft: Java Edition** (Port `25565`)
3. The server address (`100.97.56.52:<PORT>`) is **automatically copied to your clipboard**!
4. Launch your game and press `Ctrl+V` to paste the address!

---

## 🕹️ In-Game Join Steps

### Palworld
1. In Palworld main menu, click **Join Multiplayer Game**.
2. Go to the address bar at the bottom of the screen.
3. Paste the address (Ctrl+V): `100.97.56.52:8211`
4. If a password is required, paste the password and click **Connect**!

### Minecraft (Java Edition)
1. In Minecraft main menu, click **Multiplayer**.
2. Click **Direct Connection** (or **Add Server**).
3. Paste the address (Ctrl+V): `100.97.56.52:25565`
4. Click **Join Server**!

---

## ❓ Need Help?
- Make sure the Tailscale icon is visible in your Windows System Tray (bottom right near the clock) and shows "Connected".
- If ping fails, ask Hemz to ensure the server is active on `Host-Dashboard.bat`.
