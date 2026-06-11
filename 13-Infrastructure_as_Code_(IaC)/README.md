← [Back to Homelab main page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# IaC

The goal is to continuously evolve my homelab as a learning environment for implementing and documenting Infrastructure as Code (IaC) practices.

---

## 📚 Table of Contents

- [Project Philosophy & Approach](#philosophy)
- [Technology Stack](#stack)
- [Architecture Overview](#architecture)
- [Repository Structure](#repo-structure)
- [Full Deployment Workflow](#workflow)
- [Running Workloads](#workloads)
- [Secrets Management](#secrets)
- [Monitoring](#monitoring)
- [Current Status & Roadmap](#roadmap)

---

<a name="philosophy"></a>

## Project Philosophy & Approach

I use a **hybrid approach** — intentionally.

- **Automated platform:** VM provisioning, OS configuration, software installation and K3s cluster setup are fully automated (Terraform + Ansible).
- **Hybrid config model:** Application configs are synced from NAS to maintain environment consistency, while I gradually migrate everything toward a pure GitOps-managed state.

This allows me to rebuild any VM quickly, while all application data and configurations are immediately available.

**Context:** Currently running **1 Proxmox physical server**, K3s is **single-node** (not HA), persistent storage is **local-path** (not Longhorn/NAS-backed PVC). Application configs are **not provisioned from scratch via GitOps** — instead, the pipeline restores previously saved configs from the NAS. This is a deliberate decision.

---

<a name="stack"></a>

## Technology Stack

| Layer | Tool |
|---|---|
| **IaC & Provisioning** | Terraform (VM provisioning), Ansible (OS config, users, mounts, apps, etc.) |
| **Container Orchestration** | K3s (Lightweight Kubernetes) |
| **CI/CD** | GitHub Actions (self-hosted runner on the private network) |
| **GitOps** | ArgoCD |
| **Kubernetes Management** | K9s, Lens |
| **Storage** | Local-path (planned: Longhorn / NAS-backed PVC) |
| **Secrets Management** | GitHub Actions Secrets, SOPS + AGE |

---

<a name="architecture"></a>

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Proxmox1 Hypervisor                          │
│                                                                     │
│  ┌─────────────────────┐  ┌──────────────────────────────────────┐  │
│  │ mgmt-core-01-204    │  │ k3s-server-01-225  (K3s single-node) │  │
│  │                     │  │                                      │  │
│  │ Ansible, Terraform  │  │ ArgoCD                               │  │
│  │ Semaphore (Docker)  │  │ identity-stack  (Vaultwarden)        │  │
│  │ GitHub Runner       │  │ monitoring-stack(Prometheus, Grafana,│  │
│  │ Portainer (Docker)  │  │                 Uptime-Kuma)         │  │
│  │                     │  │ storage-stack   (Nextcloud)          │  │
│  └─────────────────────┘  │ media-stack     (Sonarr, Radarr,     │  │
│                           │                 qBit, Prowlarr,      │  │
│  ┌─────────────────────┐  │                 Bazarr, Seerr)       │  │
│  │ access-core-01-206  │  │ notif-stack     (Gotify)             │  │
│  │                     │  │ dashboard-stack (Homarr)             │  │
│  │ Authentik (Docker)  │  │ admin-stack     (Renovate)           │  │
│  │ Teleport            │  │ access-stack    (Guacamole)          │  │
│  │ FreeRADIUS          │  │                                      │  │
│  │ Portainer Agent     │  └──────────────────────────────────────┘  │
│  │                     │                                            │
│  └─────────────────────┘  ┌──────────────────────────────────────┐  │
│                           │ edge-gw-01-230                       │  │
│                           │                                      │  │
│                           │ Traefik (Docker)                     │  │
│                           │ Cloudflare Tunnel                    │  │
│                           │ Portainer Agent                      │  │
│                           │                                      │  │
│                           └──────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  NAS (192.168.2.220)  — NFS + SMB                            │   │
│  │  /mnt/backup/app-configs-backup/  ← saved configs            │   │
│  │  /mnt/torrent,  /mnt/pxeiso                                  │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

<a name="repo-structure"></a>

## Repository Structure

```
.
├── terraform/
│   └── proxmox-deploy/     # VM provisioning / cloning on Proxmox
├── ansible/
│   ├── site.yml            # Main playbook — split into phases
│   ├── roles/
│   │   ├── common/         # Base setup: packages, user, SSH, timezone
│   │   ├── mounts/         # NFS/SMB mounts
│   │   ├── docker/         # Docker installation
│   │   ├── portainer_agent/# Portainer Agent (for Docker hosts)
│   │   ├── k3s_prep/       # K3s prep: swap off, kernel modules
│   │   ├── k3s_install/    # K3s binary + cluster init
│   │   ├── argocd/         # ArgoCD installation via Helm
│   │   ├── argocd_apps/    # ArgoCD Application registration
│   │   ├── app_restore/    # Config restore from NAS (rsync)
│   │   ├── access_core_01/ # Teleport + Authentik (Docker Compose)
│   │   └── edge_gw_01/     # Traefik reverse proxy (Docker Compose)
│   └── secrets.enc.yaml    # SOPS+AGE encrypted variables
├── kubernetes/
│   └── apps/               # K8s manifests (read by ArgoCD)
│       ├── media/          # Sonarr, Radarr, Prowlarr, Bazarr, qBittorrent, Seerr
│       ├── monitoring/     # Prometheus, Grafana, Uptime-Kuma
│       ├── storage/        # Nextcloud
│       ├── identity/       # Vaultwarden
│       ├── notification/   # Gotify
│       ├── dashboard/      # Homarr
│       ├── access/         # Guacamole
│       └── automation/     # Renovate (scheduled via CronJob)
└── README.md
```

---

<a name="workflow"></a>

## Full Deployment Workflow

### Phase 1 — VM Provisioning (Terraform)

VMs are created as Full Clones from a **Golden Image** I prepared (Ubuntu 22.04, Proxmox cloud-init template) — new VMs are completely independent from the base template. Terraform declaratively defines hardware parameters (CPU, RAM, Disk) for each node. **Terraform is run manually from the CLI** on the `mgmt-core-01-204` management machine (init, plan, apply).

The Terraform configurations were not written from scratch: I first **imported** the manually created Ubuntu template from Proxmox into the Terraform state (`terraform import`), bringing the existing resource under Terraform management. I then adapted and extended this base configuration for each VM type (`k3s-server-01-225`, `access-core-01-206`, `edge-gw-01-230`), adjusting hardware parameters and roles accordingly.

Managed VMs:

- `k3s-server-01-225` — K3s node
- `access-core-01-206` — Identity & Access layer (Teleport, Authentik, FreeRADIUS)
- `edge-gw-01-230` — Edge gateway (Traefik reverse proxy, Cloudflare Tunnel)
- `mgmt-core-01-204` — Management node (Self-hosted GitHub Runner, Ansible, Terraform, Portainer)

SSH keys and the Ansible user are injected via the Terraform `initialization` block — the VM is ready for Ansible immediately after first boot, no manual steps required:

```hcl
user_account {
  keys     = [var.laptopom_pub, var.ansible_target_key_pub]
  password = var.ansible_user_pwd
  username = var.ans_username
}
```

Static IP assignment is guaranteed by pinning MAC addresses on the DHCP server. Secrets (Proxmox API token, passwords) are stored in a `.tfvars` file, outside version control.

---

### Phase 2 — Base Configuration (Ansible `common` role)

Runs on every machine as the first step of the GitHub Actions-triggered pipeline:

| Task | Detail |
|---|---|
| APT proxy | `apt-cacher-ng` (192.168.2.207) — speeds up package downloads |
| Base packages | `python3`, `curl`, `git`, `mc`, `prometheus-node-exporter` |
| `dist-upgrade` | Full system upgrade |
| User & SSH | User creation, SSH key upload, `PermitRootLogin no`, `PasswordAuthentication no` |
| SSH hardening | Login banner, 900s shell timeout (`TMOUT`) |
| Timezone | `Europe/Budapest` |
| Prometheus Node Exporter | Auto-start + enable — every machine is monitored |

---

### Phase 3 — NAS Mounts (`mounts` role)

K3s workloads and backup processes depend on NAS availability. Ansible handles this on every affected machine before K3s/Docker installation:

- **NFS:** `/mnt/torrent` ← `192.168.2.220:/mnt/ssdpool/torrent`
- **SMB:** `/mnt/backup` ← `//192.168.2.220/backup` (config backup source)
- **SMB:** `/mnt/pxeiso` ← `//192.168.2.220/pxeiso`

---

### Phase 4 — Layer-specific Installations

#### 4a. Edge Layer (`edge-gw-01-230`)

Traefik runs in **Docker Compose** (not on K3s). Ansible:
1. Creates the directory structure (`/opt/app-data/edge-stack/traefik/`)
2. Restores the saved Traefik config from NAS via `rsync` (dynamic routes, ACME cert)
3. Generates static and dynamic config files from Jinja2 templates
4. Starts the Docker Compose stack

#### 4b. Identity & Access Layer (`access-core-01-206`)

**Docker Compose** (Authentik) + **systemd** (Teleport) + **native APT** (FreeRADIUS + daloRADIUS). Ansible handles:

**Teleport:**
1. GPG key + APT repo added, v18.7.4 installed
2. `rsync` from NAS: `data/` restored (`.sock` files excluded)
3. Config generated from Jinja2 template, systemd service configured, Teleport started

**Authentik:**
1. `rsync` from NAS: PostgreSQL `db_data/` + `config/` (media, custom-templates) restored
2. Permissions fixed (DB: `999:999`, `0700`)
3. Docker Compose stack started (`pull: always`, `recreate: always`)

**FreeRADIUS + daloRADIUS:**
1. APT dependencies installed: Apache2, PHP, MariaDB, FreeRADIUS (with MySQL + LDAP modules)
2. **Smart restore** — checks in order what's available on the NAS:
   - If `radius_configs_backup.tar.gz` exists → full config restore (`unarchive`)
   - If `radius_db_backup.sql` exists → database restore (imported from `mysqldump`)
   - If neither exists → fresh install: schema import, SQL module config, daloRADIUS repo cloned from GitHub
3. Apache vhosts configured: operators interface (`:8000`), users interface (`:80`)
4. **Auto-backup at the end of the run:** the role finishes by packing FreeRADIUS + daloRADIUS + Apache configs into a `tar.gz` and dumping the database via `mysqldump` to the NAS — so there's always a restore point for the next run

#### 4c. K3s Node (`k3s-server-01-225`)

Ansible prepares the machine (swap off, required kernel modules loaded), then installs K3s with a one-liner installer script. The built-in load balancer and Traefik are disabled — ingress traffic is handled by the dedicated Traefik instance on `edge-gw-01-230`.

---

### Phase 5 — ArgoCD + Config Restore

#### ArgoCD (`argocd` role)

Installed via Helm into its own namespace. The password hash is passed in so ArgoCD starts up with the pre-configured password — no manual reset needed.

#### Config Restore (`app_restore` role)

Apps (Sonarr, Radarr, Prowlarr, Grafana, etc.) **don't start from a blank state** — they're restored from configs previously saved to the NAS. The process:

1. Stop K3s (to prevent it from overwriting data being restored)
2. Create target directories on the K3s node
3. `rsync` from NAS `/mnt/backup/app-configs-backup/` to local `/opt/app-data/`
4. Restore file permissions
5. Start K3s

#### ArgoCD Applications (`argocd_apps` role)

ArgoCD registers the private GitHub repo and creates Application objects. Each stack points to a folder in the repo, running in `automated` sync + `selfHeal` mode — any manifest change on GitHub is automatically synced:

| ArgoCD Application | GitHub path | K8s namespace |
|---|---|---|
| `media-stack` | `kubernetes/apps/media` | `media` |
| `monitoring-stack` | `kubernetes/apps/monitoring` | `monitoring` |
| `storage-stack` | `kubernetes/apps/storage` | `storage` |
| `identity-stack` | `kubernetes/apps/identity` | `identity` |
| `notification-stack` | `kubernetes/apps/notification` | `notification` |
| `dashboard-stack` | `kubernetes/apps/dashboard` | `dashboard` |
| `access-stack` | `kubernetes/apps/access` | `access` |
| `automation-stack` | `kubernetes/apps/automation` | `automation` |

---

### Phase 6 — GitHub Actions + Self-hosted Runner

The **self-hosted GitHub Actions runner** runs on `mgmt-core-01-204`. The pipeline is called **Ansible Dispatcher** and has two triggers:

- **Automatic (schedule):** runs `system_update.yml` against all nodes every day at 23:00 (UTC+2).
- **Manual (`workflow_dispatch`):** launched from the GitHub Actions UI with three parameters:

| Parameter | Description |
|---|---|
| `playbook` | Which playbook to run — e.g. `full_site`, `k3s_full`, `common`, `argocd`, `system_update`, etc. |
| `target_hosts` | Which machine(s) to target — e.g. `all_nodes`, `host_k3s`, `host_edge`, `host_dns`, `lxc_nodes`, etc. |
| `dry_run` | If enabled, runs in `--check --diff` mode — makes no changes, only shows what would change |

The workflow runs on the self-hosted runner with direct access to the internal network — no VPN or external agent required. A **Gotify notification** is sent after every run: ✅ on success, ❌ on failure.

**SOPS+AGE encryption in the pipeline:** The `secrets.enc.yaml` file is stored encrypted in version control. At runtime, the workflow creates the AGE key file from the `SOPS_AGE_KEY` GitHub Actions Secret, decrypts the secrets file, passes it to Ansible, then deletes both files at the end of the run.

---

### Phase 7 — Backup (`backup` role)

The `backup` role can be run standalone from the Dispatcher (`playbook: backup`, with target host selection), and executes different logic per machine type — `main.yml` decides which task file to load based on `inventory_hostname`.

#### `access-core-01-206`
1. Stop Docker containers
2. `rsync` `/opt/app-data/` into a **date-stamped folder** on the NAS (`app-configs-backup-YYYY-MM-DD/`)
3. Restart Docker containers
4. Pack FreeRADIUS + daloRADIUS + Apache configs into a `tar.gz` inside the date-stamped folder
5. Dump the RADIUS database via `mysqldump`

#### `edge-gw-01-230`
1. Stop Docker containers
2. `rsync` `/opt/app-data/` into a **date-stamped folder** on the NAS (`app-configs-backup-YYYY-MM-DD/`)
3. Restart Docker containers

#### `k3s-server-01-225`
For K3s, simply stopping Docker isn't enough — pods need to be gracefully shut down to ensure data is backed up in a consistent state:
1. Collect all application namespaces (system namespaces excluded)
2. Scale all Deployments and StatefulSets to `replicas=0`
3. Wait for all pods to fully terminate (`kubectl wait`)
4. `rsync` `/opt/app-data/` into a **date-stamped folder** on the NAS (`.sock` and `admin-stack/` excluded)
5. Scale Deployments and StatefulSets back to `replicas=1`
6. Wait for pods to reach `Ready` state (`kubectl wait --for=condition=Ready`)

---

<a name="workloads"></a>

## Running Workloads

### K3s (single-node, local-path storage)

| Stack | App |
|---|---|
| media | Sonarr, Radarr |
| media | Prowlarr, Bazarr |
| media | qBittorrent |
| media | Seerr |
| monitoring | Prometheus |
| monitoring | Grafana |
| monitoring | Uptime-Kuma |
| storage | Nextcloud + DB |
| identity | Vaultwarden |
| notification | Gotify |
| dashboard | Homarr |
| access | Guacamole + DB |
| automation | Renovate |

> **Storage:** Currently using the `local-path` provisioner — PVCs land on the K3s node's local disk. Config data is the rsync-restored copy from NAS. Migration to Longhorn / NAS-backed PVCs is planned.

### Docker Compose (outside K3s)

| VM | App |
|---|---|
| `edge-gw-01-230` | Traefik (reverse proxy, Let's Encrypt) |
| `access-core-01-206` | Teleport (SSH/RDP proxy), Authentik (SSO/IdP), FreeRADIUS (RADIUS server), daloRADIUS (web admin UI) |

---

<a name="secrets"></a>

## Secrets Management

| Tool | What it stores |
|---|---|
| **SOPS+AGE** (`secrets.enc.yaml`) | SMB passwords, user password hashes, SSH keys, API tokens — stored encrypted in version control |
| **Terraform `.tfvars`** (not version-controlled) | Proxmox API token, MAC addresses, user passwords |
| **GitHub Actions Secrets** (`SOPS_AGE_KEY`) | The AGE private key — used by the pipeline to decrypt `secrets.enc.yaml` at runtime |

The flow: the pipeline creates the key file from the Secret → `sops -d` decrypts the secrets → Ansible receives them via `-e "@/tmp/secrets_dec.yaml"` → both the key file and decrypted file are deleted at the end of the run.

---

<a name="monitoring"></a>

## Monitoring

`prometheus-node-exporter` is installed on every VM as part of the `common` role. Prometheus reads fixed targets from `host_vars`:

- `proxmox1` / `proxmox2` — physical hypervisors (Prometheus Node Exporter + SMART)
- All VMs — automatically monitored
- Grafana dashboards restored from NAS via rsync — fully functional immediately after datasource reconnect

---

<a name="roadmap"></a>

## Current Status & Roadmap

- [x] Terraform-based VM provisioning (Proxmox)
- [x] Ansible roles for every VM type
- [x] Self-hosted GitHub Actions pipeline
- [x] K3s single-node + ArgoCD GitOps (manifest level)
- [x] Config-based restore (rsync from NAS)
- [x] Monitoring (Prometheus + Grafana + Uptime-Kuma)
- [x] Identity/Access layer (Teleport + Authentik)
- [x] Edge layer (Traefik + Let's Encrypt)
- [ ] Bring all remaining VMs into the Terraform + Ansible pipeline
- [ ] Migrate NAS-loaded configs fully into Kubernetes ConfigMaps/Secrets
- [ ] Longhorn or NAS-backed PVC storage (replace local-path)
- [ ] Terraform remote state backend (currently local)
- [ ] Multi-node → K3s HA cluster

---

← [Back to Homelab main page](../README.md)
