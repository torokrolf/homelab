← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Monitorozás és Riasztás

A homelab infrastruktúra átláthatóságát és üzembiztonságát egy központosított monitorozó rendszer biztosítja.

## 1.1 Alkalmazott Eszközök

| Szolgáltatás / Eszköz | Leírás |
|----------------------|--------|
| **Prometheus**       | Gyűjti és tárolja a metrikákat. |
| **Grafana**          | Vizualizációs platform az adatok megjelenítésére és dashboardok készítésére. |
| **Node Exporter**    | A fizikai gépek (Proxmox host) és virtuális gépek (VM) erőforrásainak kinyerése. |
| **Uptime Kuma**      | Szolgáltatások és hosztok elérhetőségének monitorozása (HTTP(S), TCP, ping, DNS stb.), valamint státusz- és uptime figyelés. |
| **Gotify**           | A riasztások és értesítések fogadására. |

---

## 1.2 Grafana+Prometheus---importált dashboard-al

A rendszer folyamatosan figyeli a **Proxmox** hypervisort és az összes futó **VM-et**. Kiemelt figyelmet kapnak az alábbiak:

- **Erőforrás használat:** CPU, RAM és Disk kihasználtság.

**Riasztási Szabályok (Alerting)**

A riasztások **Gotify**-ra érkeznek, amennyiben triggerelve lesznek:

| Erőforrás | Küszöbérték | Időtartam | Leírás |
|-----------|------------|-----------|--------|
| **Disk**  | > 85%      | 5 perc    | Megakadályozza a tároló megtelését és a VM-ek leállását. |
| **RAM**   | > 90%      | 5 perc    | Jelzi a memória szűkületet vagy a "memory leak" jelenséget. |
| **CPU**   | > 90%      | 10 perc   | Tartós túlterhelés esetén riaszt (rövid kiugrásokat figyelmen kívül hagy). |

- **S.M.A.R.T. adatok HD sentinel script-el:** A fizikai meghajtók (HDD/SSD) állapotának figyelése a váratlan adatvesztés megelőzése érdekében. [SMART scriptek megtekintése](/11-Scripts/proxmox/SMART)


## 1.3 Uptime Kuma

Az **Uptime Kuma** a szolgáltatások rendelkezésre állását és elérhetőségét figyeli valós időben. A rendszer különböző protokollokon keresztül ellenőrzi a hosztokat és alkalmazásokat, például:

- **HTTP / HTTPS**   --> elérhető-e az adott Web GUI, az SSL érvényes-e illetve mikor fog lejárni
- **TCP port**       --> SMB vagy NFS megosztásom elérhető-e
- **Ping (ICMP)**    --> Host (pl.: Proxmox) elérhető-e
- **DNS válaszidő**  --> DNS szerverem működik-e, oldja-e a neveket

A monitorozás célja a szolgáltatáskimaradások gyors észlelése és a hibák azonnali jelzése.

Hiba vagy elérhetetlenség esetén az értesítések **Gotify**-ra kerülnek továbbításra.

Az Uptime Kuma emellett uptime statisztikákat, válaszidő grafikonokat és státuszoldalt is biztosít a szolgáltatások állapotának gyors áttekintéséhez.

---

← [Vissza a Homelab főoldalra](../README_HU.md)
