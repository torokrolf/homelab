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
| 103 | adguardhome-222 | LXC | 192.168.2.222 | Ad-blocking |

**VM Core Infrastructure (ID 500-999)**
| ID | Name | Type | IP Address | Status/Role |
| :--- | :--- | :--- | :--- | :--- |
| 510 | access-core-01-206 | VM | 192.168.2.206 | Remote Access / VPN |
| 520 | edge-gw-01-230 | VM | 192.168.2.230 | Edge Gateway |


**LXC Services (ID 1000-1099)**
| ID | Name | Type | IP Address | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1005 | apt-cacher-ng-207 | LXC | 192.168.2.207 | Package Proxy |
| 1006 | freeipa-210 | LXC | 192.168.2.210 | Identity Mgmt |
| 1010 | jellyfin-221 | LXC | 192.168.2.221 | Media Server |

**VM Linux Servers (ID 1100-1199)**
| ID | Name | Type | IP Address | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1101 | pxeboot-209 | VM | 192.168.2.209 | Network Boot |
| 1105 | k3s-server-01-225 | VM | 192.168.2.225 | Kubernetes Control Plane |

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

## 1.3 Proxmox 2 VMs and LXCs

**VM Core Infrastructure (ID 500-999)**
| ID | Name | Type | IP Address | Status/Role |
| :--- | :--- | :--- | :--- | :--- |
| 500 | pfsense | VM | DHCP/Static | Firewall & Router |
| 501 | pbs | VM | DHCP/Static | Proxmox Backup Server |
| 502 | truenas-220 | VM | 192.168.2.220 | Network Attached Storage (NAS) |

---

← [Back to Homelab Home](../README.md)

