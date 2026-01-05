← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Operating Systems

| Platform | Type     | Versions |
|----------|---------|---------|
| Linux    | Server  | CentOS 9 Stream, Ubuntu 22.04 Server |
| Linux    | Clients | Ubuntu 22.04 Desktop |
| Windows  | Server  | Windows Server 2019 |
| Windows  | Clients | Windows 10, Windows 11 |

---

## Linux Server Services (LXC)

- **Bind9** – DNS server  
- **Nginx** – Web server / reverse proxy  
- **Ansible + Semaphore** – Automation & orchestration  
- **Zabbix Server** – Monitoring  
- **Pi-hole** – Network-wide ad blocker  
- **FreeIPA** – Identity management  
- **FreeRADIUS** – Authentication server  
- **APT-Cacher NG** – Package caching  
- **Vaultwarden** – Password management  
- **Restic** – Backup solution  
- **Open WebUI + OpenAI API** – Self-hosted AI interface  
- **TrueNAS** – Storage management  
- **Wireguard** – VPN server  
- **OpenVPN** – VPN server  
- **chronyd (NTP)** – Time synchronization  

---

## Linux Server Services (VM)

- **iVentoy** – Bootable ISO manager  

---

## Windows Server Services and Implementations

- **Servers:** 2 machines running Windows Server 2019  
- **Active Directory:**  
  - User creation  
  - Group Policy creation  
- **DHCP Server:** Configured on both servers with load balancing  
- **DNS Server:** Configured on both servers with secondary zone in case one server fails  
  - **DNS Forwarders:** 192.168.3.1 (pfSense); unresolved queries are forwarded here  
  - **Forward Zone:** `trkrolf.com` → `*.trkrolf.com` pointing to Nginx proxy at 192.168.2.202  
  - **Conditional Forwarder:** `otthoni.local` → Bind9 DNS at 192.168.2.201 (Windows Server 1 only)  
- **Backups:**  
  - Veeam Backup & Replication – for Windows laptops only  
  - Macrium Reflect – for dual-boot Windows + Linux laptops  
- **VPN Clients:** OpenVPN and Wireguard  

---
← [Vissza a Homelab főoldalra](../README_HU.md)
