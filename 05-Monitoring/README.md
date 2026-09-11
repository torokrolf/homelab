← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Monitoring and Alerting

The visibility and operational reliability of the homelab infrastructure are ensured by a centralized monitoring system.

## 1.1 Used Tools

| Service / Tool | Description |
|----------------|-------------|
| **Prometheus** | Collects and stores metrics. |
| **Grafana** | Visualization platform for displaying data and creating dashboards. |
| **Node Exporter** | Exposes hardware and operating system metrics from physical hosts (Proxmox) and virtual machines (VMs). |
| **Uptime Kuma** | Monitors the availability of services and hosts (HTTP(S), TCP, ping, DNS, etc.), including uptime tracking. |
| **Gotify** | Receives alerts and notifications. |

---

## 1.2 Grafana + Prometheus — Imported Dashboards

The system continuously monitors the **Proxmox** hypervisor and all running **VMs**. Special attention is given to the following:

- **Resource utilization:** CPU, RAM, and Disk usage.

**Alerting Rules**

Alerts are sent to **Gotify** when triggered:

| Resource | Threshold | Duration | Description |
|-----------|-----------|-----------|-------------|
| **Disk**  | > 85%     | 5 minutes | Prevents storage exhaustion and VM failures. |
| **RAM**   | > 90%     | 5 minutes | Indicates memory pressure or possible memory leaks. |
| **CPU**   | > 90%     | 10 minutes | Triggers on sustained high load while ignoring short spikes. |

- **S.M.A.R.T. data via HD Sentinel script:** Monitoring the health status of physical drives (HDD/SSD) to help prevent unexpected data loss. [View SMART Scripts](/11-Scripts/proxmox/SMART)

## 1.3 Uptime Kuma

**Uptime Kuma** monitors the availability and reachability of services in real time. The system checks hosts and applications through multiple protocols, including:

- **HTTP / HTTPS** --> Checks whether a Web GUI is reachable, whether the SSL certificate is valid, and when it will expire.
- **TCP port** --> Verifies whether SMB or NFS shares are reachable.
- **Ping (ICMP)** --> Checks whether a host (e.g. Proxmox) is reachable.
- **DNS response** --> Verifies whether the DNS server is operational and resolving domain names correctly.

The goal of monitoring is the rapid detection of service outages and immediate notification of failures.

In case of failures or service unavailability, notifications are forwarded to **Gotify**.

Additionally, Uptime Kuma provides uptime statistics, response time graphs, and status pages for quick service health overview.

---

← [Back to Homelab Main Page](../README.md)
