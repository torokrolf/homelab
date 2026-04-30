# Mount Watchdog: NAS-függőség kezelés

Ez az automatizáció a Proxmox host szintjén figyeli a központi adattároló (TrueNAS) elérhetőségét. Megakadályozza az I/O várakozás miatti rendszerszintű lefagyásokat azáltal, hogy leállítja a hálózati meghajtóktól függő szolgáltatásokat, ha a NAS offline állapotba kerül.

# Főbb jellemzők

**Ping-alapú gyorsreakció:** A script nem vár a fájlrendszer percekig tartó timeoutjára. Amint a TrueNAS ping sikertelen, a script azonnal leállítja a függő VM-eket/LXC-ket, mielőtt azok belefagynának az I/O várakozásba.
**Eseményvezérelt (State Machine) működés:** A `/var/lib/mount-watchdog/nas_status.state` fájl segítségével a rendszer megjegyzi az utolsó állapotot. Ha nincs változás (pl. a NAS stabilan UP), a script azonnal kilép, így nem terheli feleslegesen a rendszert SSH logolásokkal vagy Docker műveletekkel.
**Aszinkron vezérlés:** A leállítási és indítási parancsok párhuzamosan futnak (`&` és `wait`), így a kritikus reakcióidő a töredékére csökken.
**Intelligens Boot-kezelés:** A systemd unit egy egyedi logikát használ: ha a rendszerindulás óta nem telt el 45 másodperc, törli a korábbi állapotfájlt. Ez garantálja, hogy egy Proxmox reboot után a rendszer tiszta lappal induljon, és a NAS elérhetősége esetén akkor is elindítsa a gépeket, ha azok korábban nem indultak el automatikusan.

# Kezelt technológiák és függőségek

| Típus | Azonosító / Elérési út | Művelet hiba esetén |
| :--- | :--- | :--- |
| **LXC** | 1010 (Torrent) | Konténer azonnali leállítása. |
| **VM** | 1101 (PXE/ISO) | Virtuális gép leállítása. |
| **K3s Podok** | Media Namespace | Appok (Prowlarr, Radarr, stb.) skálázása 0 példányra. |

# Rendszerkomponensek

**`mount-watchdog.sh`**: A központi Bash logika, amely kezeli a PVE (pct/qm) és a távoli K3s (kubectl) parancsokat.
**`mount-watchdog.service`**: Systemd unit, amely tartalmazza a boot-idő alapú állapotfájl-törlést.
**`mount-watchdog.timer`**: 30 másodpercenkénti ütemezést és nagy pontosságot (`AccuracySec=1s`) biztosít.
**Gotify integráció**: Minden állapotváltásról (TrueNAS DOWN/UP) azonnali push értesítés érkezik a mobilomra.

 Itt láthatom az értesítés egy részletét Gotify-on.
<p align="center">
  <img src="https://github.com/user-attachments/assets/a8a0e206-cca0-4a7e-90a7-a69804076534" alt="Description" width="500">
</p>

