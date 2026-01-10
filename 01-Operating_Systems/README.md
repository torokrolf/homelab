← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Operating Systems Summary

| Platform | Type    | Versions |
|----------|---------|---------|
| Linux    | Server  | CentOS 9 Stream, Ubuntu 22.04 Server |
| Linux    | Clients | Ubuntu 22.04 Desktop |
| Windows  | Server  | Windows Server 2019 |
| Windows  | Clients | Windows 10, Windows 11 |

---

## Services Used on Linux Servers (LXC)
- Bind9  
- Nginx  
- Ansible + Semaphore  
- Zabbix server  
- Pi-hole  
- FreeIPA  
- FreeRADIUS  
- APT-Cacher NG  
- Vaultwarden  
- Restic  
- Open WebUI + OpenAI API  
- TrueNAS  
- Wireguard  
- OpenVPN  
- chronyd (NTP)

---

## Services Used on Linux Servers (VM)
- iVentoy

---

## Services and Implementations on Windows Servers

- 2 machines running Windows Server 2019  
- Active Directory  
  - User creation  
  - Group Policy creation  
- DHCP server – on both servers, with load balancing  
- DNS server – on both servers, with secondary zone configured in case one server fails  
- DNS forwarders: 192.168.3.1 (pfSense), any unresolved requests by the DNS server are forwarded here  
- Forward zone: trkrolf.com → *.trkrolf.com points to Nginx proxy at 192.168.2.202  
- Conditional forwarder: otthoni.local → directed to Bind9 DNS server at 192.168.2.201, only on Windows Server 1, so it can resolve otthoni.local  
- Veeam Backup & Replication – only for laptops running Windows  
- Macrium Reflect – for Windows + Linux dual boot laptops  
- OpenVPN client  
- Wireguard client  

---

← [Back to Homelab Home](../README.md)
