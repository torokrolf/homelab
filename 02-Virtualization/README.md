← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1 Virtualization

---

## 1.1 Type 1 Hypervisor
- **Proxmox VE 9.1.4**
  - LXC (Linux Containers)
  - VM (Virtual Machines)
  - Template + Cloud-Init (ID 8000)

---

## 1.2 Proxmox 1 VMs and LXCs

**LXC Core Infrastructure (ID 100-499)**
| ID | Name | Type | IP Address | Status/Role |
| :--- | :--- | :--- | :--- | :--- |
| 100 | dns-201 | LXC | 192.168.2.201 | Primary DNS |
| 101 | unbound-223 | LXC | 192.168.2.223 | Recursive DNS |
| 102 | traefik-224 | LXC | 192.168.2.224 | Reverse Proxy |
| 103 | adguardhome-222 | LXC | 192.168.2.222 | Ad-blocking |
| 104 | pi-hole-208 | LXC | 192.168.2.208 | DNS Sinkhole |
| 105 | nginx-202 | LXC | 192.168.2.202 | Web Server |

**LXC Services (ID 1000-1099)**
| ID | Name | Type | IP Address | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1000 | zabbix-206 | LXC | 192.168.2.206 | Monitoring |
| 1001 | ansible-semaphore-203 | LXC | 192.168.2.203 | Automation UI |
| 1002 | nextcloud-204 | LXC | 192.168.2.204 | Cloud Storage |
| 1003 | homarr-216 | LXC | 192.168.2.216 | Dashboard |
| 1004 | guacamole-217 | LXC | 192.168.2.217 | Remote Access |
| 1005 | apt-cacher-ng-207 | LXC | 192.168.2.207 | Package Proxy |
| 1006 | freeipa-210 | LXC | 192.168.2.210 | Identity Mgmt |
| 1007 | freeradius-221 | LXC | 192.168.2.221 | Auth Server |
| 1008 | restic-rclone-215 | LXC | 192.168.2.215 | Backup Agent |
| 1009 | vaultwarden-212 | LXC | 192.168.2.212 | Password Vault |
| 1010 | jellyfin-221 | LXC | 192.168.2.221 | Media Server |
| 1011 | servarr-225 | LXC | 192.168.2.225 | Media Automation |
| 1012 | gotify-226 | LXC | 192.168.2.226 | Push Notifications |
| 1013 | portainer-219 | LXC | 192.168.2.219 | Docker Management |
| 1014 | pulse-227 | LXC | 192.168.2.227 | Monitoring Agent |
| 1015 | changedetection-229 | LXC | 192.168.2.229 | Web Monitoring |

**VM Linux Servers (ID 1100-1199)**
| ID | Name | Type | IP Address | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1100 | crowdsec-218 | LXC | 192.168.2.218 | Security/IDS |
| 1101 | pxeboot-209 | VM | 192.168.2.209 | Network Boot |
| 1102 | packetfence-228 | VM | 192.168.2.228 | NAC Service |

**VM Linux Clients (ID 1200-1299)**
| ID | Name | Type | IP Address | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1200 | mainubuntu-200 | VM | 192.168.2.200 | Main Linux Host |
| 1201 | kali | VM | DHCP | Pentesting Lab |
| 1202 | probaubi-205 | VM | 192.168.2.205 | Sandbox |

**VM Windows Servers (ID 1300-1399)**
| ID | Name | Type | IP Address | Role |
| :--- | :--- | :--- | :--- | :--- |
| 1300 | winszerver1-230 | VM | 192.168.3.230 | AD Domain Controller |
| 1301 | winszerver2-234 | VM | 192.168.3.234 | Secondary DC |
| 1302 | winszerver-core-233 | VM | 192.168.3.233 | Core Services |

**VM Windows Clients (ID 1400-1499)**
| ID | Name | Type | IP Address | Role |
| :--- | :--- | :--- | :--- | :--- |
| 1400 | mainwindows11-213 | VM | 192.168.3.213 | Primary Workstation |
| 1401 | win11kliens1-231 | VM | 192.168.3.231 | Client 1 |
| 1402 | win11kliens2-232 | VM | 192.168.3.232 | Client 2 |

---

## 1.2 Proxmox 2 VMs and LXCs

**VM Core Infrastructure (ID 500-999)**
| ID | Name | Type | IP Address | Status/Role |
| :--- | :--- | :--- | :--- | :--- |
| 500 | pfsense | VM | DHCP/Static | Firewall & Router |
| 501 | pbs | VM | DHCP/Static | Proxmox Backup Server |
| 502 | truenas-220 | VM | 192.168.2.220 | Network Attached Storage (NAS) |

---

← [Back to Homelab Home](../README.md)

