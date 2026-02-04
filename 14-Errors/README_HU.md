← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Tartalomjegyzék

- [DNS – Publikus domain névfeloldás internet nélkül](#dns-offline)
- [DNS – Pi-hole blokkolja a Google képtalálatokat](#dns-pihole)
- [SSH – SSH belépés LXC / Ubuntu esetén](#ssh-lxc)
- [Megosztás – SMB/NFS elérés LXC-ből](#mount-lxc)
- [Megosztás – ha nem elérhető a Truenas megosztás](#nemelerheto)
- [Hardver – Külső SSD stabilitása USB-n](#hw-ssd)
- [Hardver – M70q hálózati adapter instabilitás](#hw-m70q)
- [Hardver – Lokális és publikus DNS problémák (Wi-Fi)](#hw-wifi)
- [DDNS – Cloudflare frissítés pfSense mögött](#ddns-pfsense)

---

## DNS – Publikus domain névfeloldás internet nélkül
<a name="dns-offline"></a>

**Probléma**:
- A `*.trkrolf.com` publikus domain elérése sikertelen volt internetkapcsolat nélkül.

**Megoldás**:
- Lokális BIND9 DNS használata DNS override-al, így a név mindig a belső IP-re (192.168.2.202) oldódik fel.

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
- Proxmoxhoz autofs-el minden megosztás mountolva van, hogy tudjon róla.
- Leellenőrzöm scripttel 30 másodpercenként, hogy elérhető-e a megosztás.
- Ha elérhető a megosztás, megnézi hogy fut-e a VM/LXC, ha nem fut, elindítja.
- Ha nem elérhető a megosztás, akkor leállítja a VM/LXC-t ha fut.

❗ Script: [/11-Scripts/Android/proxmox-mount-monitor.sh](/11-Scripts/proxmox/proxmox-mount-monitor.sh)

❗ Script: [/11-Scripts/Android/proxmox-mount-monitor.service](/11-Scripts/proxmox/proxmox-mount-monitor.service)

❗ Script: [/11-Scripts/Android/proxmox-mount-monitor.timer](/11-Scripts/proxmox/proxmox-mount-monitor.timer)

Lenti képen látható, TrueNAS-t leállítottam.
<p align="center">
  <img src="[path/to/image.png](https://github.com/user-attachments/assets/c06fd588-4cde-48af-a4af-bfef33c89914)" alt="Description" width="300">
</p>

Lenti képen látható, a TrueNAS leállásakor ezek a VM-ek és LXC-k leállnak.
<p align="center">
  <img src="[path/to/image.png](https://github.com/user-attachments/assets/23e62678-e4b9-4764-be8f-ed881317c7a0)" alt="Description" width="300">
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

← [Vissza a Homelab főoldalra](../README_HU.md)
