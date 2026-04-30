# Mount Watchdog: NAS-függőség kezelés

Ez az automatizáció a Proxmox host szintjén figyeli a központi adattároló (TrueNAS) elérhetőségét. Megakadályozza az I/O várakozás miatti rendszerszintű lefagyásokat azáltal, hogy leállítja a hálózati meghajtóktól függő szolgáltatásokat, ha a NAS offline állapotba kerül.

# Főbb jellemzők

*   **Ping-alapú gyorsreakció:** A script nem vár a fájlrendszer percekig tartó timeoutjára. Amint a ping sikertelen, a script azonnal leállítja a függő VM-eket/LXC-ket, mielőtt azok belefagynának az I/O várakozásba.
*   **Eseményvezérelt (State Machine) működés:** A `/var/lib/mount-watchdog/nas_status.state` fájl segítségével a rendszer megjegyzi az utolsó állapotot. Ha nincs változás (pl. a NAS stabilan UP), a script azonnal kilép, így nem terheli feleslegesen a rendszert SSH logolásokkal vagy Docker műveletekkel.
*   **Aszinkron vezérlés:** A leállítási és indítási parancsok párhuzamosan futnak (`&` és `wait`), így a kritikus reakcióidő a töredékére csökken.
*   **Intelligens Boot-kezelés:** A systemd unit egy egyedi logikát használ: ha a rendszerindulás óta nem telt el 45 másodperc, törli a korábbi állapotfájlt. Ez garantálja, hogy egy Proxmox reboot után a rendszer tiszta lappal induljon, és a NAS elérhetősége esetén akkor is elindítsa a gépeket, ha azok korábban nem indultak el automatikusan.

### Kezelt technológiák és függőségek

| Típus | Azonosító / Elérési út | Művelet hiba esetén |
| :--- | :--- | :--- |
| **LXC** | 1010 (Torrent) | Konténer azonnali leállítása. |
| **VM** | 1101 (PXE/ISO) | Virtuális gép leállítása. |
| **K3s Podok** | Media Namespace | Appok (Prowlarr, Radarr, stb.) skálázása 0 példányra. |

### Rendszerkomponensek

1.  **`mount-watchdog.sh`**: A központi Bash logika, amely kezeli a PVE (pct/qm) és a távoli K3s (kubectl) parancsokat.
2.  **`mount-watchdog.service`**: Systemd unit, amely tartalmazza a boot-idő alapú állapotfájl-törlést.
3.  **`mount-watchdog.timer`**: 30 másodpercenkénti ütemezést és nagy pontosságot (`AccuracySec=1s`) biztosít.
4.  **Gotify integráció**: Minden állapotváltásról (TrueNAS DOWN/UP) azonnali push értesítés érkezik a mobilomra.

### Miért jobb ez, mint a gyári megoldások?
A legtöbb rendszer megpróbálja erőszakkal fenntartani a mountot, ami zombi folyamatokhoz és a Proxmox webfelület lassulásához vezet. Ez a script proaktívan avatkozik be: ha nincs tároló, nincs futó app sem, így elkerülhető az adatkorrupció és a rendszerszintű instabilitás.

---
← [Vissza a Homelab főoldalra](../README_HU.md)