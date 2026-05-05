← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Monitoring and Alerting

A centralized monitoring system ensures the visibility and operational security of the homelab infrastructure.

## 1.1 Tools Used

| Service / Tool       | Description |
|----------------------|-------------|
| **Prometheus**       | Time-series database that collects and stores metrics. |
| **Grafana**          | Visualization platform for displaying data and creating dashboards. |
| **Node Exporter**    | Extracts resource metrics from physical machines (Proxmox host) and Virtual Machines (VMs). |
| **Gotify**           | Self-hosted push notification service for receiving alerts. |

---

## 1.2 Monitored Areas

The system continuously monitors the **Proxmox** hypervisor and all running **Virtual Machines (VMs)**. Key focus areas include:

- **Resource Usage:** CPU, RAM, and Disk utilization.
- **S.M.A.R.T. Data:** Monitoring the health of physical drives (HDD/SSD) to prevent unexpected data loss.

---

## 1.3 Alerting Rules

Alerts are sent to **Gotify** if the following thresholds are exceeded:

| Resource | Threshold | Duration | Description |
|----------|-----------|----------|-------------|
| **Disk** | > 85%     | 5 min    | Prevents storage depletion and VM crashes. |
| **RAM**  | > 90%     | 5 min    | Indicates memory pressure or potential memory leaks. |
| **CPU**  | > 90%     | 10 min   | Alerts on sustained high load (ignores short spikes). |

---

## 1.4 Why this stack?

- **Grafana + Prometheus:** The industry standard for flexibility, scalability, and high-quality community dashboards.
- **Gotify:** Provides a lightweight, independent notification system that works perfectly over VPN or Cloudflare Tunnel, eliminating reliance on external services like Slack or Discord.

---

← [Back to Homelab Main Page](../README.md)