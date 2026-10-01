@echo off
title Tailscale Firewall Helper - Open Ports for Friends
setlocal EnableDelayedExpansion

:: Check Administrator Elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Requesting Administrator Elevation to configure Windows Defender Firewall...
    powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

cls
echo ======================================================================
echo           WINDOWS FIREWALL HELPER FOR TAILSCALE HOSTING
echo ======================================================================
echo This tool ensures your friends can reach your server through Windows
echo Defender Firewall over Tailscale without network blocks.
echo.
echo Select the game you want to unblock:
echo   [1]  Minecraft: Java Edition (Port 25565 - TCP)
echo   [2]  Minecraft: Bedrock Edition (Port 19132 - UDP)
echo   [3]  Palworld Dedicated Server (Port 8211 - UDP)
echo   [4]  Valheim Dedicated Server (Port 2456-2458 - UDP)
echo   [5]  Terraria / tModLoader (Port 7777 - TCP)
echo   [6]  Enshrouded Dedicated Server (Port 15636 - UDP)
echo   [7]  Factorio (Port 34197 - UDP)
echo   [8]  Project Zomboid (Port 16261 - UDP)
echo   [9]  Rust Dedicated Server (Port 28015 - UDP)
echo   [10] 7 Days to Die (Port 26900 - TCP/UDP)
echo   [11] ARK: Survival Evolved / Ascended (Port 7777, 27015 - UDP)
echo   [12] Web Server (Port 8080 - TCP)
echo   [13] All Popular Game Ports at Once! (Comprehensive rule set)
echo   [C]  Custom Port & Protocol
echo   [0]  Exit
echo ======================================================================
set "OPT="
set /p "OPT=Choose option [1-13, C, 0]: "

if "%OPT%"=="1" (
    netsh advfirewall firewall add rule name="Tailscale - Minecraft Java (25565)" dir=in action=allow protocol=TCP localport=25565
    echo [OK] Opened TCP 25565 for Minecraft Java.
    goto FINISH
)
if "%OPT%"=="2" (
    netsh advfirewall firewall add rule name="Tailscale - Minecraft Bedrock (19132)" dir=in action=allow protocol=UDP localport=19132
    echo [OK] Opened UDP 19132 for Minecraft Bedrock.
    goto FINISH
)
if "%OPT%"=="3" (
    netsh advfirewall firewall add rule name="Tailscale - Palworld (8211)" dir=in action=allow protocol=UDP localport=8211
    echo [OK] Opened UDP 8211 for Palworld.
    goto FINISH
)
if "%OPT%"=="4" (
    netsh advfirewall firewall add rule name="Tailscale - Valheim (2456-2458)" dir=in action=allow protocol=UDP localport=2456-2458
    echo [OK] Opened UDP 2456-2458 for Valheim.
    goto FINISH
)
if "%OPT%"=="5" (
    netsh advfirewall firewall add rule name="Tailscale - Terraria (7777)" dir=in action=allow protocol=TCP localport=7777
    echo [OK] Opened TCP 7777 for Terraria.
    goto FINISH
)
if "%OPT%"=="6" (
    netsh advfirewall firewall add rule name="Tailscale - Enshrouded (15636)" dir=in action=allow protocol=UDP localport=15636
    echo [OK] Opened UDP 15636 for Enshrouded.
    goto FINISH
)
if "%OPT%"=="7" (
    netsh advfirewall firewall add rule name="Tailscale - Factorio (34197)" dir=in action=allow protocol=UDP localport=34197
    echo [OK] Opened UDP 34197 for Factorio.
    goto FINISH
)
if "%OPT%"=="8" (
    netsh advfirewall firewall add rule name="Tailscale - Project Zomboid (16261)" dir=in action=allow protocol=UDP localport=16261
    echo [OK] Opened UDP 16261 for Project Zomboid.
    goto FINISH
)
if "%OPT%"=="9" (
    netsh advfirewall firewall add rule name="Tailscale - Rust (28015)" dir=in action=allow protocol=UDP localport=28015
    echo [OK] Opened UDP 28015 for Rust.
    goto FINISH
)
if "%OPT%"=="10" (
    netsh advfirewall firewall add rule name="Tailscale - 7 Days to Die TCP (26900)" dir=in action=allow protocol=TCP localport=26900
    netsh advfirewall firewall add rule name="Tailscale - 7 Days to Die UDP (26900)" dir=in action=allow protocol=UDP localport=26900
    echo [OK] Opened TCP & UDP 26900 for 7 Days to Die.
    goto FINISH
)
if "%OPT%"=="11" (
    netsh advfirewall firewall add rule name="Tailscale - ARK (7777,27015)" dir=in action=allow protocol=UDP localport=7777,27015
    echo [OK] Opened UDP 7777,27015 for ARK.
    goto FINISH
)
if "%OPT%"=="12" (
    netsh advfirewall firewall add rule name="Tailscale - Web (8080)" dir=in action=allow protocol=TCP localport=8080
    echo [OK] Opened TCP 8080 for Web.
    goto FINISH
)
if "%OPT%"=="13" (
    echo Adding firewall rules for common multiplayer game ports...
    netsh advfirewall firewall add rule name="Tailscale - Minecraft (25565 TCP)" dir=in action=allow protocol=TCP localport=25565
    netsh advfirewall firewall add rule name="Tailscale - Minecraft Bedrock (19132 UDP)" dir=in action=allow protocol=UDP localport=19132
    netsh advfirewall firewall add rule name="Tailscale - Palworld (8211 UDP)" dir=in action=allow protocol=UDP localport=8211
    netsh advfirewall firewall add rule name="Tailscale - Valheim (2456-2458 UDP)" dir=in action=allow protocol=UDP localport=2456-2458
    netsh advfirewall firewall add rule name="Tailscale - Terraria (7777 TCP)" dir=in action=allow protocol=TCP localport=7777
    netsh advfirewall firewall add rule name="Tailscale - Enshrouded (15636 UDP)" dir=in action=allow protocol=UDP localport=15636
    netsh advfirewall firewall add rule name="Tailscale - Factorio (34197 UDP)" dir=in action=allow protocol=UDP localport=34197
    netsh advfirewall firewall add rule name="Tailscale - Project Zomboid (16261 UDP)" dir=in action=allow protocol=UDP localport=16261
    netsh advfirewall firewall add rule name="Tailscale - Rust (28015 UDP)" dir=in action=allow protocol=UDP localport=28015
    netsh advfirewall firewall add rule name="Tailscale - 7 Days to Die (26900)" dir=in action=allow protocol=UDP localport=26900
    echo [OK] All common game ports successfully allowed in Windows Firewall!
    goto FINISH
)
if /i "%OPT%"=="C" (
    set "CPORT="
    set /p "CPORT=Enter port number to open: "
    if "!CPORT!"=="" goto FINISH
    netsh advfirewall firewall add rule name="Tailscale - Custom TCP (!CPORT!)" dir=in action=allow protocol=TCP localport=!CPORT!
    netsh advfirewall firewall add rule name="Tailscale - Custom UDP (!CPORT!)" dir=in action=allow protocol=UDP localport=!CPORT!
    echo [OK] Opened TCP and UDP for port !CPORT!.
    goto FINISH
)
if "%OPT%"=="0" exit /b 0

:FINISH
echo.
echo ======================================================================
echo Configuration complete! Friends connecting via Tailscale will not be
echo blocked by Windows Defender Firewall.
echo ======================================================================
echo.
pause
