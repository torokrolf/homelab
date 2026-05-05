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
| **Gotify**           | A riasztások fogadására. |

---

## 1.2 Monitorozott Területek---importált dashboard-al

A rendszer folyamatosan figyeli a **Proxmox** hypervisort és az összes futó **VM-et**. Kiemelt figyelmet kapnak az alábbiak:

- **Erőforrás használat:** CPU, RAM és Disk kihasználtság.
- **S.M.A.R.T. adatok:** A fizikai meghajtók (HDD/SSD) állapotának figyelése a váratlan adatvesztés megelőzése érdekében.

---

## 1.3 Riasztási Szabályok (Alerting)

A riasztások **Gotify**-ra érkeznek, amennyiben triggerelve lesznek:

| Erőforrás | Küszöbérték | Időtartam | Leírás |
|-----------|------------|-----------|--------|
| **Disk**  | > 85%      | 5 perc    | Megakadályozza a tároló megtelését és a VM-ek leállását. |
| **RAM**   | > 90%      | 5 perc    | Jelzi a memória szűkületet vagy a "memory leak" jelenséget. |
| **CPU**   | > 90%      | 10 perc   | Tartós túlterhelés esetén riaszt (rövid kiugrásokat figyelmen kívül hagy). |

---

← [Vissza a Homelab főoldalra](../README_HU.md)
