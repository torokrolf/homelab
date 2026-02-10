← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 📚 Table of Contents

- [00. Homelab Hardware](./00-Homelab_Hardware/README.md)
- [01. Operating Systems](./01-Operating_Systems/README.md)
- [02. Virtualization](./02-Virtualization/README.md)
- [03. Network and Services](./03-Network_and_Services/README.md)
- [04. Remote Access](./04-Remote_Access/README.md)
- [05. Monitoring](./05-Monitoring/README.md)
- [06. Automation](./06-Automation/README.md)
- [07. Backup and Recovery](./07-Backup_and_Recovery/README.md)
- [08. Dashboard](./08-Dashboard/README.md)
- [09. Password Management](./09-Password_Management/README.md)
- [10. Storage](./10-Storage/README.md)
- [11. Scripts](./11-Scripts/README.md)
- [12. Design Decisions](./12-Design_Decisions/README.md)
- [13. Errors and Troubleshooting](./13-Errors/README.md)

---

# Homelab Short Summary 

## 🏠 Homelab Project Overview

This project presents a self-designed, enterprise-grade homelab where I practice virtualization, network security, and systems administration on Linux and Windows platforms. It includes both Windows and Linux solutions. For the implementation and the mastery of the underlying theory, Udemy courses, YouTube videos, articles, and forums have been of great help—all in English. I have also started using ChatGPT, which I find useful for drastically accelerating information gathering and research.

| Domain | Tools Used |
|----------------------|---------------------------------------------------|
| **Operating Systems** | CentOS 9 Stream, Ubuntu 22.04 Desktop/Server, Windows 10/11, Windows Server 2019 |
| **Virtualization** | Proxmox VE (on 2 nodes), LXC, VM, Template + Cloud-init |
| **Firewall & Router** | pfSense |
| **DHCP** | ISC-KEA, Windows Server 2019 DHCP Server |
| **DNS** | BIND9 + Unbound + Namecheap + Cloudflare, Windows Server 2019 DNS Server |
| **VPN** | Tailscale, WireGuard, OpenVPN, NordVPN |
| **Remote Access** | SSH (Termius), RDP (Guacamole) |
| **Reverse Proxy** | Nginx Proxy Manager (replaced), Traefik (currently used) |
| **Monitoring** | Zabbix |
| **Automation** | Ansible + Semaphore, Cron + Cronicle |
| **Security & Backup** | Proxmox Backup Server, Clonezilla, rclone, Nextcloud, FreeFileSync, Restic, Veeam Backup & Replication Community Edition, Macrium Reflect |
| **Ad Filtering** | Pi-hole (replaced), AdGuard Home (currently used) |
| **APT Cache Proxy** | APT-Cacher-NG |
| **Dashboard** | Homarr |
| **RADIUS, LDAP** | FreeRADIUS, FreeIPA |
| **Password Management** | Vaultwarden |
| **PXE Boot** | iVentoy |
| **Troubleshooting** | Wireshark |
| **Storage** | TrueNAS |

---

## 🎯 How this Homelab supports my professional growth:
- Deepened my theoretical knowledge through practical, hands-on tasks.
- Infrastructure design required significant planning and research, fostering foresight.
- Explored and implemented new technologies, broadening my technical stack.
- Faced real-world problems that required independent troubleshooting, improving problem-solving skills.
- Increased the need to understand the root cause of errors to prevent them in the future.

> [!IMPORTANT]
> I would like to highlight the following two sections, which I consider the most valuable parts of this project. In these documents, I explain the rationale behind my design decisions, the challenges I encountered, and the specific troubleshooting steps I took to resolve them.
> 
> - [12. Design Decisions](./12-Design_Decisions/README.md)
> - [13. Errors and Troubleshooting](./13-Errors/README.md)

---

## 🔮 Future Learning and Implementation Goals

- Deepen knowledge of the **Python** programming language.
- **Cloud Computing:** Strong interest in AWS and Azure; aim to gain deeper expertise.
- **Advanced Monitoring:** Learn Grafana + Prometheus; further deepen Zabbix knowledge.
- **Cloud Storage:** Implement Hetzner or pCloud to satisfy the **3-2-1 backup rule**.
- **High Availability:** Planning to acquire three 2.5" SSDs and a Lenovo M920q Tiny PC to build a three-node **Proxmox cluster** with **Ceph** integration.
- **DIY PiKVM:** Implement KVM over IP using a Raspberry Pi 4.
- **IDS/IPS:** Implementation of Suricata.
- **Network Security Expansion:** pfBlockerNG, PacketFence.
- **Advanced Switching:** Acquire a managed switch to test 802.1x port-based authentication and RADIUS management. Enhance security via DHCP snooping and port security.

---

**Homelab Network Topology:**

```mermaid
graph TD
    %% Global
    Internet((Internet)) --- Asus[ASUS Router]

    %% Home Network Section
    subgraph Home_Net ["Home Network"]
        Subnet["192.168.1.0/24"]
        TV["TV"]
        Phone["Phones"]
        Laptop["Laptops"]
    end
    Asus --- Subnet
    Subnet --- TV
    Subnet --- Phone
    Subnet --- Laptop

    %% Homelab Entry Point
    Entry_IP["pfSense WAN: 192.168.1.196"]
    Asus --- Entry_IP

    %% HOMELAB SYSTEM
    subgraph Homelab_System ["HOMELAB SYSTEM"]
        direction TB

        %% Node2 - Firewall Node
        subgraph Node2 ["Proxmox 2 - M920q (Firewall)"]
            P2_WAN["vmbr0 - WAN Bridge <br/> IP: 192.168.1.198"]
            pfS{pfSense VM <br/> GW: 192.168.2.1}
            P2_LAN["vmbr1 - LAN Bridge <br/> IP: 192.168.2.198"]

            P2_WAN -- "enp1s0f0" --- pfS
            pfS -- "enp1s0f1" --- P2_LAN
        end

        Entry_IP --- P2_WAN

        %% Physical Switch
        subgraph Switch ["TP-Link TL-SG108E Switch"]
            SW_P1[Port 1] -- "VLAN 30 Trunk" --- SW_P8[Port 8]
        end

        P2_LAN --- SW_P1
        SW_P8 --- P1_NIC

        %% Node1 - Compute Node
        subgraph Node1 ["Proxmox 1 - M70q (Server)"]
            P1_NIC["NIC: enx503eaa522d61"]
            P1_Bridge["vmbr0 - VLAN Aware <br/> IP: 192.168.2.199"]

            P1_NIC --- P1_Bridge

            subgraph Subnets ["VLAN Networks"]
                P1_Bridge -- "Native" --- LAN2["192.168.2.0/24"]
                P1_Bridge -- "VLAN 30" --- VLAN3["192.168.3.0/24"]
            end

            subgraph VMs ["Virtual Resources"]
                LAN2 --- Linux["Linux Systems"]
                VLAN3 --- Windows["Windows Systems"]
            end
        end
    end

    %% Styles
    style Home_Net fill:#fffbe6,stroke:#d4a017
    style Entry_IP fill:#fff3cd,stroke:#d4a017,font-weight:bold
    style pfS fill:#f96,stroke:#333
    style Homelab_System fill:#f8f9fa,stroke:#333,stroke-dasharray: 8 4
    style Node1 fill:#fff
    style Node2 fill:#fff
```
---

← [Back to Homelab Home](../README.md)
