← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Network and Services

---

## 1.1 Network and Services Overview

| Service / Area            | Tools / Software |
|---------------------------|------------------|
| **Firewall / Router**     | pfSense |
| **VLAN**                  | TP-LINK SG108E switch |
| **DHCP**                  | ISC-KEA, Windows Server 2019 DHCP Server |
| **DNS**                   | BIND9 + Namecheap + Cloudflare, Windows Server 2019 DNS Server |
| **VPN**                   | Tailscale, WireGuard, OpenVPN, NordVPN |
| **Reverse Proxy**         | Nginx Proxy Manager (replaced), Traefik (currently in use) |
| **Ad Blocking**           | Pi-hole |
| **PXE Boot**              | iVentoy |
| **RADIUS / LDAP**         | FreeRADIUS, FreeIPA |
| **Network Troubleshooting** | Wireshark |
| **APT Cache Proxy**       | APT-Cache-NG |

---

## 1.2 VPN Usage in the Homelab

- I use **OpenVPN** and **WireGuard** VPN servers, and I have also tested **Tailscale** and **NordVPN Meshnet**.
- Public-facing services are directly accessible from the internet to avoid the need for VPN client configuration.
- Internal, private services are accessible exclusively through VPN, ensuring that only authorized users can reach them.
- With **full tunnel** mode enabled, my phone uses the **AdGuard Home forwarder DNS** for ad blocking.

---

← [Back to the Homelab main page](../README_HU.md)
