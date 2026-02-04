← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Network and Services

---

## 1.1 Network and Services Overview

| Service / Area                         | Tools / Software |
|---------------------------------------|------------------|
| [1.2 Firewall / Router](#pfsense)            | pfSense                                                 
| [1.3 VPN](#vpn)                              | Tailscale, WireGuard, OpenVPN, NordVPN                  
| [1.4 APT cache proxy](#apt)                  | APT-Cache-NG                                            
| [1.5 VLAN](#vlan)                            | TP-LINK SG108E switch                                   
| [1.6 Reverse Proxy](#reverseproxy)           | Nginx Proxy Manager (replaced), Traefik (currently used)
| [1.7 Radius / LDAP](#radiusldap)             | FreeRADIUS, FreeIPA                                     
| [1.8 Ad blocking](#reklamszures)             | Pi-hole                                                 
| [1.9 PXE Boot](#pxe)                         | iVentoy                                                 
| [1.10 DNS](#dns)                             | BIND9 + Namecheap + Cloudflare, Windows Server 2019 DNS 
| [1.11 Network troubleshooting](#hibakereses) | Wireshark                                               
| [1.12 DHCP](#dhcp2)                          | ISC-KEA, Windows Server 2019 DHCP                       
| [1.13 Notifications](#notification)         | Gotify                                         

---

<a name="pfsense"></a>
## 1.2 pfSense

In my homelab, I use a **pfSense-based firewall and router**.

### 1.2.1 NAT & Routing
- **Outbound NAT** configuration for internal networks
- **Port Forward NAT** for publishing external services
- **Routing between internal networks**

<a name="dhcp"></a>
### 1.2.2 DHCP Server Configuration and Operation
- Managing IP ranges
- Static DHCP leases
- Gateway and DNS distribution
- Static ARP entries: servers and clients receive static IP–MAC bindings from the DHCP server on the 2.0 network, protecting against **ARP spoofing**
- The switch has a manually assigned static IP to ensure the management interface is always reachable independently of DHCP

### 1.2.3 Running an NTP Server <a name="ntp"></a>
- Time synchronization for internal clients
- Clients use **chronyd**
- pfSense uses the older **ntpd** service by default, but chronyd and ntpd can coexist without issues
- pfSense acts as the NTP server for all LXCs and VMs except the **FreeIPA LXC**

### 1.2.4 WireGuard VPN
- Modern, fast VPN solution
- Secure remote access to the internal network

### 1.2.5 OpenVPN
- Certificate-based authentication
- Compatibility with multiple clients
- Firewall rules and routing through the VPN

### 1.2.6 Dynamic DNS (DDNS)
- Handling dynamic public IP changes
- Ensures continuous access to the **VPN network from the internet** even if the public IP changes

---

<a name="vpn"></a>
## 1.3 VPN Usage in the Homelab

- I use **OpenVPN** and **WireGuard**, and have also tested **Tailscale** and **NordVPN Meshnet**.
- Public services are directly accessible from the internet without requiring VPN client configuration.
- Internal services are accessible **only through VPN**, ensuring only authorized users can access them.
- With **full tunnel** enabled, my phone uses the **AdGuard Home forwarder DNS** for ad blocking even outside my home network.

---

<a name="apt"></a>
## 1.4 APT Cache NG

### 1.4.1 Why I Use It

- Used for **Ansible-scheduled VM and LXC updates** at 3 AM.
- Prevents every VM/LXC from downloading packages individually and generating unnecessary traffic.
- The cache proxy stores previously downloaded packages. If another machine requests the same package and it is in cache (cache hit), it is served locally instead of from the internet.

There were days when the cache hit ratio reached **88.26%**: out of 34.05 MB traffic, 30.05 MB was served from cache. Even on the worst day, 526 MB out of 996 MB was served from cache (52% efficiency). In total, 6.3 GB of data was served, while only 2.2 GB had to be downloaded from the internet — saving roughly **4 GB of bandwidth**.

<div align="center">
  <img src="https://github.com/user-attachments/assets/d2e4134c-879c-4b88-b3f6-ccb0553a6d9f" width="800">
</div>

---

<a name="vlan"></a>
## 1.5 VLAN and Network Segmentation

- Creating VLAN interface in Proxmox (`vmbr0.30`)
- Enabling **VLAN-aware** mode on the bridge
- Assigning VLAN tags to VMs
- Creating new subnet (192.168.3.0/24)
- VLAN interface and firewall rules on pfSense
- VLAN trunk configuration on TP-Link switch
- Static route on ASUS router
- DHCP enabled on pfSense VLAN interface

---

<a name="reverseproxy"></a>
## 1.6 Reverse Proxy

Used for centralized **SSL/TLS certificate management**.

### 1.6.1 Using Local DNS Names (Nginx / Traefik)

I never use fixed IPs in proxy configs — only DNS names.

Benefits:
- No reconfiguration on IP change
- Cleaner, more readable setup

### 1.6.2 SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard

- HTTPS via Let’s Encrypt
- DNS-01 challenge with Cloudflare API
- Temporary TXT record for validation

---

<a name="radiusldap"></a>
## 1.7 RADIUS & LDAP

### 1.7.1 FreeIPA as LDAP
- Centralized user and permission management
- Sudo user configuration

### 1.7.2 FreeRADIUS for pfSense GUI Authentication
- pfSense GUI login via RADIUS
- Authentication fallback to local user
- SQL + PhpMyAdmin for user management

---

<a name="reklamszures"></a>
## 1.8 Ad Blocking – Pi-hole

- DNS-based ad blocking
- Integrated into WireGuard VPN
- Upstream DNS: BIND9

---

<a name="pxe"></a>
## 1.9 PXE Boot – iVentoy

- Network ISO boot (Clonezilla, Windows, Ubuntu)
- Service starts automatically on boot

---

<a name="dns"></a>
## 1.10 DNS

### Public Domain
- Namecheap + Cloudflare

### Private Domain (BIND9)
- `otthoni.local`
- DNS override for `trkrolf.com` internally

---

<a name="hibakereses"></a>
## 1.11 Network Troubleshooting – Wireshark

Used to study DNS, DHCP, ARP, TCP handshakes in practice.

---

<a name="dhcp2"></a>
## 1.12 DHCP

[See pfSense DHCP section](#dhcp)

---

<a name="notification"></a>
## 1.2  Notification

---

← [Back to Homelab Home](../README.md)



