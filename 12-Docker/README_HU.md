← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# 1. Docker and K3S

---

## 1.1 📚 Tartalomjegyzék

- [1.2 Virtualizációs stratégia](#vs)
- [1.3 Docker](#docker)

---

<a name="vs"></a>

### 1.2 Virtualizációs Stratégia

A kritikus azonosítási és hálózati rétegek tudatosan a **K3S-en kívül**, dedikált virtuális gépekben (VM) és konténerekben (LXC) futnak, megakadályozva a körkörös függőségek kialakulását.

| Hostnév | Típus | Stackek / Feladatok | Stratégia (Tier) |
| :--- | :--- | :--- | :--- |
| **ACCESS-CORE-01** | VM | **Identity:** Authentik, Freeradius <br> **Access:** Teleport, Guacamole | **MARAD (Tier 0):** Kritikus réteg. Ha a K3S-t bütykölöd, az azonosításnak mennie kell. |
| **FREEIPA-210** | VM | Freeipa | |
| **EDGE-GW-01** | VM | Cloudflare Tunnel, Traefik | |
| **MGMT-CORE-01** | VM | Ansible, Terraform, Semaphore, GitHub Runner, management-stack (Portainer) | **MARAD (Tier 2):** Ez a parancsnoki híd, nem futhat abban, amit vezérel. |
| **WAZUH-SERVER-01-203** | VM | Wazuh | |
| **K3S-SERVER-01** | VM (ÚJ) | identity-stack (Vaultwarden) monitoring-stack (Prometheus, Grafana, Uptime Kuma) storage-stack (Nextcloud) media-stack (Sonarr, Radarr, qBit, Prowlarr, Bazarr, Seerr) notifications-stack (Gotify) dashboard-stack (Homarr) admin-stack (Renovate) | **ÖSSZEVONT:** Itt fut minden Docker konténer Namespace-ekre bontva. |
| **DNS-201** | LXC | Bind9 (Internal DNS) | **MARAD (Tier 0):** Alapvető hálózati szolgáltatás. |
| **UNBOUND-223** | LXC | Unbound (Recursive DNS) | **MARAD (Tier 0):** Kell a biztonságos névfeloldáshoz. |
| **ADGUARDHOME-222** | LXC | AdGuard Home (Filtering) | **MARAD (Tier 0):** Hogy ne haljon meg a net, ha a K3S épp frissül. |
| **JELLYFIN-221** | LXC | Jellyfin (GPU Passthrough) | **MARAD (Tier 5):** A hardveres gyorsítás LXC-ben a legegyszerűbb. |
| **APT-CACHER-NG-207** | LXC | APT Cacher NG | **MARAD (Tier 3):** Kiszolgálja az összes VM-et és LXC-t. |

### Failure Domain Separation (Hiba-szeparáció)
A hálózati alapréteg (DNS, Gateway) és az Identity réteg (Authentik, Teleport) különálló virtuális gépeken fut. Ez garantálja, hogy egy esetleges Kubernetes frissítési hiba vagy egy rosszul konfigurált YAML fájl nem okoz teljes hálózati sötétséget (blackout).

### Infrastructure as Code (IaC)
Az összes gazdagép (VM/LXC) provizionálása és konfigurációmenedzsmentje az `MGMT-CORE-01` gépen futó **Ansible** és **Terraform** segítségével történik. Ez biztosítja a reprodukálhatóságot és a verziókövetett infrastruktúrát.

### Edge Security & Connectivity
A külső elérést **Cloudflare Tunnel** biztosítja, így nincs szükség nyitott portokra a tűzfalon. A belső SSL terminálást és a **Forward Auth** irányítást az Authentik felé a dedikált **Traefik** példány végzi, amely független a Kubernetes-ben futó Ingress Controller-től.

### Hardware Passthrough
A média-stack (Jellyfin) tudatosan LXC konténerben maradt. Ez a megoldás egyszerűbb és stabilabb GPU-hozzáférést tesz lehetővé a gazdagép kernelén keresztül.

---

<a name="docker"></a>

## 1.3 Docker

---

### 1.3.1 Miért Docker

- **Kernel-függetlenség**: LXC használata mellett többször belefutottam olyan hibákba, ahol egy-egy szolgáltatás csak meghatározott Linux kernel-verzión futott stabilan. A gazdagép frissítése után a szolgáltatások gyakran megálltak vagy újra kellett konfigurálni őket. A Docker izolációs rétege megszünteti ezt a közvetlen függőséget, így a rendszer stabilabb marad kernel-frissítések után is.

- **Telepítési komplexitás**: Míg LXC-ben minden alkalmazást manuálisan, lépésről lépésre kell telepíteni az OS-en belül, a Docker-nél az előre csomagolt image-ek  leegyszerűsítik a folyamatot. Nincs szükség a függőségek egyenkénti vadászatára.

---
← [Vissza a Homelab főoldalra](../README_HU.md)














