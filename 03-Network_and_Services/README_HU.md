← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Network and services

---

## 1.1 Hálózat és Szolgáltatások

| Szolgáltatás / Terület                 | Eszközök / Szoftverek |
|--------------------------              |-----------------------|
| [1.2 Tűzfal / Router](#pfsense)             | pfSense                                                         |
| [1.3 VPN](#vpn)                             | Tailscale, WireGuard, OpenVPN, NordVPN                          |
| [1.4 APT cache proxy](#apt)                 | APT-Cache-NG                                                    |
| [1.5 VLAN](#vlan)                           | TP-LINK SG108E switch                                           |
| [1.6 Reverse Proxy](#reverseproxy)          | Nginx Proxy Manager (lecseréltem), Traefik (használom jelenleg) |
| [1.7 Radius / LDAP](#radiusldap)            | FreeRADIUS, FreeIPA                                             |
| [1.8 Reklámszűrés](#reklamszures)           | Pi-hole                                                         |       
| [1.9 PXE Boot](#pxe)                        | iVentoy                                                         |
| [1.10 DNS](#dns)                            | BIND9 + Namecheap + Cloudflare, Windows Server 2019 DNS szerver |
| [1.11 Hálózati hibakeresés](#hibakereses)   | Wireshark                                                       |
| [1.12 DHCP](#dhcp2)                          | ISC-KEA, Windows Server 2019 DHCP szerver                       |

---

<a name="pfsense"></a>
## 1.2 pfSense 

Homelabomban egy **pfSense alapú tűzfalat és routert** használok.  

---

### 1.2.1 NAT & Routing
- **Outbound NAT** konfigurálása belső hálózat számára  
- **Port Forward NAT** külső szolgáltatások publikálásához  
- **Hálózatok közötti routing biztosítása**  

---

<a name="dhcp"></a>
### 1.2.2 DHCP szerver konfigurálása és üzemeltetése 
- IP tartományok kezelése
- Statikus DHCP lease-ek
- Gateway és DNS kiosztás
- ARP table static entry, szerverek és kliensek statikus ARP bejegyzést kapnak IP-MAC pároshoz a 2.0-ás hálózaton a DHCP szervertől, védve így az **ARP spoofing** ellen
- A switchnek fix IP-t adok manuálisan, mert így mindig elérhető marad a menedzsment felülete, függetlenül a DHCP-től

---

### 1.2.3 NTP szerver futtatása <a name="ntp"></a>
- Időszinkron biztosítása belső klienseknek
- Kliensek a **chronyd**-t használják
- A pfSense szerver alapból a régebbi **ntpd** szervert használja, de a chronyd és az ntpd képes együttműködni hiba nélkül
- A pfSense szolgál NTP szerverként minden LXC-nek és VM-nek, kivéve a **FreeIPA LXC**-t

---

### 1.2.4 WireGuard VPN
- Modern, gyors VPN megoldás
- Távoli hozzáférés biztosítása belső hálózathoz

---

### 1.2.5 OpenVPN
- Tanúsítvány-alapú hitelesítés
- Kompatibilitás különböző kliensekkel
- VPN-en keresztüli routing és tűzfalszabályok kialakítása

---

### 1.2.6 Dynamic DNS (DDNS)
- Dinamikus publikus IP-cím kezelése 
- Fontos, hogy az **internet felől a VPN hálózathoz** mindig hozzáférhessek, még akkor is, ha a publikus IP változik

---

<a name="vpn"></a>
## 1.3 VPN használat a homelabhoz

- **OpenVPN** és **WireGuard** VPN szervereket használok, de kipróbáltam a **Tailscale**-t és a **NordVPN Meshnet** rendszerét is.
- A nyilvánosan elérhető szolgáltatások internet felől közvetlenül elérhetők, hogy ne legyen szükség VPN kliens beállítására a használatukhoz.
- A belső, privát szolgáltatások kizárólag VPN-en keresztül érhetők el, így csak a megfelelő jogosultsággal rendelkező felhasználók férhetnek hozzájuk.
- A **full tunnel** mód beállításával a telefon a **AdGuard Home forwarder DNS-t** használja reklámblokkolásra.
---

<a name="apt"></a>
## 1.4 APT Cache NG

---

### 1.4.1 Miért használom?

- Hajnali 3-ra időzített **Ansible** által vezényelt VM és LXC frissítésekhez használom.  
- Cél: ne kelljen minden VM/LXC-re külön letölteni a csomagokat, felesleges adatforgalmat generálva.  
- A cache proxy tárolja a letöltött csomagokat, amiket egy kliens már kért. Ha egy másik gép kéri ugyanazt a csomagot, és szerepel a cache-ben, azaz van hit, akkor a gépek a frissítéseket az APT cache proxy szerverről töltik, nem az internetről, ezzel sávszélességet és adatforgalmat spórolok.

Látható, hogy volt olyan nap, amikor a találati arány 88,26% volt: a 34,05 MB forgalomból 30,05 MB-ot a cache-ből tudott kiszolgálni. A legrosszabb napokon is a 996 MB forgalomból 526 MB-ot szolgált ki, ami 52%-os hatékonyságot jelent. Összességében 6,3 GB adatot szolgáltatott, amelyből csupán 2,2 GB kellett az internetről letölteni, így kb. 4 GB sávszélességet spóroltam.
<div align="center">
  <img src="https://github.com/user-attachments/assets/d2e4134c-879c-4b88-b3f6-ccb0553a6d9f" alt="Leírás" width="800">
</div>

---

<a name="vlan"></a>
## 1.5 VLAN kialakítása és hálózati szegmentáció

- **Proxmox alatt VLAN interface létrehozása** (`vmbr0.30`), amely a `vmbr0` bridge-hez tartozik VLAN tag 30-cal.
- A `vmbr0` bridge-en **VLAN-aware** mód engedélyezése, hogy a VLAN tagek kezelése ne dobódjon el.
- A megfelelő **VM-ek VLAN taggel ellátása**, így elkülönültek a tag nélküli 2.0 hálózattól.
- **Új alhálózat létrehozása a VLAN számára** (192.168.3.0/24), default gateway a pfSense VLAN interfésze.
- **pfSense-en VLAN interfész létrehozása** és IP-cím kiosztása a VLAN hálózathoz.
- **pfSense firewall szabályok és NAT konfiguráció** a VLAN és más hálózatok közötti kommunikációhoz.
- **TP-Link SG108E switch VLAN konfigurálása** a trunkolt forgalom kezelésére.
- **Statikus route hozzáadása az ASUS routeren**, hogy az 1.0 hálózat elérje a VLAN hálózatot.
- **DHCP szolgáltatás engedélyezése** a pfSense VLAN interfészén.

---

<a name="reverseproxy"></a>
## 1.6 Reverse Proxy

Azért használok Reverse Proxy-t, mert egyszerű és átlátható módon teszi lehetővé az **SSL/TLS tanúsítványok kezelését** a homelab szolgáltatásaimhoz.

- Könnyen hozzárendelhető egy wildcard tanúsítvány minden aldomainhez
- Elrejti a belső szerverek IP-címét, portját és útvonalát az URL-ből, ami növeli a biztonságot és egyszerűsíti a hozzáférést
- Grafikus felületének köszönhetően gyorsan és átláthatóan konfigurálható

---

### 1.6.1 Lokális DNS nevek használata (Nginx / Traefik)

**Fontos tervezési elv**, hogy **sem Nginx, sem Traefik esetén nem fix IP-címeket használok**, hanem **lokális DNS neveket**.

Ennek oka, hogy **IP-cím változás esetén ne kelljen minden konfigurációt módosítani** – elegendő legyen **csak a központosított DNS szerveren átírni** az adott rekordot.

Ez a megközelítés:
- **rugalmasabb** – IP-csere esetén nincs újrakonfigurálás
- **átláthatóbb** – beszédes hostnevek fix IP-címek helyett

---

### 1.6.2 SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard megoldás

A homelab környezetben a böngésző figyelmeztetett, mert a szolgáltatások nem HTTPS-en keresztül voltak elérhetők.  
A megoldás az volt, hogy **Reverse Proxy-t használok Let’s Encrypt SSL/TLS tanúsítvánnyal**, **DNS-01 challenge** alapú hitelesítéssel.

**Lényeg röviden**
- A HTTPS használatához SSL/TLS tanúsítvány szükséges
- A **DNS-01 challenge** egy DNS TXT rekord segítségével igazolja a domain tulajdonjogát
- A hitelesítés **Cloudflare API token** használatával történik
- A Reverse Proxy ideiglenes TXT rekordot hoz létre  
  (`_acme-challenge.trkrolf.com  TXT  <ACME azonosító>`)

---

<a name="radiusldap"></a>
## 1.7 RADIUS & LDAP

---

### 1.7.1 FreeIPA szerver mint LDAP (CentOS 9)

- Egységes felhasználó- és jogosultságkezelés az infrastruktúrán belül.

---

#### 1.7.1.1 Megvalósított funkciók

- Felhasználók létrehozása és kezelése.
- Sudo jogokkal rendelkező felhasználók konfigurálása.

---

### 1.7.2 FreeRADIUS szerver mint RADIUS – Pfsense GUI hitelesítés

---

#### 1.7.2.1 Megvalósított funkciók

- **Pfsense-re RADIUS beléptetéssel**: a Pfsense GUI-ra  bejelentkezés Radius hitelesítéssel.
- **Authentication fallback**: ha a RADIUS szerver leáll, a lokális felhasználóval is be lehet jelentkezni.
- **A lokális és RADIUS felhasználók neve/jelszava azonos**, így a felhasználónak nem kell tudnia, melyik hitelesítésen keresztül lép be.
- **SQL adatbázis + PhpMyAdmin**: a felhasználók és jogosultságok kényelmesen kezelhetők grafikus felületen, így nem kell fájlokban szerkeszteni vagy logolni, hanem közvetlenül az adatbázisból történik a kezelés.

---

<a name="reklamszures"></a>
## 1.8 Reklámszűrés
### 1.8.1 Pi-hole 

A Pi-hole célja: **DNS alapú reklámszűrés a homelab hálózaton**.

---

#### 1.8.1.1 Hálózati integráció

- **WireGuard VPN-be integrálva**:  
  - Minden kliens, például a telefon, a Pi-hole DNS-en keresztül kap reklámszűrést, még internetkapcsolat esetén is.
- Upstream DNS szerver: lokális **BIND9** szerver. 

---

<img src="https://github.com/user-attachments/assets/2d1971e8-aa55-4ebf-9fb2-3b0e95681515" alt="Kép leírása" width="700"/>

---

<a name="pxe"></a>
## 1.9 PXE Boot Server
### 1.9.1 iVentoy

A cél: Nem kell minden gépen külön telepítőt futtatni USB-ről vagy CD-ről, segítségével bármilyen iso-t futtathatok (Clonezilla, Windows telepítő, Ubuntu telepítő stb.).

---

### 1.9.2 Tesztek

- **Clonezilla futtatása**:
  - gépek klónozására SSH kapcsolaton keresztül.  
  - disaster recovery tesztelés Clonezillával

- **Automatikus indítás**:  
  - iVentoy service létrehozva, így a rendszer **indításakor elindul**, jobb megoldás, mint cron-al indítani.

**A lenti képen látható a legalsó sorban, hogy csatlakozott a PXE szerverhez egy gép.**

<img width="800" alt="kép" src="https://github.com/user-attachments/assets/b9906010-79dc-44ec-b386-403fbe40a8f9" />

---

<a name="dns"></a>
## 1.10 DNS
### 1.10.1 Publikus domain (Namecheap, Cloudflare)

- Saját domain vásárlva **Namecheap**-en, majd **Cloudflare** nameserverre átköltöztetve.  
- Publikus szolgáltatások: **nem elérhetők közvetlenül**; lokálisan érem el, távolról **VPN-en keresztül**.
- 
### 1.10.2 Privát domain (Bind9)

- Privát domain: **`otthoni.local`**  
- Feloldás: **BIND9 DNS szerver**
- 
- **Bind9** szolgáltatásom két célt szolgál:  
  1. Az **otthoni `.local` domain**-re autoritatív, így az otthoni gépek és szolgáltatások mindig elérhetők.  
  2. A **`trkrolf.com`** domain felülírása LAN-ról kérdezve az **NGINX szerverem IP-címére**, így internetkapcsolat hiányában is elérem az otthoni szolgáltatásokat, mivel a névfeloldás nem a Cloudflare nameserverről történik.  

- Részlet a BIND9 db.otthoni.local zónafájljáról
<img src="https://github.com/user-attachments/assets/12686bdf-316a-4b5a-9f78-95d481fe005f" alt="Kép leírása" width="500"/>
---

#### 1.10.2.1 DNS override

- A homelab hálózaton belül a `*.trkrolf.com` kéréseket **a lokális DNS IP-címére irányítom**.  
- Előny:  
  - Nem a publikus DNS szerver oldja fel a nevet  
  - Internetkapcsolat nélkül is működik az otthoni szolgáltatások elérése

---

<a name="hibakereses"></a>
## 1.11 Hálózati hibakeresés
### 1.11.1 Wireshark Alapok

Segítségével gyorsan lehet diagnosztizálni hálózati problémákat és megérteni az alapvető protokollok működését.

**Protokollok gyakorlati tanulmányozására használtam, a mélyebb megértés érdekében (DNS, DHCP, ARP, TCP)**:
- **DNS** lekérdezések és válaszok követése
- **DHCP** üzenetek figyelése
- **ARP** kommunikáció nyomon követése
- **TCP 3-way handshake** vizsgálata

---

<a name="dhcp2"></a>
## 1.12 DHCP

[LSD pfSense](#dhcp)  

← [Vissza a Homelab főoldalra](../README_HU.md)














