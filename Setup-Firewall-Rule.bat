@echo off
title Tailscale Firewall Helper - Palworld & Minecraft Java
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
echo Defender Firewall strictly over Tailscale (restricted to 100.64.0.0/10).
echo Traffic from the public internet or local LAN remains blocked.
echo.
echo Select the server you want to unblock:
echo   [1]  Palworld Dedicated Server (Port 8211 - UDP)
echo   [2]  Minecraft: Java Edition   (Port 25565 - TCP)
echo   [3]  Both Palworld ^& Minecraft Java (Open both at once)
echo   [C]  Custom Port ^& Protocol
echo   [0]  Exit
echo ======================================================================
set "OPT="
set /p "OPT=Choose option [1-3, C, 0]: "

if "%OPT%"=="1" (
    netsh advfirewall firewall add rule name="Tailscale - Palworld (8211 UDP)" dir=in action=allow protocol=UDP localport=8211 remoteip=100.64.0.0/10
    echo [OK] Opened UDP 8211 strictly for Tailscale peers (100.64.0.0/10).
    goto FINISH
)
if "%OPT%"=="2" (
    netsh advfirewall firewall add rule name="Tailscale - Minecraft Java (25565 TCP)" dir=in action=allow protocol=TCP localport=25565 remoteip=100.64.0.0/10
    echo [OK] Opened TCP 25565 strictly for Tailscale peers (100.64.0.0/10).
    goto FINISH
)
if "%OPT%"=="3" (
    echo Adding firewall rules for Palworld and Minecraft Java restricted to Tailscale...
    netsh advfirewall firewall add rule name="Tailscale - Palworld (8211 UDP)" dir=in action=allow protocol=UDP localport=8211 remoteip=100.64.0.0/10
    netsh advfirewall firewall add rule name="Tailscale - Minecraft Java (25565 TCP)" dir=in action=allow protocol=TCP localport=25565 remoteip=100.64.0.0/10
    echo [OK] Both Palworld and Minecraft Java rules added (restricted to Tailscale subnet 100.64.0.0/10).
    goto FINISH
)
if /i "%OPT%"=="C" (
    set "CPORT="
    set /p "CPORT=Enter port number to open: "
    if "!CPORT!"=="" goto FINISH
    netsh advfirewall firewall add rule name="Tailscale - Custom TCP (!CPORT!)" dir=in action=allow protocol=TCP localport=!CPORT! remoteip=100.64.0.0/10
    netsh advfirewall firewall add rule name="Tailscale - Custom UDP (!CPORT!)" dir=in action=allow protocol=UDP localport=!CPORT! remoteip=100.64.0.0/10
    echo [OK] Opened TCP and UDP for port !CPORT! strictly for Tailscale peers.
    goto FINISH
)
if "%OPT%"=="0" exit /b 0

:FINISH
echo.
echo ======================================================================
echo Configuration complete! Friends connecting via Tailscale can now connect.
echo Non-Tailscale traffic is not allowed.
echo ======================================================================
echo.
pause
