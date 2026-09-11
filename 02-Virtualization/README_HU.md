← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Virtualizáció

---

## Type 1 Hypervisor
- **Proxmox VE 9**
  - LXC (Linux Containers)
  - VM (Virtual Machines)
  - Template + Cloud-Init

---

## 1.2 Proxmox Node 1 - Compute & Core Services

**LXC Core Infrastructure (ID 100-499)**
| ID | Name | Type | IP Address | Status/Role |
| :--- | :--- | :--- | :--- | :--- |
| 100 | dns-core-01 | LXC | 192.168.2.201 | Primary DNS Server |
| 101 | unbound-forwarder | LXC | 192.168.2.223 | Recursive DNS Resolver |
| 103 | adguard-home | LXC | 192.168.2.222 | Network-wide DNS Ad-blocking & Filtering |

**VM Core Infrastructure (ID 500-999)**
| ID | Name | Type | IP Address | Status/Role |
| :--- | :--- | :--- | :--- | :--- |
| 510 | access-core-01 | VM | 192.168.2.206 | Remote Access Gateway / VPN |
| 520 | edge-gw-01 | VM | 192.168.2.230 | Perimeter Edge Gateway |

**LXC Services (ID 1000-1099)**
| ID | Name | Type | IP Address | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1005 | apt-cacher-ng | LXC | 192.168.2.207 | Centralized Package Proxy Cache |
| 1006 | freeipa-domain | LXC | 192.168.2.210 | Linux Identity & Access Management (IAM) |
| 1010 | jellyfin-media | LXC | 192.168.2.221 | Centralized Media Streaming Server |
| 1015 | changedetection | LXC | 192.168.2.229 | Website Change Detection & Monitoring |

**VM Linux Servers (ID 1100-1199)**
| ID | Name | Type | IP Address | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1101 | pxeboot-server | VM | 192.168.2.209 | Automated Network Boot & OS Deployment |
| 1103 | mgmt-core-01 | VM | 192.168.2.204 | Core Management Server |
| 1104 | wazuh-server-01 | VM | 192.168.2.203 | SIEM & Security Monitoring Server |
| 1105 | k3s-control-01 | VM | 192.168.2.225 | Kubernetes Control Plane Node |

**VM Linux Clients / Labs (ID 1200-1299)**
| ID | Name | Type | IP Address | Description |
| :--- | :--- | :--- | :--- | :--- |
| 1200 | ubuntu-desktop | VM | 192.168.2.200 | Main Linux Workstation |
| 1201 | kali-pentest | VM | DHCP | Network Security Auditing & Pentesting Lab |
| 1202 | sandbox-ubuntu | VM | 192.168.2.205 | Isolated Linux Sandbox Environment |

**VM Windows Infrastructure Lab (ID 1300-1399)**
| ID | Name | Type | IP Address | Role |
| :--- | :--- | :--- | :--- | :--- |
| 1300 | winserver-dc-01 | VM | 192.168.3.230 | Active Directory Domain Controller (Primary) |
| 1301 | winserver-dc-02 | VM | 192.168.3.234 | Active Directory Domain Controller (Secondary) |
| 1302 | winserver-core | VM | 192.168.3.233 | Windows Server Core Minimal Installation |

**VM Windows Clients (ID 1400-1499)**
| ID | Name | Type | IP Address | Role |
| :--- | :--- | :--- | :--- | :--- |
| 1400 | win11-workstation | VM | 192.168.3.213 | Enterprise Windows 11 Client Host |
| 1401 | win11-client-01 | VM | 192.168.3.231 | Active Directory Domain Joined Client 1 |
| 1402 | win11-client-02 | VM | 192.168.3.232 | Active Directory Domain Joined Client 2 |

**VM Templates (ID 8000+)**
| ID | Name | Type | Status | Description |
| :--- | :--- | :--- | :--- | :--- |
| 8000 | ubuntu-server-22.04.5-template | VM | Template | Cloud-Init Prepared Golden Image |

---

## 1.3 Proxmox Node 2 - Storage & Edge Network

**VM Core Infrastructure (ID 500-999)**
| ID | Name | Type | IP Address | Status/Role |
| :--- | :--- | :--- | :--- | :--- |
| 500 | pfsense | VM | DHCP/Static | High-Performance Firewall & Core Router |
| 501 | pbs | VM | DHCP/Static | Centralized Proxmox Backup Server |
| 502 | truenas-core | VM | 192.168.2.220 | Network Attached Storage (NAS) |

---

← [Vissza a Homelab főoldalra](../README_HU.md)