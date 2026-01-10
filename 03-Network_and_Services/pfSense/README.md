← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# pfSense

In my homelab, I use a **pfSense-based firewall and router**.  

---

# 📚 Table of Contents

- [NAT & Routing](#nat--routing)
- [Configuring and Managing DHCP Server](#dhcp)
- [Running an NTP Server](#ntp)
- [WireGuard VPN](#wireguard-vpn)
- [OpenVPN](#openvpn)
- [Dynamic DNS (DDNS)](#dynamic-dns-ddns)

---

## NAT & Routing
- Configure **Outbound NAT** for the internal network  
- **Port Forward NAT** for publishing external services  
- Ensure routing between networks

---

## Configuring and Managing DHCP Server <a name="dhcp"></a>
- Manage IP ranges  
- Static DHCP leases  
- Assign gateways and DNS  
- Servers and clients on the 2.0 network receive **MAC-based static IPs** from the DHCP server  
- I assign a fixed IP to the switch manually so its management interface is always reachable, independent of DHCP

---

## Running an NTP Server <a name="ntp"></a>
- Provide time synchronization to internal clients  
- Clients use **chronyd**  
- pfSense uses the older **ntpd** server by default, but chronyd and ntpd can coexist without issues  
- pfSense serves as the NTP server for all LXCs and VMs except the **FreeIPA LXC**

---

## WireGuard VPN
- Modern, fast VPN solution  
- Provides remote access to the internal network

---

## OpenVPN
- Certificate-based authentication  
- Compatibility with various clients  
- Configure routing and firewall rules over VPN

---

## Dynamic DNS (DDNS)
- Handle dynamic public IP addresses  
- Ensures I can always access the **VPN network from the internet**, even if the public IP changes

---

← [Back to Homelab Home](../README.md)
