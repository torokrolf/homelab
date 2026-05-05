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
  - Convenient access to multiple machines directly from the browser.
  - Superior to Proxmox's built-in RDP as it supports **audio passthrough** when needed.
  - Centralized access to **any machine via RDP** with a single click.
  - **Clipboard sync issues** experienced with Proxmox are resolved; Guacamole provides stable performance.

---

<a name="ssh"></a>

## 1.3 SSH 

### 1.3.1 SSH - Linux Configuration (Automated Hardening)

In my lab, SSH settings are automated via **Ansible**[cite: 1] to ensure every new machine meets modern security standards. The hardening process implements the following technical steps:

*   **Disable Root Login**: Prevents direct root access using the `PermitRootLogin no` setting[cite: 1].
*   **Disable Password Authentication**: Only key-based authentication is permitted (`PasswordAuthentication no`), protecting the system against brute-force attacks[cite: 1].
*   **Automated Session Timeout**: Inactive sessions are automatically terminated after 15 minutes via `export TMOUT=900`[cite: 1].
*   **Legal Banner**: The content of `/etc/issue.net` is displayed upon login to warn about activity logging[cite: 1].
*   **Anti-Lock Protection**: The playbook automatically terminates background update processes and clears lock files to ensure automation never stalls[cite: 1].

> **[➔ Click here to view the complete Ansible Hardening Playbook](../06-Automation/Ansible_Semaphore/Playbooks/complete_setup.yaml)**

---

### 1.3.2 SSH - Why Termius

- Manage multiple machines simultaneously from a single interface using **profiles and groups**.
- Built-in **SSH key management**: simplified importing and deployment of keys.
- Convenient **multiplatform** support: Windows, Linux, macOS, and mobile.
- Encrypted configurations with easy **synchronization across devices**.

---

<a name="vpn"></a>

## 1.4 VPN Usage in the Homelab

- I utilize **OpenVPN** and **WireGuard**, having also tested **Tailscale** and **NordVPN Meshnet** solutions.
- **Public Services**: Accessible directly from the internet via Reverse Proxy without a VPN.
- **Internal Services**: Accessible **exclusively via VPN**, ensuring the protection of management interfaces.
- **Full Tunnel**: Enabled on mobile devices to route all traffic through the home network, allowing remote access to **Pi-hole / AdGuard Home** ad-blocking.

---
<a name="zerotrust"></a>

## 1.5 Zero Trust Remote Access 

Unlike traditional VPNs, a Cloudflare Tunnel establishes only an outbound connection between the homelab and the Cloudflare network.

- **No Port Forwarding:** There is no need to open OpenVPN or WireGuard ports on the router. This completely hides my public IP address from direct attacks.
- **Security Layers:** **Cloudflare Access** can be enabled in front of the tunnel, requiring extra authentication (e.g., Google OAuth, GitHub login, or Authentik) before a request even reaches my internal server.
- **WAF (Web Application Firewall):** Automatic protection against bots and common web attacks like SQL injection and XSS.
- **Simple Management:** `cloudflared` runs as a single lightweight container in Docker and is centrally configured via the Cloudflare Zero Trust dashboard.

---

← [Back to Homelab Main Page](../README.md)