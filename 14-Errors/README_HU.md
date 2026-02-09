← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Tartalomjegyzék

- [DNS – Publikus domain névfeloldás internet nélkül](#dns-offline)
- [DNS – Pi-hole blokkolja a Google képtalálatokat](#dns-pihole)
- [DNS – AdGuard DNS rate limitből adótó ARP starving](#ratelimit)
- [SSH – SSH belépés LXC / Ubuntu esetén](#ssh-lxc)
- [Megosztás – SMB/NFS elérés LXC-ből](#mount-lxc)
- [Megosztás – ha nem elérhető a Truenas megosztás](#nemelerheto)
- [Hardver – Külső SSD stabilitása USB-n](#hw-ssd)
- [Hardver – M70q hálózati adapter instabilitás](#hw-m70q)
- [Hardver – Lokális és publikus DNS problémák (Wi-Fi)](#hw-wifi)
- [DDNS – Cloudflare frissítés pfSense mögött](#ddns-pfsense)
- [Apt-cacher-ng csomagok beragadása](#aptcacherng)

---

## DNS – Publikus domain névfeloldás internet nélkül
<a name="dns-offline"></a>

**Probléma**:
- A `*.trkrolf.com` publikus domain elérése sikertelen volt internetkapcsolat nélkül.

**Megoldás**:
- **DNS override**: A wildcardolt trkrolf.com (*.trkrolf.com) rekordok belső hálózaton közvetlenül a Traefik helyi IP-re oldódik fel, kikerülve a külső lekérdezést.

---

## DNS – Pi-hole blokkolja a Google képtalálatokat mobilon
<a name="dns-pihole"></a>

**Probléma**:
- Mobilon a Google képtalálatok nem nyílnak meg a Pi-hole blokkolási listái miatt.

**Ok**:
- A Google tracking domaineket használ (pl. `googleadservices.com`), amik a tiltólistákon szerepelnek.

**Megoldás**:
- Ideiglenes Pi-hole kikapcsolás SSH script segítségével.

❗ Script: [/11-Scripts/Android/toggle_pihole_ssh.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## DNS – AdGuard DNS rate limitből adótó ARP starving
<a name="ratelimit"></a>

**Probléma leírása**
A Pi-hole-ról AdGuard Home-ra való átállás után a 192.168.1.0/24 hálózatról a Proxmox hostok (192.168.2.198, 192.168.2.199) elérhetetlenné váltak. Érdekesség, hogy a hostokon futó VM-ek és LXC konténerek pingelhetőek maradtak, de maguk a fizikai node-ok nem válaszoltak.

**Ok**

- **DNS rate limit:** Az AdGuard Home alapértelmezett rate limit-e (**20 lekérdezés/mp**) túl alacsony volt. A kliensek túllépték ezt, az AdGuard Home pedig eldobta a kéréseket.
- **DNS Flood:** A kliensek a sikertelen feloldások miatt agresszív újrapróbálkozásokba kezdtek, egyre sűrűbben, ami túlterhelte a Proxmox hálózati interfészét, ez egy öngerjesztő folyamat.
  **Hiányzó rekordok:** Mivel a Proxmox node-ok fix IP-vel rendelkeztek (nem Pfsense DHCP által), nem volt hozzájuk a statikus ARP bejegyzés bekapcsolva a pfSense-ben. A hálózati zaj miatt nem tudtak bekerülni az ARP táblába így, aminek eredménye az **ARP starving**.
- **ARP starving:** A nagy mennyiségű eldobott csomag és a sorban állás miatt a Proxmox interfésze nem tudta időben megválaszolni a pfSense ARP kéréseit, ami a PING-hez kellene. A Proxmox node-on lévő VM-eket és LXC-ket azért tudtam pingelni 1.0-ról, mert ők a pfSense DHCP szervertől kapták az IP-t és ott a statikus ARP-ot is megkapták, ugyanis beállítottam. Így az ő IP címük + MAC címük ismert volt. 


**Megoldás**

1.  **Statikus ARP rögzítése:**
    * A pfSense-ben a Proxmox hostokat hozzáadtam a **DHCP Static Mappings** listához.
    * A MAC címek rögzítése után bekapcsoltam a **Static ARP** opciót, így a routernek már nem kell ARP kérésekkel keresnie a hostokat.
2.  **AdGuard Home korlát feloldása:**
    * Az AdGuard felületén: Settings/DNS settings/Rate limit.

---

## SSH – SSH belépés LXC / Ubuntu esetén
<a name="ssh-lxc"></a>

**Probléma**:
- Az LXC konténerekben alapértelmezetten tiltott a root SSH login.

**Megoldás**:
- Regular user létrehozása és SSH kulcs alapú hitelesítés beállítása.

---

## Megosztás – SMB/NFS elérés LXC-ből
<a name="mount-lxc"></a>

**Probléma**:
- Unprivileged LXC konténerek nem tudnak közvetlenül hálózati megosztást mountolni.

**Megoldás**:
- A Proxmox hoston **AutoFS**-el csatolt megosztás továbbadása bind mount (`mp0`) segítségével.
- Ez kiküszöböli a `df` parancs fagyását, ha a tároló nem elérhető.

---

## Megosztás – ha nem elérhető a Truenas megosztás]
<a name="nemelerheto"></a>

**Probléma**:
- Mivel nekem a Proxmox1-es node-on fut több VM és LXC ami használja a TrueNAS megosztást, így problémás lehet, hogy mi van akkor, amennyiben nem elérhető a megosztás. Például a qBittorrent a megosztás amennyiben nem volt elérhető, a VM lokális terhelyére folytatta a letöltést, ami probléma. 

**Megoldás**:
Legjobb megoldásnak azt találtam, ha leállítom ekkor az LXC és VM gépeket, úgyis az ahány szolgáltatás annyi VM/LXC elvet követem, így ez nem befolyásolja más szolgáltatás futását. Amennyiben elérhető a megosztás, akkor elindítom a VM/LXC-t.
- Proxmoxhoz autofs-el minden megosztás mountolva van, hogy tudja ellenőrizni és továbbosztani LXC-nek.
- Leellenőrzöm scripttel 30 másodpercenként, hogy elérhető-e a megosztás.
- Ha elérhető a megosztás, megnézi hogy fut-e a VM/LXC, ha nem fut, elindítja.
- Ha nem elérhető a megosztás, akkor leállítja a VM/LXC-t ha fut.

❗ Script: [/11-Scripts/Android/proxmox-mount-monitor.sh](/11-Scripts/proxmox/mount-monitor)

Lenti képen látható, TrueNAS-t leállítottam akkor leáll a másik Proxmoxon node-on lévő érintett VM/LXC gépek. Ha elindíntanám újra a TrueNAS-t akkor elindulnak ezek a gépek is.
<p align="center">
  <img src="https://github.com/user-attachments/assets/042abb72-ea53-4769-b017-237a0f493dbe" alt="TrueNAS stopped" width="400">
</p>

---

## Hardver – Külső SSD stabilitása USB-n
<a name="hw-ssd"></a>

**Probléma**:
- A Samsung 870 EVO SSD közvetlen USB csatlakozás mellett instabil volt.

**Megoldás**:
- TP-Link UE330 USB hub használata, amely stabilabb áramellátást biztosít.

---

## Hardver – M70q hálózati adapter instabilitása
<a name="hw-m70q"></a>

**Probléma**:
- Az M70q belső hálózati kártyája véletlenszerűen megszakította a kapcsolatot.

**Megoldás**:
- TP-Link UE330 külső USB adapter használata a stabil hálózati eléréshez.

---

## Hardver – Lokális és publikus DNS problémák Wi-Fi adapter miatt
<a name="hw-wifi"></a>

**Probléma**:
- A MediaTek 7921 Wi-Fi kártya instabil DNS feloldást produkált Linux környezetben.

**Megoldás**:
- Az adapter cseréje Intel AX210-re.

---

## DDNS – DDNS nem frissül Cloudflare-en pfSense mögött
<a name="ddns-pfsense"></a>

**Probléma**:
- A pfSense privát WAN IP-je miatt a DDNS nem érzékelte a publikus IP változását.

**Megoldás**:
- Egyedi script használata, amely külsőleg ellenőrzi a publikus IP-t és frissíti a Cloudflare rekordot.

❗ Script: [/11-Scripts/pfsense/ddns-force-update.sh](/11-Scripts/pfsense/ddns-force-update.sh)

---

## Apt-cacher-ng beragadó csomagok problémája 
<a name="aptcacherng"></a>

**Probléma**
Kliensek Ansible-el történő frissítésekor a Semaphore GUI-nál láttam, hogy néha nem fut le, csak beragad és vár a végtelenségig. Ezt láthatom a lenti ábrán.
<p align="center">
  <img src="https://github.com/user-attachments/assets/db0a18b6-dd7c-45b4-83cc-b9f97840c7f8" alt="Description" width="300">
</p>

**Ok**

- Proxy szerveren: tail -f /var/log/apt-cacher-ng/apt-cacher.err –> mutatja a cache hibákat, ezt láthatom a lenti ábrán.
- A kliens kéri a csomagot a proxy szervertől (apt-cacher-ng).
- Az apt-cacher-ng adatbázisa látja, hogy a letöltött csomag fájlmérete nem egyezik azzal, ami az adatbázisában szerepel, hogy hivatalosan mekkora méretűnek kellene lennie a fájlnak (checked size beyond EOF).
- A proxy megpróbálja újra letölteni a hibás fájl, de nem tudja, hiszen van már ilyen nével letölve, még ha hibásan is (file exists), ezért a kliens **vár a csomagra végtelenségig**.
<p align="center">
  <img src="https://github.com/user-attachments/assets/3563cca6-e744-4dbe-b23f-4ae2823db9ac" alt="Description" width="300">
</p>


**Megoldás**

Az acngtool karbantartó parancs cron-ba helyezve, minden nap 22:30-kor futtatva. Így automatikusan tisztítja és újraépíti a cache-t, elkerülve a beragadást, közvetlenül a 23:00 órási ansible által vezényelt update playbook előtt, elkerülve így a beragadást.

30 22 * * * /usr/lib/apt-cacher-ng/acngtool maint -c /etc/apt-cacher-ng >/dev/null 2>&1

---

← [Vissza a Homelab főoldalra](../README_HU.md)
