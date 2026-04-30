← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# 1. Docker and K3S

---

## 1.1 📚 Tartalomjegyzék

- [1.2 Virtualizációs stratégia](#vs)
- [1.3 docker](#docker)
- [1.4 K3S](#k3s)

---

<a name="vs"></a>

### 1.2 Virtualizációs Stratégia

A kritikus azonosítási és hálózati rétegek tudatosan a **K3S-en kívül**, dedikált virtuális gépekben (VM) és konténerekben (LXC) futnak, megakadályozva a körkörös függőségek kialakulását.

| Hostnév | Típus | Stackek / Feladatok | Stratégia (Tier) |
| :--- | :--- | :--- | :--- |
| **ACCESS-CORE-01** | VM | **Identity:** Authentik, FreeIPA, RADIUS <br> **Access:** Teleport, Guacamole | **MARAD (Tier 0):** Kritikus réteg. Az azonosításnak akkor is futnia kell, ha a K3S fürt karbantartás alatt áll. |
| **EDGE-GW-01** | VM | **Edge Gateway:** Cloudflare Tunnel, Traefik | **MARAD (Tier 1):** Ingress pont. A K3S-től függetlenített gateway a stabil külső elérésért. |
| **MGMT-CORE-01** | VM | **Management:** Ansible, Terraform, Semaphore, GitHub Runner, Portainer | **MARAD (Tier 2):** Parancsnoki híd. Nem futhat abban az infrastruktúrában, amit vezérel és provizionál. |
| **K3S-SERVER-01** | VM | **Apps:** Vaultwarden, Monitoring (Prometheus/Grafana), Nextcloud, Media-stack (Arr appok), Notifications, Dashboard | **ÖSSZEVONT (K3S):** Minden alkalmazáskonténer ide került Kubernetes Namespace-ekre bontva az erőforrás-optimalizálás érdekében. |
| **DNS-201** | LXC | Bind9 (Internal DNS) | **Tier 0:** Alapvető hálózati szolgáltatás. |
| **UNBOUND-223** | LXC | Unbound (Recursive DNS) | **Tier 0:** Biztonságos, rekurzív névfeloldás. |
| **ADGUARD-222** | LXC | AdGuard Home (Filtering) | **Tier 0:** Hálózati szintű reklámszűrés és helyi DNS védelem. |
| **JELLYFIN-221** | LXC | Jellyfin (Media Server) | **Tier 5:** LXC-ben marad a stabil GPU Passthrough (hardveres transzkódolás) miatt. |
| **APT-CACHER-207**| LXC | APT Cacher NG | **Tier 3:** Helyi frissítési proxy az összes VM és LXC számára. |

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

<a name="k3s"></a>

## 1.4 K3s

---
← [Vissza a Homelab főoldalra](../README_HU.md)












