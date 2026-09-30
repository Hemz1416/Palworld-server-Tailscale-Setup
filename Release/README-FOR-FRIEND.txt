================================================================================
                    HEMZ PALWORLD DEDICATED SERVER
                        PLAYER CONNECTION GUIDE
================================================================================

Welcome! This package allows you to connect securely to the shared Hemz Palworld
server machine through Tailscale.

--------------------------------------------------------------------------------
HOW TO CONNECT (SIMPLE 3-STEP GUIDE)
--------------------------------------------------------------------------------

STEP 1: Run the Connection App
  - Double-click: Hemz-Palworld-Connection-Setup.exe
  - If Tailscale is not installed on your PC, the app will ask to download and
    install official Tailscale automatically. Click YES when Windows asks for
    permission.

STEP 2: Sign in to Tailscale & Accept Machine Share
  - A browser window will open with the Tailscale machine-share invitation.
  - Sign in with your personal Google, Microsoft, Apple, or GitHub account and
    accept the invitation to access the shared Palworld server machine.
    (Note: This grants you private access only to the Palworld server machine,
    not any other devices or the host's entire tailnet).
  - Return to Hemz-Palworld-Connection-Setup.exe.
  - The status will turn GREEN ("HEMZ PALWORLD SERVER ONLINE") automatically.

STEP 3: Launch Palworld and Play
  - Click the green button: [ CONNECT TO PALWORLD ]
  - This automatically copies the server address (e.g., 100.x.x.x:8211) to your
    Windows clipboard and launches Palworld (if safely detected).
  - If the server has a password, click [ COPY SERVER PASSWORD ] in the app
    to copy it when needed (it will not overwrite your clipboard silently).
  - In the Palworld main menu, click:
      "Join Multiplayer Game"
  - In the direct IP connection box at the bottom, paste (Ctrl+V):
      The server address (e.g., 100.x.x.x:8211)
  - If prompted for a password, paste the server password.
  - Click "Connect" and enjoy!

--------------------------------------------------------------------------------
NEED HELP?
--------------------------------------------------------------------------------
- Click the [ TROUBLESHOOT ] button inside the app to run an automated diagnostic
  check verifying Tailscale, the Tailscale Windows service, shared server
  discovery, and ping latency.
- Or click [ OPEN LOG ] to view the local diagnostic log.
================================================================================
