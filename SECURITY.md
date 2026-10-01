# 🔒 Security & Architecture Policy

This document outlines the security architecture, access controls, and network constraints implemented in **Tailscale Setup — Palworld & Minecraft Java Server Hub**.

---

## 🛡️ Core Security Principles

### 1. Tailscale Machine-Share Model & ACL Grants (Node & Port Level Isolation)
* **No General Tailnet Access**: Friends are **never** granted access to your entire personal tailnet.
* **Isolated Node Access**: The setup uses Tailscale's "Share machine" mechanism. The friend's Tailscale account is only granted access to the specific dedicated server host machine (`hemz`).
* **Port-Level ACL Restrictions**: In Tailscale Access Controls (see [TAILSCALE-ACL-POLICY.json](file:///TAILSCALE-ACL-POLICY.json)), `autogroup:shared` is strictly constrained to `tcp:25565` and `udp:8211`. All other ports (RDP 3389, SMB 445, RCON 25575, SSH 22) are blocked at the Tailscale network layer before packets ever reach your OS.
* **Unrelated Devices Protected**: All other devices on your tailnet (personal laptops, PCs, NAS storage, phones, smart home devices) remain completely invisible and unreachable to the friend.

### 2. Windows Defender Firewall Subnet Isolation
* Inbound rules configured by `Setup-Firewall-Rule.bat` and `Host-Dashboard.bat` are strictly scoped to the Tailscale subnet (`remoteip=100.64.0.0/10`).
* No ports are opened to the public internet or your local Wi-Fi router LAN (`192.168.x.x`).

### 3. Minecraft Dedicated Server Hardening (Offline Mode & Whitelisting)
* When running Minecraft with `online-mode=false` (to allow offline/unauthenticated clients), the server does not verify usernames with Mojang authentication servers. This means any connecting player could theoretically choose an administrator's username.
* **Mitigations**:
  * **Whitelist**: Set `white-list=true` and `enforce-whitelist=true` in `server.properties` and add allowed player gamertags to `whitelist.json`.
  * **RCON Isolation**: RCON (`port 25575`) is **never** opened in the Windows Firewall rules, keeping remote console management strictly local (`127.0.0.1`).

### 4. Single-Use Invitation Link Protection
* **Sensitive Links**: Machine-share invitation links are intended solely for authorized friends.
* **Expiration**: Reusable links expire after 30 days if unused; single-use links expire upon initial acceptance.
* **Strict Privacy / Zero Logging**:
  * Invitation URLs are never written to disk logs.
  * URLs are scrubbed with regex masking (`[REDACTED_INVITATION_URL]`) in all logs.
  * Invitation URLs are never exposed in UI diagnostic screens or command-line outputs.
* **Standard Tailscale Authentication**: Once the friend accepts the invitation, normal Tailscale node-to-node cryptographic authentication is maintained by the Tailscale WireGuard daemon.

### 5. Server Password Handling
* **Zero Password Logging**: Game server passwords are never written to disk logs or diagnostic traces.
* **Embedded Password Warning**:
  > **SECURITY NOTICE**: Anyone possessing a compiled executable may potentially recover an embedded server password.
  * Server owners may choose to leave the password field blank in configuration and deliver the password via secure personal messaging (Discord, WhatsApp).
* **Explicit User Clipboard Control**: The app provides a dedicated **[ COPY SERVER PASSWORD ]** button so that the user's clipboard is never silently overwritten.

### 6. Zero Credential / Token Embedding
* **No Hardcoded Tailscale Auth Keys**: The application **NEVER** packages reusable Tailscale auth keys (`tskey-auth-...`), API keys, OAuth client secrets, or administrative credentials.
* **No Session Hijacking**: Tailscale session cookies and tokens are not extracted or manipulated.
* **Interactive Player Authentication**: The friend signs in interactively via their own browser using their preferred identity provider (Google, Microsoft, Apple, GitHub).

### 7. Network Integrity (No Port Forwarding / No UPnP)
* **No Open Router Ports**: No router port forwarding is required. Traditional dedicated servers require exposing ports (TCP 25565, UDP 8211) to the global internet, exposing the host to vulnerability scanners and denial-of-service attacks.
* **No UPnP**: Universal Plug and Play is never enabled or queried on your router.
* **Encrypted WireGuard Mesh**: All gameplay traffic travels over Tailscale's end-to-end encrypted WireGuard tunnels.

### 8. Host-Only Unattended Mode
* Unattended mode (`tailscale set --unattended`) is strictly restricted to `Host-Setup.ps1` on the **Host PC**.
* It is **never** offered or enabled on the friend's computer.

### 9. Non-Intrusive Game Operation
* The tools do not alter, patch, emulate, or bypass game executables, Steam DRM, or Steam authentication.
* Only official game clients, server binaries, and official Tailscale components are utilized.
