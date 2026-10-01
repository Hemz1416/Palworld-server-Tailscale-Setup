# 🔒 Tailscale Machine Share Architecture Guide

This guide explains how **Tailscale Machine Sharing** works, why it is the optimal architecture for hosting game servers for friends, and how to create single-use machine share links.

---

## 🌐 The Two Tailscale Invite Models

When inviting friends to connect to your PC, Tailscale offers two models:

```
MODEL 1: Tailnet Member (Full Network Access)
Your Tailnet ───► NAS ───► Family PCs ───► Game Server
   ▲
   └── [Friend has access to entire tailnet or needs complex ACLs]

MODEL 2: Machine Share (Node-Level Isolation) - RECOMMENDED!
Host PC ('Hemz' Game Server)
   │ (Single-Device Machine Share)
   ▼
Friend's Personal Tailscale Account
   │
   └── [Friend can ONLY connect to Host PC, nothing else on your network]
```

### Why Machine Share is Superior for Gaming
1. **Zero Exposure of Home Network**: The friend is granted network visibility *only* to your host PC node. Your home router, family laptops, printer, and NAS remain completely invisible and unreachable.
2. **Independent Accounts**: Your friend creates or uses their own personal Tailscale account (with their own Google/Microsoft/Apple/GitHub login). You do not share passwords.
3. **Revocable Anytime**: You can revoke access for any friend in 1 click from your Tailscale Admin Console.
4. **No Router Port Forwarding**: Traffic is encrypted point-to-point via WireGuard. No risky open ports on your public ISP router.

---

## 🛠️ How the Host (Hemz) Creates a Machine Share Link

1. Go to the **Tailscale Admin Console**:
   👉 [https://login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines)
2. Locate your PC in the Machines list (e.g. `hemz`).
3. Click the **three dots menu (`...`)** on the right side of your machine row.
4. Click **Share...**.
5. Select **"Generate a share link"**.
6. Copy the generated HTTPS link (e.g. `https://login.tailscale.com/a/...`) and send it to your friend on Discord or WhatsApp.

> [!NOTE]
> Tailscale share links are single-use and expire after a period if unused. Once your friend accepts the link in their browser, the machine share remains active permanently until you revoke it.

---

## ⚡ NAT Traversal & Connection Types

Tailscale uses intelligent NAT traversal to connect you and your friend:

| Connection Mode | Description | Gaming Latency |
| :--- | :--- | :--- |
| **Direct Peer-to-Peer** | Tailscale negotiates direct UDP WireGuard tunnels through your home routers using STUN. | **Lowest possible ping** (identical to LAN/direct connection). |
| **DERP Relay** | If both routers use strict symmetric NAT or cellular carrier-grade NAT (CGNAT) that blocks direct UDP, traffic is securely relayed via Tailscale's encrypted DERP relays. | Adds ~10-40ms relay latency, but guarantees 100% connectivity where Hamachi fails! |

You can check connection mode in `Host-Dashboard.bat` or by typing:
```cmd
tailscale ping <FRIEND_IP>
```
