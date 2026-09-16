# Mount Watchdog: NAS-függőség kezelés

Ez az automatizáció a Proxmox host szintjén figyeli a központi adattároló (TrueNAS) elérhetőségét. Megakadályozza az I/O várakozás miatti rendszerszintű lefagyásokat azáltal, hogy leállítja a hálózati megosztástól függő VM-eket, LXC-ket és K3s szolgáltatásokat, ha a NAS offline állapotba kerül — majd automatikusan visszaindítja őket, amint a NAS ismét elérhető.

## 📚 Tartalomjegyzék

- [Miért van erre szükség](#miert)
- [Előfeltételek](#elofeltetelek)
- [Főbb jellemzők és a mögöttük lévő logika](#logika)
- [Kezelt technológiák és függőségek](#fuggosegek)
- [Megvalósítás](#megvalositas)
- [Tesztelés és tapasztalatok](#tesztelese)

---

## Miért van erre szükség
<a name="miert"></a>

Nálam a Proxmox1-es node-on fut több VM és LXC, ami a TrueNAS megosztást használja. Gond van akkor, ha a megosztás nem elérhető: például a qBittorrent a megosztás hiányában a VM lokális tárhelyére folytatta a letöltést, ami nem kívánt viselkedés.

A legjobb megoldásnak azt találtam, ha ilyenkor **leállítom** az érintett LXC-t és VM-et — úgyis az "ahány szolgáltatás, annyi VM/LXC" elvet követem, így ez nem befolyásolja más szolgáltatás futását. Amint a megosztás újra elérhető, automatikusan visszaindítom őket.

---

## Előfeltételek
<a name="elofeltetelek"></a>

- **Auto-boot kikapcsolva** azokon a VM/LXC-ken, amiket a script kezel (1010, 1101) — Proxmox ne indítsa el őket bootkor, mert erre a scriptet bízzuk. A K3s szerver (1105) kivétel, mert azt app-szinten (podok skálázásával) kapcsolgatom, nem VM-szinten, így az automatikusan indulhat a Proxmox-szal.
- **Jelszó nélküli SSH hozzáférés** (`ssh-copy-id`) a Proxmox hostról a K3s (és opcionálisan egy jövőbeli Docker) VM felé, hogy a script felügyelet nélkül tudjon `kubectl`/`docker compose` parancsokat küldeni.

---

## Főbb jellemzők és a mögöttük lévő logika
<a name="logika"></a>

### Ping-alapú gyorsreakció

A script nem magát a megosztást (SMB/NFS) teszteli, hanem magát a TrueNAS gépet **pingeli**. Ennek oka, hogy nem várunk arra, hogy a fájlrendszer timeoutoljon vagy a mount "megdögöljön" (ami percekig tarthat) — a ping azonnal jelzi, ha a TrueNAS offline, így a script még azelőtt leállítja a függő gépeket, hogy azok elkezdenének belefagyni az I/O várakozásba. Ez lényegesen gyorsabb reakciót ad, mintha a mount tényleges elérhetőségét vizsgálnánk.

### Állapotvezérelt (event-driven) működés — State machine

A `$STATE_FILE` (`/var/lib/mount-watchdog/nas_status.state`) használatával a scriptnek van memóriája. A systemd timer 30 másodpercenként mindig lefuttatja a scriptet, de ha a ping eredménye megegyezik az előző, fájlba mentett állapottal, a script azonnal kilép — nem indít vagy állít le semmit feleslegesen. Enélkül minden 30 másodperces ciklusban újraindítaná a már futó gépeket is, hiszen a teljes script lefutna. Így viszont csak akkor nyúl a rendszerekhez, ha **ténylegesen történt állapotváltozás** — nincs felesleges SSH login, nincs "Docker spam", nem szemeteli a logokat.

### Aszinkron (párhuzamos) vezérlés

A `&` és `wait` parancsokkal a script nem sorban (egymásra várva) állítja le/indítja el a gépeket, hanem egyszerre löki ki az összes parancsot a Proxmoxnak (VM/LXC) és a távoli rendszereknek (K3s, opcionálisan Docker) egyaránt. Ezzel a kritikus leállási/indítási idő a töredékére csökken.

### A reboot-probléma és a javítása

**Mi volt a baj eredetileg:** Ha úgy indítom újra a Proxmoxot, hogy a TrueNAS elérhető volt, a state fájlban "UP" marad. Reboot után lefut a script, látja hogy az előző állapot UP, a jelenlegi állapot is UP — tehát nincs változás, és **soha nem indítja el** a VM-et/LXC-t, hiszen azok auto-boot nélkül eleve állva vannak. Csak akkor oldódott fel a helyzet, ha kézzel leállítottam a TrueNAS-t (ekkor volt állapotváltozás, leállította a már úgyis állva lévő gépeket), majd újra elérhetővé tettem (ekkor DOWN→UP váltás miatt elindította őket).

Ha viszont a TrueNAS leállítva volt, és úgy indult újra a Proxmox, hogy a state fájlba még sikerült beírni "DOWN"-t leállás előtt, akkor reboot után a script azt látja: jelenleg nem elérhető, state is DOWN — nincs változás, nem csinál semmit (ez helyes). Ha viszont áramszünet miatt indult újra a Proxmox, és a state fájlba nem sikerült beírni a DOWN állapotot (UP maradt benne), akkor a script állapotváltozást észlel (state UP, valóság DOWN) és leállítja a gépeket, amik amúgy is állnak — ez ártalmatlan, de felesleges.

**A javítás:** Reboot után egyszer töröljük a state fájlt. Ehhez a `mount-watchdog.service`-ben egy 45 másodperces uptime-ellenőrzés van beépítve (`ExecStartPre`), ami csak az első futásnál (a timer `OnBootSec=30` miatt kb. 30mp-nél) törli a fájlt, utána (60mp, 90mp, stb.) többé nem. Így a script frissen indul, a jelenlegi valós állapot alapján dönt, látja a DOWN→UP váltást, és elindítja a gépeket.

**Miért pont 45 másodperc:** Amikor a Proxmox elindul, a VM-ek/LXC-k alapból állnak (auto-boot ki van kapcsolva), a script indítja majd őket, ha van TrueNAS. De a state fájl még a tegnapi (leállás előtti) állapotot mutatja, ami tipikusan "UP". Ha a script 30 másodpercnél lefutna törlés nélkül, azt látná: "a state szerint minden fut, a NAS is elérhető, nincs teendő" — és a gépek soha nem indulnának el. A 45 másodperces küszöb pont úgy van belőve, hogy az első (kb. 30mp-es) futásnál igaz legyen a feltétel (30 < 45 → törlés), a másodiknál (kb. 60mp-nél) pedig már ne (60 > 45 → nincs törlés). Így a state pontosan egyszer törlődik reboot után, utána stabilan, a tényleges változásokra reagálva fut tovább.

### UNKNOWN állapot kezelése

A state fájlban valójában három állapot fordulhat elő: UP, DOWN, és egy "ismeretlen" (UNKNOWN) helyzet, ami akkor áll fenn, ha a fájl egyáltalán nem létezik (első indításkor, vagy reboot után, miután töröltük). A script ezt így kezeli:

```bash
PREVIOUS_STATUS="DOWN"
[ -f "$STATE_FILE" ] && PREVIOUS_STATUS=$(cat "$STATE_FILE")
```

Ha a fájl hiányzik, a `PREVIOUS_STATUS` alapértelmezetten "DOWN" lesz — vagyis a script úgy viselkedik, mintha korábban a NAS DOWN lett volna. Ha a TrueNAS éppen elérhető, ez DOWN→UP változást eredményez, ami elindítja a VM-eket és LXC-ket. Ez pontosan a kívánt viselkedés: a state-törlés + ez az alapértelmezés együtt garantálja, hogy a rendszer mindig a valós, jelenlegi állapothoz igazodik, nem egy elavult bejegyzéshez.

### systemd.automount — késői mount automatizálása

A systemd.automount egységeket azért használom, hogy ha a TrueNAS később válik elérhetővé, mint ahogy a Proxmox elindult, a rendszer akkor is automatikusan felcsatolja a megosztást, amikor valaki (pl. Jellyfin) először hozzá akar férni az adott elérési úthoz.

Az automount nem előre csatolja fel a megosztást induláskor, hanem **on-demand** — csak akkor, amikor valami ténylegesen megpróbál hozzáférni a mountponthoz. Ha a TrueNAS induláskor nem elérhető, a mount nem csatolódik fel, de ez nem okoz hibát. Amint a TrueNAS visszajön, és pl. Jellyfin megpróbálja olvasni a médiát, a kernel jelzi az automount egységnek, az felcsatolja a megosztást, és a Jellyfin megkapja az adatokat — mindezt automatikusan, beavatkozás nélkül.

Ez azért jobb, mint egy sima `mount.service`: az utóbbi induláskor próbál csatolni, és ha a NAS nem elérhető, hibával leáll. Az automount ezzel szemben türelmes: bármikor felcsatolja a megosztást, ha az elérhetővé válik, és a folyamat (Jellyfin, qBittorrent stb.) az első hozzáférés pillanatában már a felcsatolt megosztást látja. A megosztás a Proxmox hoston van systemd.automount-tal kezelve, az LXC-knek pedig bind mount (`mp0`) segítségével van továbbadva — mivel unprivileged LXC konténerek nem tudnak közvetlenül hálózati megosztást mountolni.

---

## Kezelt technológiák és függőségek
<a name="fuggosegek"></a>

| Típus | Azonosító / Elérési út | Művelet, ha a NAS elérhetetlenné válik | Művelet, ha a NAS újra elérhető |
| :--- | :--- | :--- | :--- |
| **LXC** | 1010 (Jellyfin) | Konténer leállítása (`pct stop`) | Konténer indítása (`pct start`) |
| **VM** | 1101 (PXE/ISO) | Virtuális gép leállítása (`qm stop`) | Virtuális gép indítása (`qm start`) |
| **K3s Podok** | `media` namespace — bazarr, prowlarr, qbittorrent, radarr, seerr, sonarr | Deploymentek skálázása 0 példányra (`kubectl scale`) | Deploymentek skálázása 1 példányra |
| **Docker VM** | *(előkészítve, jelenleg nincs aktívan használva)* | `handle_vm_docker` funkció, SSH-n keresztüli `docker compose stop` | `docker compose stop` |

---

## Megvalósítás
<a name="megvalositas"></a>

**`mount-watchdog.sh`**

```bash
#!/bin/bash

# --- LXC KONFIGURÁCIÓ ---
declare -A LXC_LIST=( [1010]="/mnt/torrent" )

# --- VM KONFIGURÁCIÓ ---
declare -A VM_LIST=( [1101]="/mnt/pxeiso" )

# Docker VM KONFIGURÁCIÓ (jelenleg inaktív, előkészítve)
#DOCKER_VM_ID=1102
#DOCKER_VM_IP="192.168.2.230"
#DOCKER_VM_USER="rolf"
#DOCKER_STACK_PATH="/opt/apps-stack/media-stack"

# K3S VM Konfiguráció
K3S_VM_ID=1105
K3S_VM_IP="192.168.2.225"
K3S_VM_USER="rolf"
K3S_NAMESPACE="media"
K3S_APPS="bazarr prowlarr qbittorrent radarr seerr sonarr"

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GOTIFY_SCRIPT="/usr/local/bin/send-gotify.sh"
NAS_IP="192.168.2.220"
STATE_FILE="/var/lib/mount-watchdog/nas_status.state"

mkdir -p /var/lib/mount-watchdog

# --- TrueNAS állapot ellenőrzés ---
if ping -c1 -W1 $NAS_IP >/dev/null 2>&1; then
    NAS_ONLINE=0
    CURRENT_STATUS="UP"
else
    NAS_ONLINE=1
    CURRENT_STATUS="DOWN"
fi

PREVIOUS_STATUS="DOWN"
[ -f "$STATE_FILE" ] && PREVIOUS_STATUS=$(cat "$STATE_FILE")

if [ "$CURRENT_STATUS" == "$PREVIOUS_STATUS" ]; then
    exit 0
fi

echo "$(date '+%F %T') - Státuszváltás észlelve: $PREVIOUS_STATUS -> $CURRENT_STATUS"

if [ "$CURRENT_STATUS" == "UP" ]; then
    $GOTIFY_SCRIPT "✅ TrueNAS újra elérhető! A rendszerek indulnak."
else
    $GOTIFY_SCRIPT "⚠️ HIBA: TrueNAS elérhetetlen! A függő rendszerek leállításra kerülnek."
fi

# --- Kezelő függvények ---

handle_lxc() {
    local ID=$1
    [ $NAS_ONLINE -eq 0 ] && pct start $ID 2>/dev/null || pct stop $ID 2>/dev/null
}

handle_vm() {
    local ID=$1
    [ $NAS_ONLINE -eq 0 ] && qm start $ID 2>/dev/null || qm stop $ID 2>/dev/null
}

handle_vm_docker() {
    if qm status $DOCKER_VM_ID | grep -q "status: running"; then
        if [ $NAS_ONLINE -eq 0 ]; then
            ssh -o ConnectTimeout=3 ${DOCKER_VM_USER}@${DOCKER_VM_IP} "cd ${DOCKER_STACK_PATH} && docker compose start" >/dev/null 2>&1
        else
            ssh -o ConnectTimeout=3 ${DOCKER_VM_USER}@${DOCKER_VM_IP} "timeout 15s docker compose -f ${DOCKER_STACK_PATH}/docker-compose.yml stop" >/dev/null 2>&1
        fi
    fi
}

handle_k3s_media() {
    if qm status $K3S_VM_ID | grep -q "status: running"; then
        local REPLICAS=0
        [ $NAS_ONLINE -eq 0 ] && REPLICAS=1

        echo "K3S: $K3S_APPS skálázása $REPLICAS példányra..."
        for APP in $K3S_APPS; do
            ssh -o ConnectTimeout=3 ${K3S_VM_USER}@${K3S_VM_IP} "kubectl scale deployment $APP --replicas=$REPLICAS -n $K3S_NAMESPACE" >/dev/null 2>&1 &
        done
    fi
}

# --- FUTTATÁS PÁRHUZAMOSAN ---

for ID in "${!LXC_LIST[@]}"; do handle_lxc "$ID" & done
for ID in "${!VM_LIST[@]}"; do handle_vm "$ID" & done
handle_vm_docker &
handle_k3s_media &

wait

echo "$CURRENT_STATUS" > "$STATE_FILE"
echo "$(date '+%F %T') - Minden művelet befejezve."
exit 0
```

**`mount-watchdog.service`**

```ini
[Unit]
Description=Mount Watchdog (LXC + VM)
After=network.target

[Service]
Type=oneshot
ExecStartPre=/bin/bash -c 'if [ $(awk -F. "{print \$1}" /proc/uptime) -lt 45 ]; then rm -f /var/lib/mount-watchdog/nas_status.state; fi'
ExecStart=/usr/local/bin/mount-watchdog.sh

[Install]
WantedBy=timers.target
```

**`mount-watchdog.timer`**

```ini
[Unit]
Description=Run Mount Watchdog every 30s

[Timer]
OnBootSec=30
OnUnitActiveSec=30
Unit=mount-watchdog.service
AccuracySec=1s

[Install]
WantedBy=timers.target
```

Aktiválás:

```bash
systemctl daemon-reload
systemctl enable --now mount-watchdog.timer
```

* **Gotify integráció** — minden állapotváltásról (TrueNAS DOWN→UP vagy UP→DOWN) azonnali push értesítés érkezik a mobilomra.

<p align="center">
  <img src="https://github.com/user-attachments/assets/a8a0e206-cca0-4a7e-90a7-a69804076534" alt="Description" width="500">
</p>

---

## Tesztelés és tapasztalatok
<a name="tesztelese"></a>

**Fontos tapasztalat:** az egyik LXC lassú leállását sokáig hibának hittem, mígnem kiderült, hogy ez csak a Proxmox GUI-ban látszik úgy, mintha nem állt volna le teljesen — valójában már elérhetetlen. A Gotify-értesítés megérkezése egyértelmű jelzés arra, hogy a leállás/indítás ténylegesen megtörtént, függetlenül attól, hogy a Proxmox GUI mit mutat.
