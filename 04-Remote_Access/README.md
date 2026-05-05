← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Remote Access

## 1.1 Remote Access Overview

| Service / Area                         | Tools / Software                                         |
|----------------------------------------|----------------------------------------------------------|
| [1.2 RDP](#rdp)                        | Guacamole                                                |
| [1.3 SSH](#ssh)                        | Termius, Teleport                                        |
| [1.4 VPN](#vpn)                        | Wireguard, OpenVPN                                       |
| [1.5 Zero Trust Remote Access](#zerotrust) | Cloudflare Tunnel                                    |

---
<a name="rdp"></a>

## 1.2 RDP 

- **Why Guacamole:**
  - Conveniently access multiple machines directly from your browser.
  - Superior to Proxmox's built-in RDP as it supports **audio passthrough**.
  - Centralized dashboard to access **any machine via RDP** with a single click.
  - Stable performance; resolves the **clipboard sync issues** often found in Proxmox.

---

<a name="ssh"></a>

## 1.3 SSH 

### 1.3.1 SSH - Linux Configuration & Automated Hardening

In my lab, SSH security is strictly enforced and automated via **Ansible**[cite: 1]. The following hardening measures ensure a secure baseline across all nodes:

*   **Disable Root Login**: Direct root access is blocked via `PermitRootLogin no`, requiring the use of a standard user with sudo privileges[cite: 1].
*   **Key-Based Authentication Only**: Password login is fully disabled (`PasswordAuthentication no`) to eliminate the risk of brute-force attacks[cite: 1].
*   **SSH Key Management**: Access is granted exclusively through secure SSH keys (without passphrases for automation compatibility), managed centrally[cite: 1].
*   **Automatic Session Timeout**: Inactive connections are automatically terminated after 15 minutes (900 seconds) via the `TMOUT` variable in `/etc/profile`[cite: 1].
*   **Legal Warning Banner**: A custom warning from `/etc/issue.net` is displayed upon login to notify users that all activity is logged[cite: 1].

---

### 1.3.2 SSH - Why Termius

- **Centralized Management**: Manage all nodes from a single interface with organized profiles and groups.
- **SSH Key Management**: Built-in secure vault for easy key importing and deployment.
- **Multiplatform**: Seamlessly sync encrypted configurations across Windows, Linux, macOS, and mobile devices.

---

<a name="vpn"></a>

## 1.4 VPN Usage in the Homelab

- I utilize **OpenVPN** and **WireGuard**, having also tested **Tailscale** and **NordVPN Meshnet**.
- **Public Services**: Accessible directly via Reverse Proxy without a VPN.
- **Internal Services**: Accessible **exclusively via VPN**, ensuring management interfaces remain hidden.
- **Full Tunnel**: Enabled on mobile to route all traffic through the home network, providing remote access to **Pi-hole / AdGuard Home** ad-blocking.

---
<a name="zerotrust"></a>

## 1.5 Zero Trust Remote Access 

Unlike traditional VPNs, a Cloudflare Tunnel establishes only an outbound connection between the homelab and the Cloudflare network.

- **No Port Forwarding:** Eliminates the need to open ports on the router, hiding my public IP from direct attacks.
- **Security Layers:** **Cloudflare Access** adds an extra layer of authentication (e.g., Google OAuth, GitHub, or Authentik) before reaching the server.
- **WAF (Web Application Firewall):** Provides automated protection against bots and common attacks like SQL injection or XSS.
- **Lightweight Management:** Runs as a single `cloudflared` container, managed centrally via the Cloudflare Zero Trust dashboard.

---

← [Back to Homelab Main Page](../README.md)