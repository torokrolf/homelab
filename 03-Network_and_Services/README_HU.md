← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Network and Services

---

## 1.1 Table of Contents

| Service / Area                         | Tools / Software |
|----------------------------------------|--------------------------------------------------------------------|
| [1.2 Firewall / Router](#pfsense)      | pfSense                                                  
| [1.3 VPN](#vpn)                        | Tailscale, WireGuard, OpenVPN, NordVPN                   
| [1.4 APT cache proxy](#apt)            | APT-Cache-NG                                             
| [1.5 VLAN](#vlan)                      | TP-LINK SG108E switch                                        
| [1.6 Reverse Proxy](#reverseproxy)     | Nginx Proxy Manager (replaced), Traefik (currently used)        
| [1.7 Radius / LDAP](#radiusldap)       | FreeRADIUS, FreeIPA                             
| [1.8 Ad filtering](#reklamszures)      | Pi-hole                                               
| [1.9 PXE Boot](#pxe)                   | iVentoy                                         
| [1.10 DNS](#dns)                       | BIND9 + Namecheap + Cloudflare, Windows Server 2019 DNS server 
| [1.11 Network Troubleshooting](#hibakereses) | Wireshark                                                
| [1.12 DHCP](#dhcp2)                    | ISC-KEA, Windows Server 2019 DHCP server                       

---

<a name="pfsense"></a>
## 1.2 pfSense 

In my homelab, I use a **pfSense-based firewall and router**.  

---

### 1.2.1 NAT & Routing
- **Outbound NAT** configuration for the internal network  
- **Port Forward NAT** for publishing external services  
- **Ensuring routing between networks** ---

<a name="dhcp"></a>
### 1.2.2 DHCP Server Configuration and Operation 
- IP range management
- Static DHCP leases
- Gateway and DNS assignment
- ARP table static entry: servers and clients receive static ARP entries for IP-MAC pairs on the 2.0 network from the DHCP server, thus protecting against **ARP spoofing**
- Assigning a fixed IP manually to the switch ensures its management interface remains accessible regardless of DHCP

---

### 1.2.3 Running an NTP Server <a name="ntp"></a>
- Providing time synchronization for internal clients
- Clients use **chronyd**
- The pfSense server uses the older **ntpd** server by default, but chronyd and ntpd work together without issues
- pfSense serves as the NTP server for all LXCs and VMs, except for the **FreeIPA LXC**

---

### 1.2.4 WireGuard VPN
- Modern, high-speed VPN solution
- Providing remote access to the internal network

---

### 1.2.5 OpenVPN
- Certificate-based authentication
- Compatibility with various clients
- Configuring routing and firewall rules over VPN

---

### 1.2.6 Dynamic DNS (DDNS)
- Managing dynamic public IP addresses 
- Crucial for ensuring the **VPN network remains accessible from the internet** even if the public IP changes

---

<a name="vpn"></a>
## 1.3 VPN Usage for the Homelab

- I use **OpenVPN** and **WireGuard** VPN servers, but I have also tested **Tailscale** and the **NordVPN Meshnet** system.
- Publicly available services are directly accessible from the internet to avoid the need for VPN client setup.
- Internal, private services are accessible exclusively via VPN, ensuring only authorized users can reach them.
- By configuring **full tunnel** mode, the phone uses the **AdGuard Home forwarder DNS** for ad blocking.

---

<a name="apt"></a>
## 1.4 APT Cache NG

---

### 1.4.1 Why do I use it?

- I use it for VM and LXC updates orchestrated by **Ansible**, scheduled for 3 AM.  
- Goal: avoid downloading packages individually for every VM/LXC, which generates unnecessary traffic.  
- The cache proxy stores downloaded packages requested by a client. If another machine requests the same package and there is a "hit" in the cache, the machines download updates from the APT cache proxy server instead of the internet, saving bandwidth and data.

It can be seen that on one day, the hit rate was 88.26%: out of 34.05 MB of traffic, 30.05 MB was served from the cache. Even on the worst days, it served 526 MB out of 996 MB of traffic, representing 52% efficiency. Overall, it served 6.3 GB of data, of which only 2.2 GB had to be downloaded from the internet, saving approximately 4 GB of bandwidth.
<div align="center">
  <img src="https://github.com/user-attachments/assets/d2e4134c-879c-4b88-b3f6-ccb0553a6d9f" alt="Description" width="800">
</div>

---

<a name="vlan"></a>
## 1.5 VLAN Implementation and Network Segmentation

- **Creating a VLAN interface under Proxmox** (`vmbr0.30`), belonging to the `vmbr0` bridge with VLAN tag 30.
- Enabling **VLAN-aware** mode on the `vmbr0` bridge to prevent VLAN tags from being dropped.
- **Assigning VLAN tags to relevant VMs**, isolating them from the tagless 2.0 network.
- **Creating a new subnet for the VLAN** (192.168.3.0/24), with the default gateway being the pfSense VLAN interface.
- **Creating a VLAN interface on pfSense** and assigning an IP address to the VLAN network.
- **Configuring pfSense firewall rules and NAT** for communication between the VLAN and other networks.
- **Configuring VLANs on the TP-Link SG108E switch** to handle trunked traffic.
- **Adding a static route on the ASUS router** so the 1.0 network can reach the VLAN network.
- **Enabling DHCP service** on the pfSense VLAN interface.

---

<a name="reverseproxy"></a>
## 1.6 Reverse Proxy

I use a Reverse Proxy because it allows for a simple and transparent way to **manage SSL/TLS certificates** for my homelab services.

- A wildcard certificate can be easily assigned to every subdomain
- It hides the internal servers' IP addresses, ports, and paths from the URL, increasing security and simplifying access
- Thanks to its graphical interface, it is fast and transparent to configure

---

### 1.6.1 Using Local DNS Names (Nginx / Traefik)

**Important design principle**: **I do not use fixed IP addresses for either Nginx or Traefik**; instead, I use **local DNS names**.

The reason for this is to **avoid modifying every configuration in case of an IP change** – it should be sufficient to **only update the record on the centralized DNS server**.

This approach is:
- **More flexible** – no reconfiguration required if an IP is changed
- **More transparent** – descriptive hostnames instead of fixed IPs

---

### 1.6.2 SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard Solution

In the homelab environment, the browser displayed warnings because services were not accessible via HTTPS.  
The solution was to **use a Reverse Proxy with Let’s Encrypt SSL/TLS certificates**, based on **DNS-01 challenge** authentication.

**The essence in short:**
- HTTPS requires an SSL/TLS certificate
- The **DNS-01 challenge** verifies domain ownership using a DNS TXT record
- Authentication is performed using a **Cloudflare API token**
- The Reverse Proxy creates a temporary TXT record  
  (`_acme-challenge.trkrolf.com  TXT  <ACME Identifier>`)

---

<a name="radiusldap"></a>
## 1.7 RADIUS & LDAP

---

### 1.7.1 FreeIPA Server as LDAP (CentOS 9)

- Unified user and permission management within the infrastructure.

---

#### 1.7.1.1 Implemented Features

- Creating and managing users.
- Configuring users with Sudo privileges.

---

### 1.7.2 FreeRADIUS Server as RADIUS – pfSense GUI Authentication

---

#### 1.7.2.1 Implemented Features

- **RADIUS login for pfSense**: logging into the pfSense GUI via Radius authentication.
- **Authentication fallback**: if the RADIUS server goes down, login is still possible with a local user.
- **Identical usernames/passwords for local and RADIUS users**, so the user doesn't need to know which authentication method is being used.
- **SQL database + PhpMyAdmin**: users and permissions are conveniently managed via a graphical interface, avoiding manual file editing or logging, as management occurs directly from the database.

---

<a name="reklamszures"></a>
## 1.8 Ad Filtering
### 1.8.1 Pi-hole 

The goal of Pi-hole: **DNS-based ad filtering on the homelab network**.

---

#### 1.8.1.1 Network Integration

- **Integrated into WireGuard VPN**:  
  - All clients, such as mobile phones, receive ad filtering through Pi-hole DNS, even when using mobile data.
- Upstream DNS server: local **BIND9** server. 

---

<img src="https://github.com/user-attachments/assets/2d1971e8-aa55-4ebf-9fb2-3b0e95681515" alt="Image description" width="700"/>

---

<a name="pxe"></a>
## 1.9 PXE Boot Server
### 1.9.1 iVentoy

The goal: No need to run individual installers from USB or CD on every machine; it allows booting any ISO (Clonezilla, Windows installer, Ubuntu installer, etc.).

---

### 1.9.2 Tests

- **Running Clonezilla**:
  - For cloning machines via SSH connection.  
  - Disaster recovery testing with Clonezilla.

- **Automatic Start**:  
  - iVentoy service created so the system **starts on boot**, which is a better solution than starting via cron.

**The image below shows in the bottom row that a machine has connected to the PXE server.**

<img width="800" alt="image" src="https://github.com/user-attachments/assets/b9906010-79dc-44ec-b386-403fbe40a8f9" />

---

<a name="dns"></a>
## 1.10 DNS
### 1.10.1 Public Domain (Namecheap, Cloudflare)

- Own domain purchased on **Namecheap**, then migrated to **Cloudflare** nameservers.  
- Public services: **not directly accessible**; I access them locally or via **VPN** when remote.

### 1.10.2 Private Domain (Bind9)

- Private domain: **`otthoni.local`** - Resolution: **BIND9 DNS server**

- My **Bind9** service serves two purposes:  
  1. It is authoritative for the **`otthoni.local`** domain, ensuring home machines and services are always reachable.  
  2. Overriding the **`trkrolf.com`** domain when queried from the LAN to point to my **NGINX server IP**, so home services remain accessible even without an internet connection, as resolution does not rely on Cloudflare nameservers.  

- Snippet from the BIND9 db.otthoni.local zone file:
<img src="https://github.com/user-attachments/assets/12686bdf-316a-4b5a-9f78-95d481fe005f" alt="Image description" width="500"/>

---

#### 1.10.2.1 DNS Override

- Within the homelab network, I direct `*.trkrolf.com` requests to the **local DNS IP address**.  
- Advantage:  
  - The public DNS server does not resolve the name  
  - Access to home services works without an internet connection

---

<a name="hibakereses"></a>
## 1.11 Network Troubleshooting
### 1.11.1 Wireshark Basics

Used to quickly diagnose network problems and understand the operation of basic protocols.

**Used for practical study of protocols for deeper understanding (DNS, DHCP, ARP, TCP)**:
- Tracking **DNS** queries and responses
- Monitoring **DHCP** messages
- Tracking **ARP** communication
- Examining the **TCP 3-way handshake**

---

<a name="dhcp2"></a>
## 1.12 DHCP

[See pfSense DHCP](#dhcp)  

← [Back to Homelab Main Page](../README.md)

