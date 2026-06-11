← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# IaC

---

## Gyorsnavigáció
A projekt kódja az alábbi főbb mappákban található:
- [**Terraform**](./terraform/) – VM-ek létrehozása Proxmoxon.
- [**Ansible**](./ansible/) – Konfigurációs menedzsment, szerepkörök és telepítési folyamatok.
- [**Kubernetes**](./kubernetes/) – GitOps alapú konténer-vezérlés és automatizált deployment (K3s, ArgoCD).
- [**Secrets**](./secrets/) – SOPS + AGE titkosított változók és kulcskezelés.
- [**Renovate**](./renovate.json) – Infrastruktúra és függőségek automatizált verziókövetése, Pull Request alapú frissítéskezelés (Docker, K3s).

---

## 📚 Tartalomjegyzék

- [Projektfilozófia & Megközelítés](#filo)
- [Technológiai Stack](#stack)
- [Architektúra áttekintés](#archit)
- [Repó struktúra](#repstr)
- [Teljes deployment workflow](#depwork)
- [Futó workload-ok](#wrkld)
- [Secrets kezelés](#seckez)
- [Monitoring](#monitor)
- [Jelenlegi állapot & további tervek](#tervek)

---

<a name="filo"></a>

## Projektfilozófia & Megközelítés

**Hibrid megközelítést** alkalmazok — szándékosan.

- **Automatizált platform:** A VM-ek egy részének létrehozása, az OS konfigurációja, a szoftverek telepítése és a K3s cluster felállítása teljesen automatizált (Terraform + Ansible).
- **Hibrid konfigurációs modell:** A Kubernetes applikációk beállításait, konfigfájlokat NAS-ról szinkronizálom, hogy a környezet konzisztenciáját megőrizzem, miközben folyamatosan fejlesztem a rendszert tisztán GitOps-alapú kezelés irányába.

Ez a megoldás lehetővé teszi, hogy gyorsan újraépítsem bármelyik VM-et, miközben a működő alkalmazásokhoz szükséges adatok és beállítások azonnal rendelkezésre állnak.

**Kontextus:** Jelenleg **1 Proxmox fizikai szerver** fut, a K3s **single-node** (tehát nem HA-klaszter), a persistent storage **local-path** (nem Longhorn/NAS-ra mountolt PVC). Az appok konfigurációját **nem GitOps-ból állítom elő nulláról**, hanem a kézzel beállított, NAS-ra mentett konfigfájlokat állítja vissza a workflow. Ez tudatos döntés, de később változtatni kívánok rajta.

---

<a name="stack"></a>

## Technológiai Stack

| Réteg | Eszköz |
|---|---|
| **IaC & Provisioning** | Terraform (VM provisioning), Ansible (OS konfiguráció, userek, mountok, alkalmazások stb.) |
| **Container Orchestration** | K3s (Lightweight Kubernetes) |
| **CI/CD** | GitHub Actions (self-hosted runner, privát hálózaton) |
| **GitOps** | ArgoCD |
| **Kubernetes Management** | K9s, Lens |
| **Storage** | Local-path (tervben: Longhorn / NAS-alapú PVC) |
| **Secrets Management** | GitHub Actions Secrets, SOPS + AGE |

---

<a name="archit"></a>

## Architektúra áttekintés

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
│  │  /mnt/backup/app-configs-backup/  ← mentett konfigok         │   │
│  │  /mnt/torrent,  /mnt/pxeiso                                  │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

<a name="repstr"></a>

## Repó struktúra

```
.
├── terraform/
│   └── proxmox-deploy/     # VM-ek létrehozása/clonozása Proxmox-on
├── ansible/
│   ├── site.yml            # Fő playbook — fázisokra bontva
│   ├── roles/
│   │   ├── common/         # Alapozás: csomagok, user, SSH, időzóna
│   │   ├── mounts/         # NFS/SMB csatolások
│   │   ├── docker/         # Docker telepítése
│   │   ├── portainer_agent/# Portainer Agent (Docker hostokra)
│   │   ├── k3s_prep/       # K3s előkészítés: swap off, kernel modulok
│   │   ├── k3s_install/    # K3s binary + cluster init
│   │   ├── argocd/         # ArgoCD telepítése Helm-mel
│   │   ├── argocd_apps/    # ArgoCD Application-ök regisztrálása
│   │   ├── app_restore/    # Konfig visszaállítás NAS-ról (rsync)
│   │   ├── access_core_01/ # Teleport + Authentik (Docker Compose)
│   │   └── edge_gw_01/     # Traefik reverse proxy (Docker Compose)
│   └── secrets.enc.yaml    # SOPS+AGE titkosított változók
├── kubernetes/
│   └── apps/               # K8s manifest-ek (ArgoCD olvassa)
│       ├── media/          # Sonarr, Radarr, Prowlarr, Bazarr, qBittorrent, Seerr
│       ├── monitoring/     # Prometheus, Grafana, Uptime-Kuma
│       ├── storage/        # Nextcloud
│       ├── identity/       # Vaultwarden
│       ├── notification/   # Gotify
│       ├── dashboard/      # Homarr
│       ├── access/         # Guacamole
│       └── automation/     # Renovate (CronJob-al időzítve)
└── README.md
```

---

<a name="depwork"></a>

## Teljes deployment workflow

### 1. fázis — VM-ek létrehozása (Terraform)

A VM-eket egy általam előkészített **Golden Image** (Ubuntu 22.04, Proxmox cloud-init template) alapján hozom létre Full Clone módszerrel — az új VM-ek teljesen függetlenek az alap sablontól. A Terraform deklaratív módon definiálja az eltérő terhelésű csomópontok hardveres paramétereit (CPU, RAM, Disk). A Terraform **manuálisan, parancssorból kerül futtatásra** a `mgmt-core-01-204` menedzsment gépen, ahol CLI-ból vezérlem (init, plan, apply).

A Terraform konfigurációkat nem nulláról írtam meg: először a Proxmoxon kézzel elkészített Ubuntu template-et **importáltam** a Terraform state-be (`terraform import`), így a már létező erőforrás Terraform felügyelete alá került. Ezt az alap konfigurációt adaptáltam és bővítettem a különböző VM-típusokhoz (`k3s-server-01-225`, `access-core-01-206`, `edge-gw-01-230`), az eltérő hardverigények és szerepkörök szerint.

Kezelt VM-ek:

- `k3s-server-01-225` — K3s node
- `access-core-01-206` — Identity & Access layer (Teleport, Authentik, FreeRADIUS)
- `edge-gw-01-230` — Edge gateway (Traefik reverse proxy, Cloudflare Tunnel)
- `mgmt-core-01-204` — Management node (Self-hosted GitHub Runner, Ansible, Terraform, Portainer)

A Terraform `initialization` blokkján keresztül injektálja az SSH-kulcsokat és az Ansible usert — a VM az első bootja után azonnal "ready-to-use" állapotba kerül, manuális konfiguráció nélkül:

```hcl
user_account {
  keys     = [var.laptopom_pub, var.ansible_target_key_pub]
  password = var.ansible_user_pwd
  username = var.ans_username
}
```

A MAC-cím rögzítéssel biztosítom a statikus IP kiosztást a DHCP szerveren. Titkos értékek (Proxmox API token, jelszavak) `.tfvars` fájlban, verziókövetésen kívül tárolva.

---

### 2. fázis — Alap konfiguráció (Ansible `common` role)

Minden gépen lefut a GitHub Actions által indított pipeline első lépéseként:

| Feladat | Részlet |
|---|---|
| APT proxy | `apt-cacher-ng` (192.168.2.207) — gyorsítja a csomagletöltést |
| Alapcsomagok | `python3`, `curl`, `git`, `mc`, `prometheus-node-exporter` |
| `dist-upgrade` | Teljes rendszerfrissítés |
| User & SSH | User létrehozása, SSH kulcsok feltöltése, `PermitRootLogin no`, `PasswordAuthentication no` |
| SSH hardening | Banner, 900 mp-es shell timeout (`TMOUT`) |
| Időzóna | `Europe/Budapest` |
| Node Exporter (Prometheus) | Automatikus start + enable — minden gép monitorozva |

---

### 3. fázis — NAS csatolások (`mounts` role)

A K3s workload-ok és a backup folyamatok feltételezik a NAS elérhetőségét. Az Ansible ezt a K3s/Docker telepítés előtt végzi el minden érintett gépen:

- **NFS:** `/mnt/torrent` ← `192.168.2.220:/mnt/ssdpool/torrent`
- **SMB:** `/mnt/backup` ← `//192.168.2.220/backup` (konfig-backup forrás)
- **SMB:** `/mnt/pxeiso` ← `//192.168.2.220/pxeiso`

---

### 4. fázis — Réteg-specifikus telepítések

#### 4a. Edge Layer (`edge-gw-01-230`)

A Traefik **Docker Compose**-ban fut (nem K3s-en). Az Ansible:
1. Létrehozza a könyvtárstruktúrát (`/opt/app-data/edge-stack/traefik/`)
2. `rsync`-kel visszatölti a NAS-ról az elmentett Traefik konfigot (dinamikus route-ok, ACME cert)
3. Jinja2 template alapján generálja a statikus és dinamikus config fájlokat
4. Elindítja a Docker Compose stacket

#### 4b. Identity & Access Layer (`access-core-01-206`)

Szintén **Docker Compose** (Teleport + Authentik). Az Ansible:
1. Teleport GPG kulcs + APT repo hozzáadása, v18.7.4 telepítése
2. `rsync` a NAS-ról: Teleport state, Authentik DB + media
3. Systemd service konfigurálása, Teleport indítása
4. Authentik Docker Compose stack elindítása

#### 4c. K3s Node (`k3s-server-01-225`)

Az Ansible előkészíti a gépet (swap ki, szükséges kernel modulok be), majd egy egysoros installer scripttel telepíti a K3s-t. A beépített load balancert és Traefik-et kikapcsolom, mert az ingress forgalmat az `edge-gw-01-230`-on futó külön Traefik kezeli.

---

### 5. fázis — ArgoCD + konfig visszaállítás

#### ArgoCD (`argocd` role)

Helm-mel települ a saját namespace-be. A jelszó hash átadásával az ArgoCD első indulásakor már az előre beállított jelszóval rendelkezik — nincs szükség manuális resetelésre.

#### Konfig visszaállítás (`app_restore` role)

Az appok (Sonarr, Radarr, Prowlarr, Grafana, stb.) **nem üres állapotból indulnak**, hanem a NAS-ra korábban elmentett konfigurációjukból. A folyamat:

1. K3s leállítása (hogy ne írja felül a visszaállítandó adatokat)
2. Célkönyvtárak létrehozása a K3s node-on
3. `rsync` a NAS `/mnt/backup/app-configs-backup/` mappájából a lokális `/opt/app-data/` alá
4. Jogosultságok helyreállítása
5. K3s visszaindítása

#### ArgoCD Applications (`argocd_apps` role)

Az ArgoCD regisztrálja a privát GitHub repót, majd létrehozza az Application objektumokat. Minden stack a repó egy-egy mappájára mutat, `automated` sync + `selfHeal` módban — ha a K8s manifest változik GitHubon, ArgoCD automatikusan szinkronizálja:

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

### 6. fázis — GitHub Actions + Self-hosted Runner

A `mgmt-core-01-204` VM-en fut a **self-hosted GitHub Actions runner**. A pipeline neve **Ansible Dispatcher**, és két triggerrel rendelkezik:

- **Automatikus (schedule):** minden nap 23:00-kor (UTC+2) lefuttatja a `system_update.yml` playbook-ot az összes node-ra.
- **Manuális (`workflow_dispatch`):** GitHub Actions felületéről indítható, három paraméterrel:

| Paraméter | Leírás |
|---|---|
| `playbook` | Melyik playbook fusson — pl. `full_site`, `k3s_full`, `common`, `argocd`, `system_update`, stb. |
| `target_hosts` | Melyik gép(ek)re fusson — pl. `all_nodes`, `host_k3s`, `host_edge`, `host_dns`, `lxc_nodes`, stb. |
| `dry_run` | Ha be van kapcsolva, `--check --diff` módban fut — nem változtat semmit, csak megmutatja mi változna |

A workflow a self-hosted runneren közvetlenül éri el a belső hálózatot — nincs szükség VPN-re vagy külső agent-re. Futás végén minden esetben **Gotify értesítés** megy: siker esetén ✅, hiba esetén ❌.

**SOPS+AGE titkosítás a pipeline-ban:** A `secrets.enc.yaml` fájl titkosítva van verziókövetésben. A workflow futáskor a `SOPS_AGE_KEY` GitHub Actions Secret-ből hozza létre az AGE kulcsfájlt (`keys.txt`), dekódolja a secrets fájlt, átadja az Ansible-nek, majd a futás végén mindkét fájlt törli.

---

<a name="wrkld"></a>

## Futó workload-ok

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

> **Storage:** Jelenleg `local-path` provisioner — a PVC-k a K3s node lokális lemezére kerülnek. A konfig adat a NAS-ról visszaállított rsync-másolat. Longhorn / NAS-alapú PVC migrációt tervezem a jövőre nézve.

### Docker Compose (K3s-en kívül)

| VM | App |
|---|---|
| `edge-gw-01-230` | Traefik (reverse proxy, Let's Encrypt) |
| `access-core-01-206` | Teleport (SSH/RDP proxy), Authentik (SSO/IdP) |

---

<a name="seckez"></a>

## Secrets kezelés

| Eszköz | Mit tárol |
|---|---|
| **SOPS+AGE** (`secrets.enc.yaml`) | SMB jelszó, user jelszó hash, SSH kulcsok, API tokenek — titkosítva verziókövetésben |
| **Terraform `.tfvars`** (nincs verziókövetésben) | Proxmox API token, MAC-címek, user jelszavak |
| **GitHub Actions Secrets** (`SOPS_AGE_KEY`) | Az AGE privát kulcs — ebből dekódolja a pipeline a `secrets.enc.yaml`-t futáskor |

A folyamat: a pipeline létrehozza a kulcsfájlt a Secretből → `sops -d` dekódolja a titkokat → Ansible megkapja `-e "@/tmp/secrets_dec.yaml"` formában → futás végén a kulcsfájl és a dekódolt fájl törlésre kerül.

---

<a name="monitor"></a>

## Monitoring

Minden VM-re települ a `prometheus-node-exporter` a `common` role részeként. A Prometheus fix targeteket olvas a `host_vars`-ból:

- `proxmox1` / `proxmox2` — a fizikai hypervisorok (node exporter + SMART)
- Összes VM — automatikusan monitorozva
- Grafana dashboardok a NAS-ról rsync-kel visszaállítva — az adatsource reconnect után azonnal működik

---

<a name="tervek"></a>

## Jelenlegi állapot & további tervek

- [x] Terraform-alapú VM provisioning (Proxmox)
- [x] Ansible roles minden VM-típushoz
- [x] Self-hosted GitHub Actions pipeline
- [x] K3s single-node + ArgoCD GitOps (manifest szintű)
- [x] Konfig-alapú visszaállítás (rsync a NAS-ról)
- [x] Monitoring (Prometheus + Grafana + Uptime-Kuma)
- [x] Identity/Access layer (Teleport + Authentik)
- [x] Edge layer (Traefik + Let's Encrypt)
- [ ] Az összes VM bevonása a Terraform + Ansible pipeline-ba
- [ ] NAS-ról betöltött konfigok teljes migrációja Kubernetes ConfigMap-ekbe/Secret-ekbe
- [ ] Longhorn vagy NFS-alapú PVC storage (local-path kiváltása)
- [ ] Terraform state remote backend (jelenleg local)
- [ ] Több node → K3s HA cluster

---

← [Vissza a Homelab főoldalra](../README_HU.md)
