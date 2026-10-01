================================================================================
                    HEMZ TAILSCALE GAME SERVER CONNECTION GUIDE
================================================================================

Welcome! This package allows you to connect securely to Hemz's hosted game
servers over Tailscale with zero port forwarding and the lowest possible ping.

--------------------------------------------------------------------------------
OPTION A: 1-CLICK QUICK JOIN BATCH SCRIPT (FASTEST & LIGHTWEIGHT)
--------------------------------------------------------------------------------
1. Double-click: Friend-Quick-Join.bat
2. If Tailscale is not installed, it will automatically download and install it.
3. Sign in to Tailscale in your browser (or accept Hemz's machine share link).
4. Select the game you are joining (Minecraft, Palworld, Valheim, Terraria, etc.).
5. The exact server IP & port is AUTOMATICALLY COPIED to your Windows clipboard!
6. Launch your game, go to Multiplayer / Direct Connect, and press Ctrl+V to paste!

--------------------------------------------------------------------------------
OPTION B: GRAPHICAL CONNECTION APP (HEMZ CONNECTION SETUP)
--------------------------------------------------------------------------------
1. Double-click: Hemz-Palworld-Connection-Setup.exe (or Tailscale-Connection-Setup.exe)
2. Follow the on-screen status badges:
   - Green [Tailscale: Active]
   - Green [Host PC: Reachable]
3. Click [ CONNECT / COPY ADDRESS ] to copy the join address and launch game!

--------------------------------------------------------------------------------
COMMON GAME IN-GAME JOIN STEPS:
--------------------------------------------------------------------------------
- Minecraft (Java Edition):
    Multiplayer -> Direct Connection -> Paste (Ctrl+V) -> Join Server
- Minecraft (Bedrock Edition):
    Play -> Servers tab -> Add Server -> Enter Host IP -> Port 19132
- Palworld:
    Join Multiplayer Game -> Bottom IP address bar -> Paste (Ctrl+V) -> Connect
- Valheim:
    Start Game -> Join Game -> Join IP -> Paste (Ctrl+V) -> Connect
- Terraria / tModLoader:
    Multiplayer -> Join via IP -> Enter Host IP -> Port 7777
- Project Zomboid:
    Join -> Direct Connect -> Enter Host IP and Port 16261
- Rust:
    Press F1 in-game -> Type: client.connect <HOST_IP>:28015

--------------------------------------------------------------------------------
NEED HELP / TROUBLESHOOTING:
--------------------------------------------------------------------------------
- Verify the Tailscale icon is running in your Windows system tray (bottom-right).
- If ping fails, ask Hemz to ensure the server is active on Host-Dashboard.bat.
================================================================================
