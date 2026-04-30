← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# 1. Docker and K3S

---

## 1.1 📚 Tartalomjegyzék

- [1.2 Virtualizációs stratégia](#vs)
- [1.3 Docker](#docker)
- [1.4 K3S](#k3s)

---

<a name="vs"></a>

### 1.2 Virtualizációs Stratégia

A kritikus azonosítási és hálózati rétegek tudatosan a **K3S-en kívül**, dedikált virtuális gépekben (VM) és konténerekben (LXC) futnak, megakadályozva a körkörös függőségek kialakulását.

| Hostnév | Típus | Stackek / Feladatok | Stratégia (Tier) |
| :--- | :--- | :--- | :--- |
| **ACCESS-CORE-01** | VM | **Identity:** Authentik, FreeIPA, RADIUS <br> **Access:** Teleport, Guacamole | **MARAD (Tier 0):** Kritikus réteg. Az azonosításnak akkor is futnia kell, ha a K3S fürt nem elérhető. |
| **EDGE-GW-01** | VM | **Edge Gateway:** Cloudflare Tunnel, Traefik | **MARAD (Tier 1):** Ingress pont. A K3S-től függetlenített gateway a stabil külső elérésért. |
| **MGMT-CORE-01** | VM | **Management:** Ansible, Terraform, Semaphore, GitHub Runner, Portainer | **MARAD (Tier 2):** Nem futhat abban az infrastruktúrában, amit vezérel. |
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

## 1.4 K3S (Kubernetes)

A projekt ezen része a dokumentációs adósság felszámolása érdekében született. A manuális alkalmazástelepítések és a felmerülő hibák egyedi dokumentálása hosszú távon fenntarthatatlanná vált, ezért álltam át az Infrastructure as Code (IaC) szemléletre. Ebben a megközelítésben a konfigurációk verziókövetett kód formájában léteznek, ami egyszerűbbé teszi az átláthatóságot és a hibakeresést.

### Motiváció és Megvalósítás

*   Átláthatóság: A manuális lépések helyett minden konfiguráció YAML manifestekben és Ansible role-okban van rögzítve.
*   Konténer-felügyelet: A K3s automatikusan kezeli az alkalmazások életciklusát, biztosítja az öngyógyító (self-healing) képességet és a belső hálózatot.
*   Reprodukálhatóság: A teljes környezet bármikor újraépíthető az Ansible playbookok segítségével, minimalizálva a manuális beavatkozás szükségességét[cite: 1].

### CI/CD: GitHub Actions és Self-hosted Runner

A folyamatos integrációt és kiterjesztést saját erőforrásokra alapoztam:

*   Self-hosted Runner: A GitHub Actions workflow-k nem külső felhőben, hanem a saját MGMT-CORE-01 menedzsment gépemen futnak[cite: 1].
*   Közvetlen elérés: A saját runner használata lehetővé teszi a belső hálózati szegmensek biztonságos elérését a deployment során.
*   Automata folyamatok: A kódbázis frissítésekor a runner aktiválódik, és az Ansible segítségével végrehajtja a szükséges módosításokat a fürtön vagy a Docker hostokon[cite: 1].

### Tárolás és Felépítés

*   Single-Node klaszter: Az erőforrás-optimalizálás érdekében a Kubernetes master és worker funkciók egyetlen virtuális gépen (K3S-SERVER-01) futnak[cite: 1].
*   Helyi adattárolás (Local Storage): Az alkalmazások perzisztens adatai – például a Guacamole adatbázis fájljai – a klaszter helyi meghajtóin tárolódnak hostPath alapú megoldással[cite: 1]. Ez alacsony késleltetést és egyszerű mentési folyamatokat biztosít.
*   Hiba-szeparáció: A kritikus hálózati alapkövek (DNS, Identity) tudatosan a K3s-en kívül maradtak, megakadályozva a körkörös függőségek kialakulását[cite: 1].

### Alkalmazott technológiák

| Technológia | Feladat |
| :--- | :--- |
| K3s | Pehelysúlyú Kubernetes disztribúció a konténerek kezeléséhez. |
| GitHub Actions | Pipeline-ok és automatizált munkafolyamatok vezérlése. |
| Self-hosted Runner | Saját infrastruktúrán futó végrehajtó környezet a pipeline-okhoz[cite: 1]. |
| Ansible | A virtuális gépek és a K3s fürt automatizált felkészítése és telepítése[cite: 1]. |
| Local Path Provisioner | Dinamikus helyi tárhely-kezelés az alkalmazások adatai számára[cite: 1]. |

---
← [Vissza a Homelab főoldalra](../README_HU.md)














