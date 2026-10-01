@echo off
title Tailscale Host Dashboard - Universal Game & Server Manager
setlocal EnableDelayedExpansion

:: ----------------------------------------------------------------------
:: Resolve Script Directory
:: ----------------------------------------------------------------------
set "SCRIPT_DIR=%~dp0"
set "ROOT_SERVERS=%SCRIPT_DIR%.."
pushd "%ROOT_SERVERS%"
set "SERVERS_DIR=%CD%"
popd

set "TS_EXE=C:\Program Files\Tailscale\tailscale.exe"
set "TS_IPN=C:\Program Files\Tailscale\tailscale-ipn.exe"

cls
echo ======================================================================
echo           TAILSCALE HOST DASHBOARD ^& SERVER MANAGER
echo ======================================================================
echo.

:: ----------------------------------------------------------------------
:: 1. CHECK & START TAILSCALE WINDOWS SERVICE
:: ----------------------------------------------------------------------
echo [1/3] Checking Tailscale background service...
sc query Tailscale 2>nul | findstr /i "RUNNING" >nul
if %errorlevel% neq 0 (
    echo   [!] Tailscale service is not running. Starting service...
    net start Tailscale >nul 2>&1
    if %errorlevel% neq 0 (
        echo   [*] Requesting administrator rights to start Tailscale service...
        powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/c net start Tailscale' -Verb RunAs -Wait"
    )
    timeout /t 2 >nul
) else (
    echo   [OK] Tailscale Windows background service is ACTIVE.
)

:: ----------------------------------------------------------------------
:: 2. VERIFY TRAY CLIENT
:: ----------------------------------------------------------------------
echo [2/3] Verifying Tailscale tray client...
tasklist /FI "IMAGENAME eq tailscale-ipn.exe" 2>nul | findstr /i "tailscale-ipn.exe" >nul
if %errorlevel% neq 0 (
    if exist "%TS_IPN%" (
        echo   [+] Launching Tailscale tray client...
        start "" "%TS_IPN%"
    )
) else (
    echo   [OK] Tailscale system tray client is RUNNING.
)

:: ----------------------------------------------------------------------
:: 3. VERIFY TAILSCALE IP & LOGIN
:: ----------------------------------------------------------------------
echo [3/3] Checking Tailscale network connection...
set "TS_IP="
if exist "%TS_EXE%" (
    "%TS_EXE%" status 2>&1 | findstr /i "Logged out NeedsLogin Stopped" >nul
    if %errorlevel% equ 0 (
        echo   [*] Tailscale requires login. Bringing up connection...
        start "" "%TS_EXE%" up
        timeout /t 3 >nul
    )

    for /f "usebackq tokens=*" %%i in (`"%TS_EXE%" ip -4 2^>nul`) do (
        set "TS_IP=%%i"
    )
)

if "%TS_IP%"=="" (
    echo   [WARNING] Could not retrieve Tailscale IPv4 address.
    echo   Ensure you are logged into Tailscale. Defaulting to 100.97.56.52.
    set "TS_IP=100.97.56.52"
) else (
    echo   [OK] Your Host Tailscale IP: %TS_IP%
)

timeout /t 1 >nul

:: ----------------------------------------------------------------------
:: GAME SELECTOR MENU
:: ----------------------------------------------------------------------
:GAME_MENU
cls
echo ======================================================================
echo           TAILSCALE HOST DASHBOARD - SELECT GAME / SERVICE
echo ======================================================================
echo   Your Host Tailscale IP : %TS_IP%
echo ----------------------------------------------------------------------
echo   POPULAR GAME PRESETS:
echo     [1]  Minecraft: Java Edition          (Port 25565 - TCP)
echo     [2]  Minecraft: Bedrock Edition       (Port 19132 - UDP)
echo     [3]  Palworld Dedicated Server        (Port 8211  - UDP)
echo     [4]  Valheim Dedicated Server         (Port 2456  - UDP)
echo     [5]  Terraria / tModLoader            (Port 7777  - TCP)
echo     [6]  Enshrouded Dedicated Server      (Port 15636 - UDP)
echo     [7]  Factorio                         (Port 34197 - UDP)
echo     [8]  Project Zomboid                  (Port 16261 - UDP)
echo     [9]  Rust Dedicated Server            (Port 28015 - UDP)
echo     [10] 7 Days to Die                    (Port 26900 - TCP/UDP)
echo     [11] ARK: Survival Evolved / Ascended (Port 7777  - UDP)
echo     [12] Satisfactory Dedicated Server    (Port 7777  - UDP)
echo     [13] Sons of the Forest               (Port 8766  - UDP)
echo     [14] Web Server / HTTP Dashboard / API(Port 8080  - TCP)
echo.
echo   CUSTOM OPTIONS:
echo     [C]  Enter Custom Game Name and Port
echo     [T]  Tailscale Diagnostics ^& Connected Peers
echo     [S]  Open Tailscale Admin Machine Share Console
echo     [0]  Exit Dashboard
echo ======================================================================
set "CHOICE="
set /p "CHOICE=Select an option [1-14, C, T, S, 0]: "

if "%CHOICE%"=="1" (
    set "GAME_NAME=Minecraft: Java Edition"
    set "GAME_PORT=25565"
    set "GAME_PROTO=TCP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="2" (
    set "GAME_NAME=Minecraft: Bedrock Edition"
    set "GAME_PORT=19132"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="3" (
    set "GAME_NAME=Palworld Dedicated Server"
    set "GAME_PORT=8211"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="4" (
    set "GAME_NAME=Valheim Dedicated Server"
    set "GAME_PORT=2456"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="5" (
    set "GAME_NAME=Terraria / tModLoader"
    set "GAME_PORT=7777"
    set "GAME_PROTO=TCP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="6" (
    set "GAME_NAME=Enshrouded Dedicated Server"
    set "GAME_PORT=15636"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="7" (
    set "GAME_NAME=Factorio"
    set "GAME_PORT=34197"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="8" (
    set "GAME_NAME=Project Zomboid"
    set "GAME_PORT=16261"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="9" (
    set "GAME_NAME=Rust Dedicated Server"
    set "GAME_PORT=28015"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="10" (
    set "GAME_NAME=7 Days to Die"
    set "GAME_PORT=26900"
    set "GAME_PROTO=TCP/UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="11" (
    set "GAME_NAME=ARK: Survival Evolved"
    set "GAME_PORT=7777"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="12" (
    set "GAME_NAME=Satisfactory Dedicated Server"
    set "GAME_PORT=7777"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="13" (
    set "GAME_NAME=Sons of the Forest"
    set "GAME_PORT=8766"
    set "GAME_PROTO=UDP"
    goto ACTIVE_GAME_DASHBOARD
)
if "%CHOICE%"=="14" (
    set "GAME_NAME=Web / HTTP Dashboard"
    set "GAME_PORT=8080"
    set "GAME_PROTO=TCP"
    goto ACTIVE_GAME_DASHBOARD
)
if /i "%CHOICE%"=="C" goto CUSTOM_SERVER
if /i "%CHOICE%"=="T" goto TS_STATUS
if /i "%CHOICE%"=="S" goto OPEN_SHARE_ADMIN
if "%CHOICE%"=="0" goto EXIT_SCRIPT

echo Invalid option. Please select from the menu.
timeout /t 2 >nul
goto GAME_MENU

:CUSTOM_SERVER
cls
echo ======================================================================
echo                     CUSTOM SERVER CONFIGURATION
echo ======================================================================
echo.
set "GAME_NAME="
set /p "GAME_NAME=Enter Game / Server Name [e.g. My Custom Game]: "
if "%GAME_NAME%"=="" set "GAME_NAME=Custom Server"

set "GAME_PORT="
set /p "GAME_PORT=Enter Server Port Number [e.g. 7777]: "
if "%GAME_PORT%"=="" (
    echo [ERROR] Port number is required.
    timeout /t 2 >nul
    goto CUSTOM_SERVER
)

set "GAME_PROTO=TCP/UDP"
set /p "GAME_PROTO=Enter Protocol (TCP / UDP / BOTH) [Default: BOTH]: "
if "%GAME_PROTO%"=="" set "GAME_PROTO=TCP/UDP"
goto ACTIVE_GAME_DASHBOARD

:: ----------------------------------------------------------------------
:: ACTIVE SERVER DASHBOARD & ACTIONS
:: ----------------------------------------------------------------------
:ACTIVE_GAME_DASHBOARD
:: Check port status
set "PORT_STATUS=UNKNOWN"
if /i "%GAME_PROTO%"=="TCP" (
    powershell -NoProfile -Command "$c = Get-NetTCPConnection -LocalPort %GAME_PORT% -ErrorAction SilentlyContinue; if ($c) { exit 0 } else { exit 1 }"
    if !errorlevel! equ 0 (set "PORT_STATUS=ACTIVE (Listening)") else (set "PORT_STATUS=OFFLINE (Not listening)")
) else if /i "%GAME_PROTO%"=="UDP" (
    powershell -NoProfile -Command "$u = Get-NetUDPEndpoint -LocalPort %GAME_PORT% -ErrorAction SilentlyContinue; if ($u) { exit 0 } else { exit 1 }"
    if !errorlevel! equ 0 (set "PORT_STATUS=ACTIVE (Listening)") else (set "PORT_STATUS=OFFLINE (Not listening)")
) else (
    powershell -NoProfile -Command "$c = Get-NetTCPConnection -LocalPort %GAME_PORT% -ErrorAction SilentlyContinue; $u = Get-NetUDPEndpoint -LocalPort %GAME_PORT% -ErrorAction SilentlyContinue; if ($c -or $u) { exit 0 } else { exit 1 }"
    if !errorlevel! equ 0 (set "PORT_STATUS=ACTIVE (Listening)") else (set "PORT_STATUS=OFFLINE (Not listening)")
)

:: Auto copy join address to clipboard
powershell -NoProfile -Command "Set-Clipboard -Value '%TS_IP%:%GAME_PORT%'"

cls
echo ======================================================================
echo         TAILSCALE HOST CONTROL PANEL - %GAME_NAME%
echo ======================================================================
echo   Target Service    : %GAME_NAME%
echo   Port ^& Protocol  : %GAME_PORT% (%GAME_PROTO%)
echo   Port Status       : %PORT_STATUS%
echo ----------------------------------------------------------------------
echo   YOUR Localhost IP : 127.0.0.1:%GAME_PORT%
echo   FRIEND DIRECT IP  : %TS_IP%:%GAME_PORT%
echo ----------------------------------------------------------------------
echo   [!] Auto-Copied '%TS_IP%:%GAME_PORT%' to your clipboard!
echo ======================================================================
echo.
echo   ACTIONS:
echo     [1] Re-copy FRIEND Join Address (%TS_IP%:%GAME_PORT%)
echo     [2] Copy MY Localhost Address (127.0.0.1:%GAME_PORT%)
echo     [3] Open/Allow Windows Defender Firewall Rule for Port %GAME_PORT%
echo     [4] Check Tailscale Peers ^& Connected Friends
echo     [5] Ping a Connected Friend via Tailscale
echo     [6] Open Tailscale Admin Machine Share Console
echo     [7] Launch Local Server (Search H:\Servers)
echo     [8] Switch to another Game / Port
echo     [0] Exit Dashboard
echo ======================================================================
set "ACT="
set /p "ACT=Select action [0-8]: "

if "%ACT%"=="1" goto COPY_FRIEND
if "%ACT%"=="2" goto COPY_LOCAL
if "%ACT%"=="3" goto ADD_FIREWALL
if "%ACT%"=="4" goto VIEW_PEERS
if "%ACT%"=="5" goto PING_FRIEND
if "%ACT%"=="6" goto OPEN_SHARE_ADMIN
if "%ACT%"=="7" goto LAUNCH_LOCAL_SERVER
if "%ACT%"=="8" goto GAME_MENU
if "%ACT%"=="0" goto EXIT_SCRIPT

echo Invalid action.
timeout /t 1 >nul
goto ACTIVE_GAME_DASHBOARD

:COPY_FRIEND
powershell -NoProfile -Command "Set-Clipboard -Value '%TS_IP%:%GAME_PORT%'"
echo.
echo   [OK] Copied '%TS_IP%:%GAME_PORT%' to Windows clipboard. Ready to paste in Discord/chat!
timeout /t 2 >nul
goto ACTIVE_GAME_DASHBOARD

:COPY_LOCAL
powershell -NoProfile -Command "Set-Clipboard -Value '127.0.0.1:%GAME_PORT%'"
echo.
echo   [OK] Copied '127.0.0.1:%GAME_PORT%' to Windows clipboard.
timeout /t 2 >nul
goto ACTIVE_GAME_DASHBOARD

:ADD_FIREWALL
echo.
echo Configuring Windows Defender Firewall for Port %GAME_PORT% (%GAME_PROTO%)...
powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/c netsh advfirewall firewall add rule name=""Tailscale - %GAME_NAME% %GAME_PORT%"" dir=in action=allow protocol=TCP localport=%GAME_PORT% & netsh advfirewall firewall add rule name=""Tailscale - %GAME_NAME% %GAME_PORT%"" dir=in action=allow protocol=UDP localport=%GAME_PORT%' -Verb RunAs -Wait"
echo   [OK] Firewall rules configured for port %GAME_PORT%!
timeout /t 2 >nul
goto ACTIVE_GAME_DASHBOARD

:VIEW_PEERS
cls
echo ======================================================================
echo                  CONNECTED TAILSCALE PEERS ^& STATUS
echo ======================================================================
echo.
if exist "%TS_EXE%" (
    "%TS_EXE%" status
) else (
    echo [ERROR] Tailscale CLI not found at %TS_EXE%
)
echo.
echo Press any key to return to dashboard...
pause >nul
goto ACTIVE_GAME_DASHBOARD

:PING_FRIEND
cls
echo ======================================================================
echo                      PING A TAILSCALE PEER
echo ======================================================================
echo.
set "PEER_TARGET="
set /p "PEER_TARGET=Enter friend's Tailscale IP or machine name: "
if not "%PEER_TARGET%"=="" (
    echo.
    "%TS_EXE%" ping "%PEER_TARGET%"
)
echo.
echo Press any key to return to dashboard...
pause >nul
goto ACTIVE_GAME_DASHBOARD

:OPEN_SHARE_ADMIN
echo.
echo Opening Tailscale Admin Machines page in default browser...
start https://login.tailscale.com/admin/machines
echo   [TIP] Find machine 'hemz' or your PC -> Click '...' -> Click 'Share...' -> Copy invitation link!
timeout /t 3 >nul
goto ACTIVE_GAME_DASHBOARD

:LAUNCH_LOCAL_SERVER
cls
echo ======================================================================
echo                       LAUNCH LOCAL SERVER
echo ======================================================================
echo Checking for known servers in %SERVERS_DIR%...
echo.
if exist "%SERVERS_DIR%\Minecraft Server\Start-Tailscale-Minecraft.bat" (
    echo   [1] Minecraft Server (H:\Servers\Minecraft Server)
)
if exist "%SERVERS_DIR%\Palworld server\Start-Server-And-Tailscale.bat" (
    echo   [2] Palworld Server (H:\Servers\Palworld server)
)
if exist "%SERVERS_DIR%\Palworld server\Run-PalworldServer.bat" (
    echo   [3] Palworld Dedicated Server Direct Console
)
echo   [B] Back to Dashboard
echo.
set "LS_OPT="
set /p "LS_OPT=Select server to launch [or B]: "
if "%LS_OPT%"=="1" (
    start "" "%SERVERS_DIR%\Minecraft Server\Start-Tailscale-Minecraft.bat"
)
if "%LS_OPT%"=="2" (
    start "" "%SERVERS_DIR%\Palworld server\Start-Server-And-Tailscale.bat"
)
if "%LS_OPT%"=="3" (
    start "" "%SERVERS_DIR%\Palworld server\Run-PalworldServer.bat"
)
goto ACTIVE_GAME_DASHBOARD

:EXIT_SCRIPT
echo.
echo Exiting dashboard. Your Tailscale connection and servers remain running!
timeout /t 1 >nul
exit /b 0
