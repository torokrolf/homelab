← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Monitoring and Alerting

A centralized monitoring system ensures the visibility and operational security of the homelab infrastructure.

## 1.1 Tools Used

| Service / Tool       | Description |
|----------------------|-------------|
| **Prometheus**       | Collects and stores metrics. |
| **Grafana**          | Visualization platform for displaying data and creating dashboards. |
| **Node Exporter**    | Extracts resource metrics from physical machines (Proxmox host) and Virtual Machines (VMs). |
| **Gotify**           | For receiving alerts. |

---

## 1.2 Monitored Areas — with Imported Dashboards

The system continuously monitors the **Proxmox** hypervisor and all running **VMs**. Key focus areas include:

- **Resource Usage:** CPU, RAM, and Disk utilization.
- **S.M.A.R.T. Data:** Monitoring the health status of physical drives (HDD/SSD) to prevent unexpected data loss.

---

## 1.3 Alerting Rules

Alerts are sent to **Gotify** once they are triggered based on the following conditions:

| Resource | Threshold | Duration | Description |
|----------|-----------|----------|-------------|
| **Disk** | > 85%     | 5 min    | Prevents storage depletion and VM crashes. |
| **RAM**  | > 90%     | 5 min    | Indicates memory pressure or potential memory leaks. |
| **CPU**  | > 90%     | 10 min   | Alerts on sustained high load (ignores short spikes). |

---

← [Back to Homelab Main Page](../README.md)
