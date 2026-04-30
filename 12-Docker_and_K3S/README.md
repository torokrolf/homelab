← [Back to Homelab main page](../README_EN.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

# 1. Containerization & Orchestration (Docker & K3s)

---

## 1.1 📚 Table of Contents

- [1.2 Virtualization Strategy](#virtualization-strategy)
- [1.3 Docker](#docker)
- [1.4 K3s (Lightweight Kubernetes)](#k3s)

---

<a name="virtualization-strategy"></a>

## 1.2 Virtualization Strategy

Critical identity and networking layers are intentionally hosted **outside of the K3s cluster** within dedicated Virtual Machines (VMs) and Containers (LXCs). This design prevents circular dependencies and ensures core services remain operational during cluster maintenance.

### Infrastructure Tiering

| Hostname | Type | Stacks / Responsibilities | Strategy (Tier) |
| :--- | :--- | :--- | :--- |
| **ACCESS-CORE-01** | VM | **Identity:** Authentik, FreeIPA, RADIUS <br> **Access:** Teleport, Guacamole | **RETAINED (Tier 0):** Critical layer. Authentication must function even if the K3s cluster is unavailable. |
| **EDGE-GW-01** | VM | **Edge Gateway:** Cloudflare Tunnel, Traefik | **RETAINED (Tier 1):** Ingress point. Independent gateway decoupled from K3s for stable external access. |
| **MGMT-CORE-01** | VM | **Management:** Ansible, Terraform, Semaphore, GitHub Runner, Portainer | **RETAINED (Tier 2):** Management plane. Must not run within the infrastructure it manages. |
| **K3S-SERVER-01** | VM | **Apps:** Vaultwarden, Monitoring (Prometheus/Grafana), Nextcloud, Media-stack (Arr suite), Notifications, Dashboard | **CONSOLIDATED (K3s):** All application containers are hosted here, isolated by Kubernetes Namespaces for resource optimization. |
| **DNS-201** | LXC | Bind9 (Internal DNS) | **Tier 0:** Core network service. |
| **UNBOUND-223** | LXC | Unbound (Recursive DNS) | **Tier 0:** Secure, recursive name resolution. |
| **ADGUARD-222** | LXC | AdGuard Home (Filtering) | **Tier 0:** Network-wide ad-blocking and local DNS protection. |
| **JELLYFIN-221** | LXC | Jellyfin (Media Server) | **Tier 5:** Hosted in LXC for stable GPU Passthrough (hardware transcoding). |
| **APT-CACHER-207**| LXC | APT Cacher NG | **Tier 3:** Local update proxy for all VMs and LXC containers. |

---

### Key Architectural Principles

#### 🛡️ Failure Domain Separation
The core networking layer (DNS, Gateway) and the Identity layer (Authentik, Teleport) reside on independent virtual machines. This ensures that a Kubernetes update failure or a misconfigured YAML file does not lead to a total network blackout.

#### ⚙️ Infrastructure as Code (IaC)
Provisioning and configuration management for all hosts (VM/LXC) are handled via **Ansible** and **Terraform** running on `MGMT-CORE-01`. This guarantees reproducibility and version-controlled infrastructure.

#### 🌐 Edge Security & Connectivity
External access is provided by **Cloudflare Tunnels**, eliminating the need for open ports on the firewall. Internal SSL termination and **Forward Auth** redirection to Authentik are managed by a dedicated **Traefik** instance, which operates independently of the Kubernetes Ingress Controller.

#### 🔌 Hardware Passthrough
The media stack (Jellyfin) is purposefully kept in an LXC container. This approach allows for a simpler and more stable direct GPU access through the host kernel, avoiding the complexity of Kubernetes Device Plugins for hardware acceleration.

---

<a name="docker"></a>

## 1.3 Docker

---

### 1.3.1 Why Docker?

- **Kernel Independence:** While using LXC, I frequently encountered issues where specific services only ran stably on certain Linux kernel versions. Host updates often broke these services, requiring reconfiguration. Docker’s isolation layer removes this direct dependency, significantly increasing system stability after kernel updates.

- **Deployment Complexity:** In contrast to LXC—where every application must be manually installed step-by-step within the OS—Docker uses pre-packaged images. This simplifies the deployment process by eliminating the need to manually manage individual dependencies.

---

<a name="k3s"></a>

## 1.4 K3s (Lightweight Kubernetes)

---
← [Back to Homelab main page](../README_EN.md)

