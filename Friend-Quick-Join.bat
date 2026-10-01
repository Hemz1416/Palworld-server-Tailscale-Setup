@echo off
title Friend Quick Join - Palworld & Minecraft Java
setlocal EnableDelayedExpansion

set "HOST_IP=100.97.56.52"
set "HOST_NAME=Hemz"

:: Check if local connection.json overrides host IP
if exist "%~dp0Config\connection.json" (
    for /f "usebackq tokens=2 delims=:, " %%a in (`findstr /i "serverTailscaleIp" "%~dp0Config\connection.json" 2^>nul`) do (
        set "CLEAN_IP=%%~a"
        if not "!CLEAN_IP!"=="" set "HOST_IP=!CLEAN_IP!"
    )
)

set "TS_DIR=C:\Program Files\Tailscale"
set "TS_EXE=%TS_DIR%\tailscale.exe"
set "TS_IPN=%TS_DIR%\tailscale-ipn.exe"

cls
echo ======================================================================
echo          FRIEND QUICK JOIN - CONNECT TO %HOST_NAME%'S SERVER
echo ======================================================================
echo This tool ensures Tailscale is installed, verifies your connection
echo to %HOST_NAME%'s PC (%HOST_IP%), and copies the server join address
echo directly to your clipboard!
echo ======================================================================
echo.

:: ----------------------------------------------------------------------
:: 1. CHECK TAILSCALE INSTALLATION
:: ----------------------------------------------------------------------
echo [1/4] Checking Tailscale installation...
where tailscale.exe >nul 2>&1
if %errorlevel% neq 0 (
    if not exist "%TS_EXE%" (
        echo   [!] Tailscale is not installed on this PC.
        echo   [+] Downloading official Tailscale installer...
        powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe', '$env:TEMP\tailscale-setup-latest.exe')"
        if exist "%TEMP%\tailscale-setup-latest.exe" (
            echo   [*] Launching Tailscale installer (Please accept Administrator prompt)...
            powershell -NoProfile -Command "Start-Process '%TEMP%\tailscale-setup-latest.exe' -Wait"
        ) else (
            echo   [ERROR] Failed to download Tailscale installer.
            echo   Please download and install Tailscale manually from: https://tailscale.com/download
            pause
            exit /b 1
        )
    )
)

:: Re-resolve executable after installation
where tailscale.exe >nul 2>&1
if %errorlevel% equ 0 (
    set "RUN_TS=tailscale.exe"
) else (
    set "RUN_TS=%TS_EXE%"
)

:: ----------------------------------------------------------------------
:: 2. VERIFY TAILSCALE SERVICE & TRAY
:: ----------------------------------------------------------------------
echo.
echo [2/4] Verifying Tailscale background service...
sc query Tailscale 2>nul | findstr /i "RUNNING" >nul
if %errorlevel% neq 0 (
    echo   [!] Starting Tailscale Windows service...
    net start Tailscale >nul 2>&1
    if %errorlevel% neq 0 (
        powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/c net start Tailscale' -Verb RunAs -Wait"
    )
) else (
    echo   [OK] Tailscale service is running.
)

tasklist /FI "IMAGENAME eq tailscale-ipn.exe" 2>nul | findstr /i "tailscale-ipn.exe" >nul
if %errorlevel% neq 0 (
    if exist "%TS_IPN%" (
        start "" "%TS_IPN%"
    )
)

:: ----------------------------------------------------------------------
:: 3. VERIFY LOGIN / MACHINE SHARE STATUS
:: ----------------------------------------------------------------------
echo.
echo [3/4] Verifying connection to Tailscale network...
"%RUN_TS%" status 2>&1 | findstr /i "Logged out NeedsLogin Stopped" >nul
if %errorlevel% equ 0 (
    echo.
    echo   ==================================================================
    echo   ACTION REQUIRED: Tailscale login or machine-share acceptance needed!
    echo   1. Opening Tailscale login prompt...
    echo   2. Sign in with your Google, Microsoft, Apple, or GitHub account.
    echo   3. If %HOST_NAME% gave you a Machine Share link, accept it in browser!
    echo   ==================================================================
    echo.
    start "" "%RUN_TS%" up
    echo Press any key once you have signed into Tailscale in your browser...
    pause >nul
)

for /f "usebackq tokens=*" %%a in (`"%RUN_TS%" ip -4 2^>nul`) do set "MY_TS_IP=%%a"
echo   [OK] Your Tailscale IP: %MY_TS_IP%

:: ----------------------------------------------------------------------
:: 4. PING HOST SERVER PC
:: ----------------------------------------------------------------------
echo.
echo [4/4] Testing connection to %HOST_NAME%'s Server (%HOST_IP%)...
"%RUN_TS%" ping -c 2 "%HOST_IP%"

echo.
timeout /t 1 >nul

:: ----------------------------------------------------------------------
:: SELECT GAME & GET JOIN ADDRESS
:: ----------------------------------------------------------------------
:SELECT_GAME
cls
echo ======================================================================
echo              WHICH GAME ARE YOU JOINING %HOST_NAME% ON?
echo ======================================================================
echo   Host Tailscale IP : %HOST_IP%
echo ----------------------------------------------------------------------
echo   [1] Palworld Dedicated Server   (Port 8211)
echo   [2] Minecraft: Java Edition     (Port 25565)
echo   [3] Custom Port (Enter port given by %HOST_NAME%)
echo   [0] Exit
echo ======================================================================
set "GOPT="
set /p "GOPT=Choose game [1-3, 0]: "

if "%GOPT%"=="1" (
    set "G_NAME=Palworld"
    set "G_PORT=8211"
    set "G_HINT=Join Multiplayer Game -> Bottom IP address bar -> Paste (Ctrl+V) -> Connect"
    goto DONE_COPY
)
if "%GOPT%"=="2" (
    set "G_NAME=Minecraft Java"
    set "G_PORT=25565"
    set "G_HINT=Multiplayer -> Direct Connection (or Add Server) -> Paste (Ctrl+V) -> Join Server"
    goto DONE_COPY
)
if "%GOPT%"=="3" (
    set "G_NAME=Custom Game"
    set /p "G_PORT=Enter the port number given by %HOST_NAME%: "
    set "G_HINT=Paste address into the game's direct connect / multiplayer server menu"
    goto DONE_COPY
)
if "%GOPT%"=="0" exit /b 0

echo Invalid selection.
timeout /t 1 >nul
goto SELECT_GAME

:DONE_COPY
set "FULL_ADDR=%HOST_IP%:%G_PORT%"
powershell -NoProfile -Command "Set-Clipboard -Value '%FULL_ADDR%'"

cls
echo ======================================================================
echo                      SUCCESSFULLY CONNECTED!
echo ======================================================================
echo.
echo   Game             : %G_NAME%
echo   Server Address   : %FULL_ADDR%
echo.
echo   [!] COPIED TO CLIPBOARD: '%FULL_ADDR%'
echo.
echo   HOW TO JOIN IN-GAME:
echo     %G_HINT%
echo.
echo ======================================================================
echo   You are now connected privately to %HOST_NAME%'s server via Tailscale!
echo   Simply open your game and press Ctrl+V to paste the server address.
echo ======================================================================
echo.
echo Press any key to exit...
pause >nul
exit /b 0
