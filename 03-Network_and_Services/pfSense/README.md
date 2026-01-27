← [Back to Homelab main page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# pfSense

In my homelab, I use a **pfSense-based firewall and router**.  

---

# 📚 Table of Contents

- [NAT & Routing](#nat--routing)
- [DHCP server configuration and management](#dhcp)
- [Running an NTP server](#ntp)
- [WireGuard VPN](#wireguard-vpn)
- [OpenVPN](#openvpn)
- [Dynamic DNS (DDNS)](#dynamic-dns-ddns)

---

## NAT & Routing
- Configure **Outbound NAT** for internal networks  
- **Port Forward NAT** to expose external services  
- Ensure routing between networks  

---

## DHCP server configuration and management <a name="dhcp"></a>
- Manage IP ranges
- Static DHCP leases
- Assign gateways and DNS servers
- ARP table static entry: servers and clients receive a static ARP entry for the IP-MAC pair on the 2.0 network via the DHCP server, protecting against **ARP spoofing**
- The switch is assigned a fixed IP manually to always keep the management interface accessible, independent of DHCP

---

## Running an NTP server <a name="ntp"></a>
- Provide time synchronization for internal clients
- Clients use **chronyd**
- The pfSense server uses the older **ntpd** by default, but chronyd and ntpd can coexist without issues
- pfSense acts as an NTP server for all LXC containers and VMs, except the **FreeIPA LXC**

---

## WireGuard VPN
- Modern, fast VPN solution
- Provides remote access to the internal network

## OpenVPN
- Certificate-based authentication
- Compatible with various clients
- Allows VPN-based routing and firewall rules

---

## Dynamic DNS (DDNS)
- Manage dynamic public IP addresses
- Ensures access from the internet to the VPN network even if the public IP changes

---

← [Back to Homelab main page](../README.md)

