# 🔒 Tailscale Machine Share & ACL Hardening Guide

This guide explains how **Tailscale Machine Sharing** works, why it is the optimal architecture for hosting game servers for friends, how to generate share links, and how to restrict shared friends strictly to game ports using **Tailscale ACL Grants**.

---

## 🌐 The Two Tailscale Invite Models

```
MODEL 1: Tailnet Member (Full Network Access - NOT Recommended for Casual Friends)
Your Tailnet ───► NAS ───► Personal PCs ───► Game Server
   ▲
   └── [Friend gains visibility to other devices unless manually blocked by complex ACLs]

MODEL 2: Machine Share (Node-Level Isolation - RECOMMENDED!)
Host PC ('Hemz' Game Server)
   │ (Single-Device Machine Share)
   ▼
Friend's Personal Tailscale Account
   │
   └── [Friend can ONLY reach the Game Server PC, never other devices on your network]
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
5. Choose your link type:
   - **Reusable Share Link**: Supports multiple friends using the same link. Reusable links expire after **30 days** if unused.
   - **Single-Use Share Link**: For one specific friend.
6. Copy the generated HTTPS link (e.g. `https://login.tailscale.com/a/...`) and send it to your friend on Discord or WhatsApp.

---

## 🛡️ Port-Level Security: Tailscale ACL Grants for `autogroup:shared`

By default, sharing a machine grants network reachability to that machine, but Tailscale recommends **restricting shared users strictly to authorized game ports**.

Without this rule, a shared user might probe non-game services running on your Windows machine (like Windows File Sharing SMB port 445, Remote Desktop port 3389, or Minecraft RCON port 25575).

### How to Apply the Port Restriction:
1. Open the **Tailscale Access Controls (ACLs) Editor**:
   👉 [https://login.tailscale.com/admin/acls](https://login.tailscale.com/admin/acls)
2. Add a rule for `autogroup:shared` allowing **ONLY** Minecraft Java (`tcp:25565`) and Palworld (`udp:8211`):

```json
{
  "hosts": {
    "game-server": "100.97.56.52"
  },
  "acls": [
    // Restrict all shared friends strictly to Palworld & Minecraft Java:
    {
      "action": "accept",
      "src": ["autogroup:shared"],
      "dst": [
        "game-server:25565",
        "game-server:8211"
      ]
    },
    // Keep full access for your own tailnet devices:
    {
      "action": "accept",
      "src": ["autogroup:member"],
      "dst": ["*:*"]
    }
  ],
  "grants": [
    {
      "src": ["autogroup:shared"],
      "dst": ["game-server"],
      "app": {
        "tailscale.com/cap/connect": [
          {
            "ports": ["tcp:25565", "udp:8211"]
          }
        ]
      }
    }
  ]
}
```

3. Save the ACL file.
4. Now, even if a friend is connected to your machine via Tailscale, they can **only communicate on ports 25565 (TCP) and 8211 (UDP)**. All other ports on your PC are cryptographically blocked by Tailscale before reaching your operating system!

---

## ⚡ NAT Traversal & Connection Types

| Connection Mode | Description | Gaming Latency |
| :--- | :--- | :--- |
| **Direct Peer-to-Peer** | Tailscale negotiates direct UDP WireGuard tunnels through your home routers using STUN. | **Lowest possible ping** (identical to LAN/direct connection). |
| **DERP Relay** | If both routers use strict symmetric NAT or cellular carrier-grade NAT (CGNAT) that blocks direct UDP, traffic is securely relayed via Tailscale's encrypted DERP relays. | Adds ~10-40ms relay latency, but guarantees 100% connectivity where Hamachi fails! |
