← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Remote Access

## 1.1 Remote Access Overview

| Service / Area                         | Tools / Software                                         |
|----------------------------------------|----------------------------------------------------------|
| [1.2 RDP](#rdp)                        | Guacamole                                                |
| [1.3 SSH](#ssh)                        | Termius, Teleport                                        |
| [1.4 VPN](#vpn)                        | Wireguard, OpenVPN, Cloudflare Tunnel                    |
| [1.5 Zero Trust Remote Access](#zerotrust) | Cloudflare Tunnel                                    |

---
<a name="rdp"></a>

## 1.2 RDP 

- **Why Guacamole:**
  - Conveniently access multiple machines directly from a browser.
  - Superior to Proxmox's built-in console as it **supports audio passthrough**.
  - Centralized access to **any RDP-enabled machine** with a single click.
  - **Reliable clipboard sync**: Fixed the inconsistent clipboard issues often experienced with Proxmox.

---

<a name="ssh"></a>

## 1.3 SSH 

### 1.3.1 SSH - Linux Configuration

- **Timeout Configuration**: Automatic termination of inactive SSH sessions.
- **Disable Root Login**: Prevented direct root access for enhanced security.
- **Password Authentication Disabled**: Passwords are blocked in favor of keys.
- **Key-based Authentication**: Minimal attack surface using strong cryptographic keys.
  - SSH keys configured.
  - Passphrase (passkey) used for added security.

---

### 1.3.2 SSH - Why Termius

- Manage multiple servers from one place using **profiles and groups**.
- Built-in **SSH key management**: Easy importing and deployment of keys.
- Convenient **multiplatform** support: Windows, Linux, macOS, and Mobile.
- Encrypted configurations that are easily **synchronized across devices**.

---

<a name="vpn"></a>

## 1.4 Using VPN in the Homelab

- I use **OpenVPN** and **WireGuard**, but I have also tested **Tailscale** and **NordVPN Meshnet** solutions.
- **Public Services**: Directly accessible from the internet (via Reverse Proxy) without a VPN.
- **Internal Services**: Accessible **exclusively via VPN**, ensuring the protection of management interfaces.
- **Full Tunnel**: Enabled on mobile devices to route all traffic through the home network, allowing me to use **Pi-hole / AdGuard Home** ad-blocking on the go.

---
<a name="zerotrust"></a>

## 1.5 Zero Trust Remote Access (Cloudflare Tunnel)

Unlike traditional VPNs, Cloudflare Tunnel establishes an outbound-only connection between the homelab and the Cloudflare network.

- **No Port Forwarding Required:** No need to open OpenVPN or WireGuard ports on the router. This completely hides my public IP address from direct internet scans and attacks.
- **Security Layers:** I can enable **Cloudflare Access** in front of the tunnel to require extra authentication (e.g., Google OAuth, GitHub login, or Authentik) before a request even reaches my internal server.
- **WAF (Web Application Firewall):** Automatic protection against bots and common web attacks like SQL injection and XSS.
- **Simplified Management:** The `cloudflared` agent runs as a lightweight Docker container and is centrally configured via the Cloudflare Zero Trust dashboard.

---

← [Back to Homelab Main Page](../README.md)