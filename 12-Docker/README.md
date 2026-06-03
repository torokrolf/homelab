← [Back to Homelab main page](../README_EN.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

# 1. Containerization & Orchestration (Docker & K3s)

---

# 1. Docker and K3S

---

## 1.1 📚 Table of Contents

- [1.2 Virtualization Strategy](#vs)
- [1.3 Docker](#docker)

---

<a name="vs"></a>

### 1.2 Virtualization Strategy

Critical identity and networking layers are intentionally separated from **K3S**, running in dedicated virtual machines (VMs) and LXC containers to avoid circular dependencies.

| Hostname | Type | Stack / Role | Strategy (Tier) |
| :--- | :--- | :--- | :--- |
| **ACCESS-CORE-01** | VM | **Identity:** Authentik, FreeRADIUS <br> **Access:** Teleport, Guacamole | **PERSIST (Tier 0):** Critical layer. Identity services must remain operational even if K3S is being updated or fails. |
| **FREEIPA-210** | VM | FreeIPA | |
| **EDGE-GW-01** | VM | Cloudflare Tunnel, Traefik | |
| **MGMT-CORE-01** | VM | Ansible, Terraform, Semaphore, GitHub Runner, management stack (Portainer) | **PERSIST (Tier 2):** Control plane. Must not depend on the infrastructure it manages. |
| **WAZUH-SERVER-01-203** | VM | Wazuh | |
| **K3S-SERVER-01** | VM (NEW) | identity-stack (Vaultwarden), monitoring-stack (Prometheus, Grafana, Uptime Kuma), storage-stack (Nextcloud), media-stack (Sonarr, Radarr, qBittorrent, Prowlarr, Bazarr, Seerr), notification-stack (Gotify), dashboard-stack (Homarr), admin-stack (Renovate) | **CONSOLIDATED:** All containerized workloads run here, separated into Kubernetes namespaces. |
| **DNS-201** | LXC | Bind9 (Internal DNS) | **PERSIST (Tier 0):** Core network dependency. |
| **UNBOUND-223** | LXC | Unbound (Recursive DNS) | **PERSIST (Tier 0):** Secure name resolution. |
| **ADGUARDHOME-222** | LXC | AdGuard Home (Filtering) | **PERSIST (Tier 0):** Ensures internet access remains functional even during Kubernetes maintenance. |
| **JELLYFIN-221** | LXC | Jellyfin (GPU Passthrough) | **PERSIST (Tier 5):** LXC preferred for straightforward GPU access via host kernel. |
| **APT-CACHER-NG-207** | LXC | APT Cacher NG | **PERSIST (Tier 3):** Package caching layer for all VMs and LXCs. |

---

### Failure Domain Separation

Network foundation services (DNS, gateway) and identity services run on separate virtual machines. This ensures that a Kubernetes misconfiguration or failed deployment cannot cause a full infrastructure outage (“blackout”).

---

### Infrastructure as Code (IaC)

All hosts (VMs and LXCs) are provisioned and configured using **Ansible** and **Terraform** running on the `MGMT-CORE-01` management node. This ensures reproducibility and version-controlled infrastructure.

---

### Edge Security & Connectivity

External access is provided via **Cloudflare Tunnel**, eliminating the need for exposed public ports. Internal SSL termination and forward authentication to **Authentik** are handled by a dedicated **Traefik** instance, fully independent from the Kubernetes ingress controller.

---

### Hardware Passthrough

The media stack (Jellyfin) is intentionally kept inside an LXC container. This provides simpler and more stable GPU passthrough via the host kernel compared to containerized or Kubernetes-based approaches.

---

<a name="docker"></a>

## 1.3 Docker

---

### 1.3.1 Why Docker

- **Kernel independence:**  
  With LXC, I previously encountered issues where certain services were tightly coupled to specific Linux kernel versions. After host upgrades, some services would break or require reconfiguration. Docker removes this direct dependency through an additional isolation layer, making the system more stable across kernel updates.

- **Deployment complexity:**  
  In LXC, each application must be installed manually inside the OS step by step. With Docker, prebuilt images significantly simplify the process, eliminating the need to manually resolve and install dependencies.

← [Back to Homelab main page](../README_EN.md)

