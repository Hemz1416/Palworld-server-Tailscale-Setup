# 🔒 Security & Architecture Policy

This document outlines the security architecture, access controls, and network constraints implemented in **Tailscale Setup — Universal Dedicated Game Server Hub**.

---

## 🛡️ Core Security Principles

### 1. Tailscale Machine-Share Model (Node-Level Isolation)
* **No General Tailnet Access**: Friends are **never** granted access to your entire personal tailnet.
* **Isolated Node Access**: The setup uses Tailscale's "Share machine" mechanism. The friend's Tailscale account is only granted access to the specific dedicated server host machine (`hemz`).
* **Unrelated Devices Protected**: All other devices on your tailnet (personal laptops, PCs, NAS storage, phones, smart home devices) remain completely invisible and unreachable to the friend.

### 2. Single-Use Invitation Link Protection
* **Sensitive Links**: Machine-share invitation links are single-use and intended solely for the specific friend.
* **Expiration**: Unused invitations expire automatically.
* **Strict Privacy / Zero Logging**:
  * Invitation URLs are never written to disk logs.
  * URLs are scrubbed with regex masking (`[REDACTED_INVITATION_URL]`) in all logs.
  * Invitation URLs are never exposed in UI diagnostic screens or command-line outputs.
* **Standard Tailscale Authentication**: Once the friend accepts the invitation, normal Tailscale node-to-node cryptographic authentication is maintained by the Tailscale WireGuard daemon.

### 3. Server Password Handling
* **Zero Password Logging**: Game server passwords are never written to disk logs or diagnostic traces.
* **Embedded Password Warning**:
  > **SECURITY NOTICE**: Anyone possessing a compiled executable may potentially recover an embedded server password.
  * Server owners may choose to leave the password field blank in configuration and deliver the password via secure personal messaging (Discord, WhatsApp).
* **Explicit User Clipboard Control**: The app provides a dedicated **[ COPY SERVER PASSWORD ]** button so that the user's clipboard is never silently overwritten.

### 4. Zero Credential / Token Embedding
* **No Hardcoded Tailscale Auth Keys**: The application **NEVER** packages reusable Tailscale auth keys (`tskey-auth-...`), API keys, OAuth client secrets, or administrative credentials.
* **No Session Hijacking**: Tailscale session cookies and tokens are not extracted or manipulated.
* **Interactive Player Authentication**: The friend signs in interactively via their own browser using their preferred identity provider (Google, Microsoft, Apple, GitHub).

### 5. Network Integrity (No Port Forwarding / No UPnP)
* **No Open Router Ports**: No router port forwarding is required. Traditional dedicated servers require exposing ports (e.g., TCP 25565, UDP 8211) to the global internet, exposing the host to vulnerability scanners and denial-of-service attacks.
* **No UPnP**: Universal Plug and Play is never enabled or queried on your router.
* **Encrypted WireGuard Mesh**: All gameplay traffic travels over Tailscale's end-to-end encrypted WireGuard tunnels.

### 6. Host-Only Unattended Mode
* Unattended mode (`tailscale set --unattended`) is strictly restricted to `Host-Setup.ps1` on the **Host PC**.
* It is **never** offered or enabled on the friend's computer.

### 7. Non-Intrusive Game Operation
* The tools do not alter, patch, emulate, or bypass game executables, Steam DRM, or Steam authentication.
* Only official game clients, server binaries, and official Tailscale components are utilized.
