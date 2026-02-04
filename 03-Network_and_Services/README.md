← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Network and Services

---

## 1.1 Network and Services Overview

| Service / Area                         | Tools / Software                                         |
|----------------------------------------|----------------------------------------------------------|
| [1.2 Firewall / Router](#pfsense)      | pfSense                                                  |
| [1.3 VPN](#vpn)                        | Tailscale, WireGuard, OpenVPN, NordVPN                   |
| [1.4 APT cache proxy](#apt)            | APT-Cache-NG                                             |
| [1.5 VLAN](#vlan)                      | TP-LINK SG108E switch                                    |
| [1.6 Reverse Proxy](#reverseproxy)     | Nginx Proxy Manager (replaced), Traefik (current)        |
| [1.7 Radius / LDAP](#radiusldap)       | FreeRADIUS, FreeIPA                                      |
| [1.8 Ad blocking](#reklamszures)       | Pi-hole                                                  |
| [1.9 PXE Boot](#pxe)                   | iVentoy                                                  |
| [1.10 DNS](#dns)                       | BIND9, Namecheap, Cloudflare, Windows Server 2019 DNS    |
| [1.11 Network troubleshooting](#debug) | Wireshark                                                |
| [1.12 DHCP](#dhcp2)                    | ISC-KEA, Windows Server 2019 DHCP                        |
| [1.13 Notification](#notification)     | Gotify                                                   |

---

<a name="pfsense"></a>
## 1.2 pfSense

In my homelab, I utilize a **pfSense-based firewall and router** to manage all traffic.

### 1.2.1 NAT & Routing
- **Outbound NAT** configuration for internal networks.
- **Port Forward NAT** for exposing external services securely.
- **Inter-VLAN routing** to manage traffic between isolated internal networks.

<a name="dhcp"></a>
### 1.2.2 DHCP Server Configuration
- **IP Range Management**: Granular control over pool assignments.
- **Static DHCP Leases**: Dedicated IPs for core infrastructure.
- **Gateway & DNS Distribution**: Automated client configuration.
- **Static ARP entries**: Servers and clients on the `2.0` network use static IP–MAC bindings, providing protection against **ARP spoofing**.
- **Management Access**: The switch uses a manually assigned static IP to ensure the management interface is reachable even if the DHCP service is down.

### 1.2.3 NTP Server <a name="ntp"></a>
- Centralized time synchronization for all internal clients.
- Clients utilize **chronyd** for precision.
- pfSense acts as the primary NTP source for all LXCs and VMs (except for the FreeIPA LXC).

### 1.2.4 WireGuard VPN
- High-performance, modern VPN solution.
- Provides secure, low-latency remote access to the internal network.

### 1.2.5 OpenVPN
- Certificate-based authentication for enterprise-grade security.
- Broad compatibility across various client devices.
- Custom firewall rules and specific routing logic per VPN tunnel.

### 1.2.6 Dynamic DNS (DDNS)
- Automated handling of dynamic public IP changes via Cloudflare API.
- Ensures the **VPN remains reachable from the internet** regardless of ISP IP rotations.

---

<a name="vpn"></a>
## 1.3 VPN Strategy

- I utilize **OpenVPN** and **WireGuard**, and have successfully tested **Tailscale** and **NordVPN Meshnet**.
- **Public Services**: Directly accessible via Reverse Proxy without VPN requirements.
- **Internal Services**: Accessible **strictly through VPN**, enforcing zero-trust access for sensitive management UIs.
- **Full Tunneling**: When enabled on mobile, all traffic is routed through the home network, utilizing **AdGuard Home / Pi-hole** for global ad-blocking on the go.

---

<a name="apt"></a>
## 1.4 APT Cache NG

### 1.4.1 Why I Use It

- Optimized for **Ansible-scheduled updates** (standardized at 3 AM).
- Prevents redundant package downloads, significantly reducing external bandwidth usage.
- **Efficiency**: If one machine downloads an update, others retrieve it at LAN speeds from the cache.

On peak days, the cache hit ratio reached **88.26%** (30 MB served locally out of 34 MB total). Even during large updates, it consistently saves gigabytes of external traffic by serving repetitive packages from local storage.

<div align="center">
  <img src="https://github.com/user-attachments/assets/d2e4134c-879c-4b88-b3f6-ccb0553a6d9f" width="800" alt="APT Cache Statistics">
</div>

---

<a name="vlan"></a>
## 1.5 VLAN and Network Segmentation

- **Proxmox Integration**: VLAN-aware bridges (`vmbr0`) and tagged interfaces (e.g., `.30`).
- **Network Isolation**: Dedicated subnet (192.168.3.0/24) for testing or isolated services.
- **Hardware Support**: VLAN trunking configured on the TP-Link SG108E switch.
- **pfSense Logic**: DHCP and firewall rules applied per VLAN interface to restrict lateral movement.

---

<a name="reverseproxy"></a>
## 1.6 Reverse Proxy

Centralized **SSL/TLS certificate management** and traffic routing.

### 1.6.1 DNS-Based Configuration

I exclusively use DNS names in proxy configurations—never static IPs.
- **Benefit**: Changing a VM's IP does not break the proxy; only the internal DNS record needs updating.
- **Readability**: Config files are human-readable (e.g., `srv-web.otthoni.local` instead of `192.168.2.50`).

### 1.6.2 SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard

- **Security**: Full HTTPS encryption via Let’s Encrypt.
- **Challenge Type**: DNS-01 validation via Cloudflare API.
- **Advantage**: Allows for wildcard certificates (e.g., `*.trkrolf.com`) without exposing internal ports for HTTP-01 validation.

---

<a name="radiusldap"></a>
## 1.7 RADIUS & LDAP

### 1.7.1 FreeIPA (LDAP)
- Centralized user, group, and permission management across the lab.
- Standardized Sudo rule deployment.

### 1.7.2 FreeRADIUS
- **pfSense Authentication**: Centralized GUI login via RADIUS.
- **Management**: Integrated with SQL and PhpMyAdmin for easy user database handling.
- **Redundancy**: Configured with local user fallback to prevent lockout.

---

<a name="reklamszures"></a>
## 1.8 Ad Blocking – Pi-hole

- DNS-level network-wide ad and tracker blocking.
- Integrated with WireGuard VPN for mobile protection.
- Upstream resolution handled by local **BIND9** for increased privacy and local record handling.

---

<a name="pxe"></a>
## 1.9 PXE Boot – iVentoy

- Seamless network booting for ISOs (Clonezilla, Windows, Ubuntu installers).
- Eliminates the need for physical USB drives; images are served directly over the network.

---

<a name="dns"></a>
## 1.10 DNS Architecture

### Public Infrastructure
- Domain managed via **Namecheap** with **Cloudflare** as the active DNS provider for API-based updates.

### Private Infrastructure (BIND9)
- Local zone: `otthoni.local`.
- **DNS Override**: Internal resolution of `trkrolf.com` records to point directly to local IPs, bypassing the external Cloudflare lookup when inside the network.

---

<a name="debug"></a>
## 1.11 Network Troubleshooting – Wireshark

Used for deep-packet inspection to analyze:
- DNS/DHCP handshakes and ARP resolution.
- TCP/IP performance and connection verification.

---

<a name="dhcp2"></a>
## 1.12 DHCP

Detailed configuration is covered in the [pfSense DHCP section](#dhcp).

---

<a name="notification"></a>
## 1.13 Notification

### 1.13.1 Gotify

**Gotify** is a lightweight, self-hosted server for sending and receiving push notifications in real-time. It allows me to stay informed about errors and system states instantly.

**Advantages:**
- **Self-hosted:** Full control over data; no dependency on third-party services.
- **Simple API:** Easily integrated with scripts and **webhooks**.
- **Real-time Notifications:** Immediate push notifications to mobile devices.

**Use Cases in My Lab:**
- **Proxmox Storage Monitoring:** Alerts if Proxmox loses its TrueNAS mount points. ❗ Script: [/11-Scripts/proxmox/mount-monitor](/11-Scripts/proxmox/mount-monitor)
- **Proxmox System Alerts:** Notifications for warnings and errors, such as low disk space (configured in Proxmox GUI).
- **Drive Health:** Alerts on S.M.A.R.T. errors. ❗ Script: [/11-Scripts/proxmox/S.M.A.R.T.](/11-Scripts/proxmox/S.M.A.R.T.)
- **Media Automation:** Radarr and Sonarr send notifications once a movie or TV show has finished downloading (configured via native GUI).
- **Automation Results:** My Ansible update playbook sends a status report (success/failure) after updating clients. ❗ Script: [/06-Automation/Ansible_Semaphore/Playbooks/upgrade-system.yaml](/06-Automation/Ansible_Semaphore/Playbooks/upgrade-system.yaml)
- **Backups:** Notifications regarding Proxmox Backup Server (PBS) backup task results and verification status (configured via PBS GUI).

---

← [Back to Homelab Home](../README.md)
