## Automation

| Service / Tool | Description |
|---------------|-------------|
| Automation    | Ansible, Semaphore, Cron, Cronicle |

### Megvalósított funkciók
> Az automatizáció jelenleg az alap rendszerkarbantartási és konfigurációs feladatokra fókuszál; további playbookok és workflow-k későbbi bővítése tervben van.

- **Ansible automatizáció**
  - Használat CLI-ből és Semaphore Web UI-n keresztül.
  - VM-ek és LXC-k frissítésének automatizálása playbookokkal.
  - Közös felhasználók létrehozása több gépen.
  - SSH kulcsok egységes kezelése és kiosztása.
  - Közös konfigurációs fájlok kezelése (pl. NTP szerver beállítása).
  - Időzóna egységes beállítása az infrastruktúrán belül.
- **Időzítés**
  - Cron és Cronicle használata automatizált feladatok ütemezésére.


