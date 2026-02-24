← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Tervezési döntések és érvek

Itt bemutatom, hogy miért esett a döntésem bizonyos technológiákra és architektúrákra.

---
## 1TB-os M.2 SSD-n Proxmox és VM-ek közösen, később ezt szétválasztom és Proxmox kerül a 250 GB SSD-re míg VM-ek gyors 1 TB-os M.2 SSD-re

- **Helyspórolás**: Így Clonezilla mentés csak a 250 GB-os Proxmox-ot tartalmazó SSD-ről szükséges. A VM-eket a Proxmox Backup Server (PBS) menti, róluk szükségtelen Clonezilla mentés. Eredmény gyorsabb és kevesebb tárhelyet igénylő mentés.
- **I/O terhelés szétválasztása**: a Proxmox host és a VM-ek is végeznek I/O műveleteket. Ha egy lemezen lennének, a terhelés összeadódna, külön SSD-vel pedig a műveletek eloszlanak, ami stabilabb és gyorsabb rendszert biztosít.
---
## FreeFileSync lecserélése Restic-re

  - Az új laptopomon lévő fontos fájlaimról **Restic** segítségével készítek biztonsági mentést a TrueNAS szerverre.
  - Miért Restic:
    - **Biztonságos**: Restic-nél a véletlen forrásfájl törlés esetén visszaállítható a törölt fájl, míg FreeFileSync-nél, ha a forrásfájl törlése után véletlen szinkronizálok, akkor nem tudom visszaállítani a fájlt.
    - **Verziózás**: akár korábbi állapotok is visszaállíthatók.
    - **Hatékony**: tömörít, gyors, FreeFileSync sokkal lassabban ellenőrizte le a változásokat és lassabban másolta  a megváltozott fájlokat.
---
## Miért Nextcloud?

- Self-hosted fájl- és képkezelés  
- Nem szükséges Google Drive / más felhő, Nextcloud a saját Google Drive-om
- Teljes kontroll és biztonság  
---
## Miért Vaultwarden?

- Self-hosted jelszókezelés  
- Jelszavak nem kerülnek ki az internetre  
- Teljes kontroll és biztonság  
---
## Minden szolgáltatást, amit tudok, LXC-ként futtatok, minden szolgáltatás külön LXC-n fut

A fő cél, hogy **minden szolgáltatás külön LXC-ben fusson**, így izoláltak: ha egy konténer leáll, az **nem érinti a többi szolgáltatást**.

**Előnyök LXC használatával VM-ekhez képest:**
- **Kisebb erőforrásigény**: kevesebb RAM és CPU szükséges, gyorsabb indítás
- **Gyorsabb deployment**: új konténerek percek alatt létrehozhatók
- **Skálázhatóság**: több konténer fér el egy hoston, mint VM
- **Izoláció**: hibás vagy leállt szolgáltatás nem állítja le a többit

---

## Mountolási stratégiám

- Proxmox1 node-on nincsen disk passthrough
- Proxmox2 node-on fut van 2 disk passthrough (TrueNAS-nak és Proxmox Backup Servernek)
- Proxmox hosthoz csatolom a TrueNAS megosztásokat, hogy továbbadja az unprivileged LXC-nek.
- VM esetében az fstab segítségével mountolom a VM-hez közvetlenül a TrueNAS megosztásokat és nem a Proxmox adja tovább.

```mermaid
flowchart TB
    %% Smooth lines
    linkStyle default interpolate basis

    %% Top row: Proxmox nodes side by side
    subgraph PROXMOX["Proxmox Nodes"]
        direction LR
        PVE1["Proxmox1"]
        PVE2["Proxmox2"]
    end

    %% Passthrough disks going directly to VMs (middle layer)
    SSD_TRUENAS["SSD Passthrough → TrueNAS (VM)"]
    SSD_PBS["Disk Passthrough → PBS (VM)"]

    %% Passthrough connections (PVE2 only)
    PVE2 --> SSD_TRUENAS
    PVE2 --> SSD_PBS

    %% TrueNAS storage exports
    SSD_TRUENAS --> NFS["NFS Share: torrent"]
    SSD_TRUENAS --> SMB1["SMB Share: backup"]
    SSD_TRUENAS --> SMB2["SMB Share: pxeiso"]
    SSD_TRUENAS --> SMB3["SMB Share: telefon"]

    %% Proxmox1 mounts for LXCs
    PVE1 -.->|Storage mount| NFS
    PVE1 -.->|Storage mount| SMB1

    %% Consumers (bottom row)
    subgraph CONSUMERS["VM/LXC Consumers"]
        direction LR
        JELLY["LXC 1010 Jellyfin\nProxmox-mounted"]
        DOCKER["VM 1102 platform-docker-01\nfstab mount"]
        RESTIC["LXC 1008 Restic\nProxmox-mounted"]
        PXEVM["VM 209 PXEBoot\nfstab mount"]
    end

    %% Storage → Consumers connections
    NFS ==>|fstab| DOCKER
    NFS --> JELLY
    SMB1 --> RESTIC
    SMB2 ==>|fstab| PXEVM
    
    %% Note for clarity
    classDef fstab fill:#f96,stroke:#333,stroke-width:2px;
    class DOCKER,PXEVM fstab;
```

---

## Bind9, AdGuard Home, Unbound cache és TTL stratégiája

**BIND9 (Lokális autoritatív forrás):**
- Mivel a pfSense statikus IP-ket oszt, a belső szolgáltatások címei állandóak, a név-IP párosítás nem változik.
- A zónafájlokban rögzített **1 órás (3600s) TTL** ideális egyensúlyt teremt a stabilitás és a tesztelés alatti rugalmasság között.

**Unbound (Rekurzív feloldó):**
- **TTL Capping (0-3600s):** Az Unbound tiszteletben tartja az eredeti TTL-t, de 1 órában maximalizálja azt. Ez megvéd az elavult rekordoktól, miközben engedi a **CDN**-nek, hogy a rövid TTL-lel (pl. 10s) mindig a legközelebbi/leggyorsabb szervert ajánlják fel.
- **Optimistic Caching:** A serve-expired funkcióval a lejárt rekordokat további 1 óráig megőrzi. Ha az upstream szerver nem elérhető vagy lassú, a cache-ből azonnal válaszol, így a hálózati hiba vagy késleltetés észrevétlen marad a kliensek számára.

**AdGuard Home (Kliens oldali szűrő):**
- **TTL tartomány (0-86400s):** Itt a maximum limit 1 napra van emelve.
- **Optimistic caching** Az AdGuard szintén használ -et. Ha a BIND9 konténer vagy az Unbound ideiglenesen leállna, az AdGuard akár 24 órán át képes kiszolgálni a már ismert belső neveket a cache-ből, biztosítva a homelab szolgáltatások folyamatos elérését.

Layer / Server                 | Cache Size                          | Minimum TTL | Maximum TTL
-------------------------------|-------------------------------------|-------------|-------------
AdGuard Home (for clients)     | 128 MB                              | 0           | 86400 (1 day)
BIND9 (local zones)            | default                             | 3600        | 3600
Unbound (public DNS)           | msg-cache 64 MB, rrset-cache 128 MB | 0           | 3600 (1 hour)
 
---

## Ütemezett feladatok (Backup & Karbantartás)

**Az ütemezés logikájának magyarázata:**
- **01:00 short SMART teszt**: Így reggelre már tisztában vagyok azzal, hogy a lemezeim épek-e, és lehet-e rájuk biztonságosan dolgozni.
- **Minden hónap első szombatján 02:00 long SMART teszt:** Így reggelre már tisztában vagyok azzal, hogy a lemezeim épek-e, és lehet-e rájuk biztonságosan dolgozni.
- **04:00/05:30 Backup**: Azért hajnalban fut, mert ilyenkor a legkisebb a hálózati forgalom és a CPU terhelés. A két node (PVE1 és PVE2) eltolva indul, hogy ne terheljék túl egyszerre a PBS szerver írási sebességét és a hálózati sávszélesség.
- **08:00 szombatonként Garbage Collection**: 
- **Vasárnaponként 10:00 verification**: Heti egyszer elegendő ellenőrizni, hogy a fájlok valóban visszaállíthatóak-e, de szükségszerű ellenőrizni, hiszen nem elég hogy van backup, de az is fontos, hogy épek leglyenek.
- **22:00 Prune**: A policy alapján már nem szükséges backup-ok törlése, ezzel helyet csinálok a reggeli backupoknak.
- **22:30 Apt-Cacher-NG Maint**: Közvetlenül a frissítés előtt kijavítjuk a proxy gyorsítótárát, ha esetleg lenne hiba, így az Ansible hiba nélkül tudja frissíteni a VM/LXC gépeket.
- **23:00 Ansible Update**: Akkor frissítek, amikor a napi használat már lecsökkent és nem zavar ha egy szolgáltatás kiesik egy kis időre.

**Lenti ábrán látható az időzítési diagram.** Lemértem hogy melyik mennyi időt vesz igénybe. Utoljára **2026.02.11-én** ellenőriztem a jobok időtartamát. A Proxmox VM/LXC backupnál figyelembe kell venni hogy az első backup tart a legtovább, utána már inkrementális backupok vannak, amik gyorsabbak.
```mermaid
gantt
    title Optimalizált Rendszerfeladatok Ütemezése
    dateFormat  HH:mm
    axisFormat  %H:%M
    todayMarker off

    section Napi Rutin
    Prune                        : 22:00, 1m
    Apt-Cacher-NG Maint          : 22:30, 1m
    Ansible Update               : 23:00, 30m
    SMART Short Test             : 02:00, 5m

    section Mentési Ablak
    PVE1 -> PBS Mentés           :crit, 04:00, 15m
    PVE2 -> PBS Mentés           :crit, 05:30, 5m

    section Karbantartás
    SMART Long (Havi)            :done, 01:00, 4h
    Garbage Collection (Szo)     :done, 08:00, 1m
    Verify Jobs (Vas)            :done, 10:00, 20m
```

| Időpont | Feladat Neve | Célzott Eszköz | Gyakoriság | Időtartam |
| :--- | :--- | :--- | :--- | :--- |
| **22:00** | Prune (Retenció) | PBS Szerver | Naponta | 1 perc |
| **22:30** | Apt-Cacher-NG Karbantartás | Apt-Proxy Szerver | Naponta | 1 perc |
| **23:00** | Ansible Frissítés | VM/LXC | Naponta | 30 perc |
| **01:00** | SMART Hosszú Teszt | Proxmox 1 & 2 | Havonta (1. Szo) | - |
| **02:00** | SMART Rövid Teszt | Proxmox 1 & 2 | Naponta | - |
| **04:00** | VM/LXC Mentés | Proxmox 1 -> PBS | Hetente (Vasárnap) | 15 perc |
| **05:30** | VM/LXC Mentés | Proxmox 2 -> PBS | Hetente (Vasárnap) | 5 perc |
| **Szo 08:00** | Garbage Collection | PBS Szerver | Hetente | 1 perc |
| **Vas 10:00** | Mentés Ellenőrzés (Verify) | PBS Szerver | Hetente/Havonta | 20 perc |

---

## Proxmox Backup Server mentésnél azonos VM/LXC ID-k miatti kavarodás

**Problélma**

Több Proxmox node használata esetén a PBS (Proxmox Backup Server) alapértelmezés szerint a VM/LXC ID-k alapján rendszerezi a mentéseket. Azonos ID-k használata (pl. 101 a Node1-en és 101 a Node2-n) esetén az alábbi hibába ütköztem. A PBS felületén nem különbözteti meg, hogy az adott 101-es VM/LXC az most a Node1 vagy Node2-ről érkezett-e, így egy azonosító alá helyeté a kétféle VM/LXC mentését, nincsenek különvélasztva.


**Megoldás**
Globálisan Egyedi VM/LXC ID-k használata, és ezeket nem véletlenszerűen adom meg, hanem egy rendszerbe foglalom, az alábbi táblázat alapján.
A jelenlegi rendszerem átszámozom a táblázat alapján és az új VM/LXC létrehozásakor a táblázat szerinti osztok ID-t. Minden VM/LXC-t regisztrálok a egy táblázatban, hogy kinek milyen ID van kiosztva.

| ID Tartomány | Kategória | Megjegyzés |
| :--- | :--- | :--- |
| **100 - 499** | **LXC Core infrastruktúra** | Alapvető működéshez kötelező LXC |
| **500 - 999** | **VM Core infrastruktúra** | Alapvető működéshez kötelező virtuális VM |
| **1000 - 1099** | **LXC services** | Kiegészítő szolgáltatások (LXC) |
| **1100 - 1199** | **VM linux szerverek** | Linux alapú szerverek |
| **1200 - 1299** | **VM linux kliensek** | Linux alapú kliensek |
| **1300 - 1399** | **VM windows szerverek** | Windows alapú szerverek |
| **1400 - 1499** | **VM windows kliensek** | Windows alapú kliensek |

**Konkrét kiosztásom**

**LXC Core infrastruktúra (100-499)**
- `100:dns`, `101:unbound`, `102:traefik`, `103:adguard`, `104:pi-hole`, `105:nginx`

**VM Core infrastruktúra (500-999)**
- `500:pfsense`, `501:pbs`, `502:truenas`

**LXC Services (1000-1099)**
- `1000:zabbix`, `1001:ansible`, `1002:nextcloud`, `1003:homarr`, `1004:guacamole`, `1005:apt-cacher`, `1006:freeipa`, `1007:freeradius`, `1008:restic`, `1009:vaultwarden`, `1010:jellyfin`, `1011:servarr`, `1012:gotify`, `1013:portainer`, `1014:pulse`, `1015:changedetection`

**VM linux szerverek (1100-1199)**
- `1100:crowdsec`, `1101:pxeboot`

**VM linux kliensek (1200-1299)**
- `1200:mainubuntu`, `1201:kali`, `1202:probaubi`

**VM windows szerverek (1300-1399)**
- `1300:winszerver1`, `1301:winszerver2`, `1302:winszerver-core`

**VM windows kliensek (1400-1499)**
- `1400:mainwindows11`, `1401:win11kliens1`, `1402:win11kliens2`

---

## VM/LXC elnevezési konvencióm

A VM/LXC neve a rajta futó szolgáltatásra vagy szerepkörre utal, kiegészítve az IP címének utolsó oktettjével, így ahogy ránézek tudom hogy mit csinál és mi az IP címe, segítve a tájékozódásom. Példa a lenti ábrán, a traefik-224, amiről így egyértelmű számomra, hogy a traefik fut rajta és az IP címe 192.168.2.224.
<p align="center">
  <img src="https://github.com/user-attachments/assets/411bfb50-f4b9-4a76-b464-794a79a88299" alt="Description" width="400">
</p>

---

← [Vissza a Homelab főoldalra](../README_HU.md)

