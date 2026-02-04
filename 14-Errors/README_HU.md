← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Tartalomjegyzék

- [1.1 DNS – Publikus domain névfeloldás internet nélkül](#dns-offline)
- [1.2 DNS – Pi-hole blokkolja a Google képtalálatokat](#dns-pihole)
- [1.3 SSH – SSH belépés LXC / Ubuntu esetén](#ssh-lxc)
- [1.4 Megosztás – SMB/NFS elérés LXC-ből](#mount-lxc)
- [1.5 Hardver – Külső SSD stabilitása USB-n](#hw-ssd)
- [1.6 Hardver – M70q hálózati adapter instabilitás](#hw-m70q)
- [1.7 Hardver – Lokális és publikus DNS problémák (Wi-Fi)](#hw-wifi)
- [1.8 DDNS – Cloudflare frissítés pfSense mögött](#ddns-pfsense)

---

## 1.1 DNS – Publikus domain névfeloldás internet nélkül
<a name="dns-offline"></a>

**Probléma**:
- A `*.trkrolf.com` publikus domain elérése sikertelen volt internetkapcsolat nélkül.
**Megoldás**:
- Lokális BIND9 DNS használata DNS override-al, így a név mindig a belső IP-re (192.168.2.202) oldódik fel.

---

## 1.2 DNS – Pi-hole blokkolja a Google képtalálatokat mobilon
<a name="dns-pihole"></a>

**Probléma**:
- Mobilon a Google képtalálatok nem nyílnak meg a Pi-hole blokkolási listái miatt.
**Ok**:
- A Google tracking domaineket használ (pl. `googleadservices.com`), amik a tiltólistákon szerepelnek.
**Megoldás**:
- Ideiglenes Pi-hole kikapcsolás SSH script segítségével.

❗ Script: [/11-Scripts/Android/toggle_pihole_ssh.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## 1.3 SSH – SSH belépés LXC / Ubuntu esetén
<a name="ssh-lxc"></a>

**Probléma**:
- Az LXC konténerekben alapértelmezetten tiltott a root SSH login.
**Megoldás**:
- Regular user létrehozása és SSH kulcs alapú hitelesítés beállítása.

---

## 1.4 Megosztás – SMB/NFS elérés LXC-ből
<a name="mount-lxc"></a>

**Probléma**:
- Unprivileged LXC konténerek nem tudnak közvetlenül hálózati megosztást mountolni.
**Megoldás**:
- A Proxmox hoston **AutoFS**-el csatolt megosztás továbbadása bind mount (`mp0`) segítségével.
- Ez kiküszöböli a `df` parancs fagyását, ha a tároló nem elérhető.

---

## 1.5 Hardver – Külső SSD stabilitása USB-n
<a name="hw-ssd"></a>

**Probléma**:
- A Samsung 870 EVO SSD közvetlen USB csatlakozás mellett instabil volt.
**Megoldás**:
- TP-Link UE330 USB hub használata, amely stabilabb áramellátást biztosít.

---

## 1.6 Hardver – M70q hálózati adapter instabilitása
<a name="hw-m70q"></a>

**Probléma**:
- Az M70q belső hálózati kártyája véletlenszerűen megszakította a kapcsolatot.
**Megoldás**:
- TP-Link UE330 külső USB adapter használata a stabil hálózati eléréshez.

---

## 1.7 Hardver – Lokális és publikus DNS problémák Wi-Fi adapter miatt
<a name="hw-wifi"></a>

**Probléma**:
- A MediaTek 7921 Wi-Fi kártya instabil DNS feloldást produkált Linux környezetben.
**Megoldás**:
- Az adapter cseréje Intel AX210-re.

---

## 1.8 DDNS – DDNS nem frissül Cloudflare-en pfSense mögött
<a name="ddns-pfsense"></a>

**Probléma**:
- A pfSense privát WAN IP-je miatt a DDNS nem érzékelte a publikus IP változását.
**Megoldás**:
- Egyedi script használata, amely külsőleg ellenőrzi a publikus IP-t és frissíti a Cloudflare rekordot.

❗ Script: [/11-Scripts/pfsense/ddns-force-update.sh](/11-Scripts/pfsense/ddns-force-update.sh)

---

← [Vissza a Homelab főoldalra](../README_HU.md)
