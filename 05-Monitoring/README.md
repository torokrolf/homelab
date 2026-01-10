← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Monitoring Overview

| Service / Tool | Description |
|----------------|------------|
| **Monitoring** | Zabbix |

## Zabbix Monitoring Server

The purpose of the Zabbix server: **central infrastructure monitoring** for the homelab machines.

---

### Implemented Features
> The monitoring currently focuses on basic functionality; further expansion of the system is planned.  
>
- Zabbix Agent installed on Linux and Windows machines  
- Basic problem triggers created:  
  - Machine unreachable (ping) for 1 minute  
  - Free disk space drops below a defined threshold  
  - CPU usage exceeds a set value  
- Alerts configured for triggers with email notifications

---

← [Back to Homelab Home](../README.md)


