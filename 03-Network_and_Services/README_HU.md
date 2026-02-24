← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Network and Services

---

## 1.1 Network and Services áttekintés

| Szolgáltatás / Terület                 | Eszközök / Szoftverek                                     
|----------------------------------------|----------------------------------------------------------
| [1.2 Tűzfal / Router](#pfsense)        | pfSense                                                  
| [1.3 VPN](#vpn)                        | Tailscale, WireGuard, OpenVPN, NordVPN                   
| [1.4 APT cacher proxy](#apt)            | APT-Cacher-NG                                             
| [1.5 VLAN](#vlan)                      | TP-LINK SG108E switch                                    
| [1.6 Reverse Proxy](#reverseproxy)     | Nginx Proxy Manager (lecserélve), Traefik (jelenlegi)    
| [1.7 IAM](#iam)       | FreeRADIUS, FreeIPA                                      
| [1.8 Reklámszűrés](#reklamszures)      | Pi-hole (lecserélve), AdGuard Home (jelenlegi)                                                  
| [1.9 PXE Boot](#pxe)                   | iVentoy                                                  
| [1.10 DNS](#dns)                       | BIND9, Namecheap, Cloudflare, Windows Server 2019 DNS    
| [1.11 Hálózati hibakeresés](#debug)    | Wireshark                                                
| [1.12 DHCP](#dhcp2)                    | ISC-KEA, Windows Server 2019 DHCP                        
| [1.13 Notification](#notification)   | Gotify 

**A homelab hálózat topológiája az alábbi diagramon látható:**
```mermaid
graph TD
    %% Global
    Internet((Internet)) --- Asus[ASUS Router]

    %% Home Network Section
    subgraph Home_Net ["Home Network"]
        Subnet["192.168.1.0/24"]
        TV["TV"]
        Phone["Phones"]
        Laptop["Laptops"]
    end
    Asus --- Subnet
    Subnet --- TV
    Subnet --- Phone
    Subnet --- Laptop

    %% Homelab Entry Point
    Entry_IP["pfSense WAN: 192.168.1.196"]
    Asus --- Entry_IP

    %% HOMELAB SYSTEM
    subgraph Homelab_System ["HOMELAB SYSTEM"]
        direction TB

        %% Node2 - Firewall Node
        subgraph Node2 ["Proxmox 2 - M920q (Firewall)"]
            P2_WAN["vmbr0 - WAN Bridge <br/> IP: 192.168.1.198"]
            pfS{pfSense VM <br/> GW: 192.168.2.1}
            P2_LAN["vmbr1 - LAN Bridge <br/> IP: 192.168.2.198"]

            P2_WAN -- "enp1s0f0" --- pfS
            pfS -- "enp1s0f1" --- P2_LAN
        end

        Entry_IP --- P2_WAN

        %% Physical Switch
        subgraph Switch ["TP-Link TL-SG108E Switch"]
            SW_P1[Port 1] -- "VLAN 30 Trunk" --- SW_P8[Port 8]
        end

        P2_LAN --- SW_P1
        SW_P8 --- P1_NIC

        %% Node1 - Compute Node
        subgraph Node1 ["Proxmox 1 - M70q (Server)"]
            P1_NIC["NIC: enx503eaa522d61"]
            P1_Bridge["vmbr0 - VLAN Aware <br/> IP: 192.168.2.199"]

            P1_NIC --- P1_Bridge

            subgraph Subnets ["VLAN Networks"]
                P1_Bridge -- "Native" --- LAN2["192.168.2.0/24"]
                P1_Bridge -- "VLAN 30" --- VLAN3["192.168.3.0/24"]
            end

            subgraph VMs ["Virtual Resources"]
                LAN2 --- Linux["Linux Systems"]
                VLAN3 --- Windows["Windows Systems"]
            end
        end
    end

    %% Styles
    style Home_Net fill:#fffbe6,stroke:#d4a017
    style Entry_IP fill:#fff3cd,stroke:#d4a017,font-weight:bold
    style pfS fill:#f96,stroke:#333
    style Homelab_System fill:#f8f9fa,stroke:#333,stroke-dasharray: 8 4
    style Node1 fill:#fff
    style Node2 fill:#fff
```

---

<a name="pfsense"></a>
## 1.2 pfSense

A homelabomban egy **pfSense alapú tűzfalat és routert** használok a forgalom kezelésére.

### 1.2.1 NAT és Routing
- **Outbound NAT** konfiguráció a belső hálózatok számára.
- **Port Forward NAT** a külső szolgáltatások közzétételéhez.
- **Belső hálózatok közötti forgalomirányítás** (Inter-VLAN routing).

<a name="dhcp"></a>
### 1.2.2 DHCP szerver konfiguráció és működés
- **IP tartományok kezelése**: Granuláris kontroll a kiosztások felett.
- **Statikus DHCP foglalások**: Fix IP címek az infrastruktúra elemeinek.
- **Gateway és DNS kiosztás**: Automatikus kliens konfiguráció.
- **Statikus ARP bejegyzések**: A szerverek és kliensek a 2.0-s hálózaton statikus IP–MAC kötést kapnak, ami védelmet nyújt az **ARP spoofing** ellen.
- **Menedzsment hozzáférés**: A switch manuálisan beállított statikus IP-t kapott, hogy a menedzsment felület a DHCP szervertől függetlenül is mindig elérhető legyen.

### 1.2.3 NTP szerver futtatása <a name="ntp"></a>
- Központi időszinkronizáció a belső kliensek számára.
- A kliensek a **chronyd** szolgáltatást használják.
- A pfSense szolgál NTP szerverként minden LXC és VM számára (kivéve a FreeIPA LXC-t).

### 1.2.4 WireGuard VPN
- Modern, gyors és alacsony késleltetésű VPN megoldás.
- Biztonságos távoli hozzáférést biztosít a belső hálózathoz.

### 1.2.5 OpenVPN
- Tanúsítvány alapú hitelesítés a magas szintű biztonságért.
- Széleskörű kompatibilitás különböző kliensekkel.
- Egyedi tűzfalszabályok és forgalomirányítás a VPN tunnelen keresztül.

### 1.2.6 Dinamikus DNS (DDNS)
- A dinamikus publikus IP változások automatikus kezelése Cloudflare API-n keresztül.
- Biztosítja a **VPN hálózat folyamatos elérhetőségét az internet felől**, függetlenül az IP változásoktól.

---

<a name="vpn"></a>
## 1.3 VPN használata a Homelabban

- **OpenVPN**-t és **WireGuard**-ot használok, de teszteltem a **Tailscale** és **NordVPN Meshnet** megoldásokat is.
- **Publikus szolgáltatások**: Közvetlenül elérhetők az internetről (Reverse Proxy-n keresztül) VPN nélkül is.
- **Belső szolgáltatások**: Kizárólag **VPN-en keresztül** érhetők el, biztosítva a menedzsment felületek védelmét.
- **Full Tunnel**: Mobilról engedélyezve a teljes forgalom a hazai hálózaton megy át, így távolról is élvezhetem a **Pi-hole / AdGuard Home** reklámszűrését.

---

<a name="apt"></a>
## 1.4 APT Cacher NG

### 1.4.1 Miért használom?

- Az **Ansible-al ütemezett VM és LXC frissítésekhez** (hajnali 3 órára beállítva) optimalizálva.
- Megakadályozza, hogy minden gép egyenként töltse le ugyanazokat a csomagokat, így jelentős sávszélességet takarít meg.
- **Hatékonyság**: Ha egy gép letölt egy frissítést, a többi már helyi hálózati sebességgel éri el a gyorsítótárból.

Volt olyan nap, amikor a "cache hit" arány elérte a **88,26%-ot**: a 34,05 MB-os forgalomból 30,05 MB a helyi cache-ből szolgált ki a rendszer. Összességében több gigabájtnyi adatot takarít meg a rendszer az internetes sávszélességen.

<div align="center">
  <img src="https://github.com/user-attachments/assets/d2e4134c-879c-4b88-b3f6-ccb0553a6d9f" width="800" alt="APT Cache statisztika">
</div>

---

<a name="vlan"></a>
## 1.5 VLAN és hálózati szegmentáció

- **Proxmox integráció**: VLAN-aware bridge (`vmbr0`) és tag-elt interfészek (pl. `.30`).
- **Izoláció**: Új alhálózat létrehozása (192.168.3.0/24) tesztelési célokra.
- **Hardveres támogatás**: VLAN trunk konfiguráció a TP-Link switch-en.
- **Tűzfalszabályok**: Szigorú szabályozás pfSense-en a hálózati szegmensek közötti mozgás korlátozására.

---

<a name="reverseproxy"></a>
## 1.6 Reverse Proxy

Központosított **SSL/TLS tanúsítványkezelés** és forgalomirányítás.

### 1.6.1 Helyi DNS nevek használata (Nginx / Traefik)

Soha nem használok fix IP-ket a proxy konfigokban — kizárólag DNS neveket.
- **Előny**: IP cím változás esetén nem törik el a proxy, csak a belső DNS-t kell frissíteni.
- **Olvashatóság**: Tisztább, átláthatóbb setup.

### 1.6.2 SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard

- **Biztonság**: Teljes HTTPS titkosítás Let’s Encrypt segítségével.
- **Validálás**: DNS-01 challenge a Cloudflare API-n keresztül.
- **Előny**: Lehetővé teszi a wildcard tanúsítványok (pl. `*.trkrolf.com`) használatát belső portok megnyitása nélkül.

---

<a name="iam"></a>
## 1.7 IAM

### 1.7.1 FreeIPA mint LDAP
- Központosított felhasználó- és jogosultságkezelés a teljes laborban.
- Sudo szabályok egységes konfigurációja.

### 1.7.2 FreeRADIUS
- **pfSense autentikáció**: A pfSense GUI-ba való belépés RADIUS-on keresztül történik.
- **Kezelés**: SQL + PhpMyAdmin integráció a felhasználók kezeléséhez.
- **Biztonsági tartalék**: Helyi felhasználó fallback beállítva a kizáródás megelőzésére.

---

<a name="reklamszures"></a>
## 1.8 Reklámszűrés

### 1.8.1 AdGuard Home

- DNS-alapú hálózati szintű reklám- és követő kód szűrés.
- Integrálva a WireGuard VPN-be a mobilvédelem érdekében.

Lenti ábrán láthatom a **conditional forwarding** szabályaimat.
<p align="center">
  <img src="https://github.com/user-attachments/assets/5bc5cc50-6947-431d-8b6c-1161a748a0d1" alt="Description" width="1000">
</p>

Lenti ábrán láthatom a felhasznált blokklistát.
<p align="center">
  <img src="https://github.com/user-attachments/assets/50c1749c-4005-4c74-a390-d18acc6c9442" alt="Description" width="1000">
</p>

---

<a name="pxe"></a>
## 1.9 PXE Boot – iVentoy

- Hálózati ISO bootolás (Clonezilla, Windows, Ubuntu telepítők).
- Megszünteti a fizikai pendrive-ok szükségességét; a telepítők közvetlenül a hálózaton keresztül töltődnek be.

---

<a name="dns"></a>
## 1.10 DNS architektúra

### 1.10.1 Publikus DNS szerver (Namecheap + Cloudflare)
- **Namecheap** domain registar-on vásároltam a domain-em, de **Cloudflare** a DNS provider, delegáltam a domainem a nameservereire.
**Miért a Cloudflare?**
  - DNS-01 Challenge: Lehetővé teszi a Traefik számára a Wildcard SSL tanúsítványok automatikus igénylését a Cloudflare API-n keresztül, jóval egyszerűbben, mint Namecheap-en.
  - Gyorsabban frissülnek a rekordjai.

### 1.10.2 Privát DNS szerver (Bind9)
- Helyi zóna: otthoni.local.
- **DNS override**: A wildcardolt trkrolf.com (*.trkrolf.com) rekordok belső hálózaton közvetlenül a Traefik helyi IP-re oldódik fel, kikerülve a külső lekérdezést.

### 1.10.3 Privát Rekurzív Resolver (Unbound)
Az **Unbound** a rendszer független feloldó szervere, amely elsődlegesen a külső lekérdezések **anonimitásáért** felel.
- **Anonimitás és Privacy**: Az Unbound maga deríti fel a publikus nameservereket iteratív kérésekkel, így a nagy szolgáltatók nem tudják naplózni és profilozni a teljes böngészési előzményt, és véd a DNS-szintű manipuláció ellen.
- **Caching**: A már feloldott címeket helyben tárolja, ami jelentősen csökkenti a válaszidőt a hálózaton belüli ismételt kérések esetén.

### 1.10.4 Bind9 + AdGuard Home + Unbound + Traefik működési logikája

Amennyiben lokális domainre vonatkozó lekérdezés történik, az AdGuard Home-ban **conditional forwarding**-ban megadott szabály alapján, az otthoni.local alapján a Bind9 szerverre továbbítja, a Bind9 válaszol.  
<p align="center">
  <img src="https://github.com/user-attachments/assets/f206bb3b-717e-4261-9a22-ffe9b7f50997" alt="Description" width="500">
</p>

Ha a saját publikus domainemre vonatkozó lekérdezés történik, az AdGuard Home-ban **conditional forwarding**-ban megadott szabály alapján, a trkrolf.com noha publikus domain, mégis akár az otthoni.local-t, a Bind9 szerverre továbbítja, a Bind9 válaszol, mivel **overrideolva** van, mégpedig a Traefik IP címét adja vissza.   
<p align="center">
  <img src="https://github.com/user-attachments/assets/0ca53c15-93eb-46f0-9ee7-a7ca9cb68917" alt="Description" width="500">
</p>

Ha egy publikus domainre vonatkozó lekérdezés történik, az AdGuard Home-ban **conditional forwarding**-ban megadott szabály alapján, mivel ez nem az otthoni.local vagy a trkrolf.com domain, így az Unbound szerverre továbbítja, ami  felkeresi a szervereket.   
<p align="center">
  <img src="https://github.com/user-attachments/assets/f99e3d13-de1e-4dbc-bb03-467948f9d915" alt="Description" width="500">
</p>

---

<a name="debug"></a>
## 1.11 Hálózati hibakeresés – Wireshark

Mélyreható csomagelemzés a következők tanulmányozására:
- DNS, DHCP és ARP kézfogások.
- TCP/IP folyamatok és hálózati teljesítmény ellenőrzése.

---

<a name="dhcp2"></a>
## 1.12 DHCP

A részletes DHCP konfiguráció a [pfSense DHCP fejezetben](#dhcp) található.

---
<a name="notification"></a>
## 1.13  Notification

### 1.13.1 Gotify

**Gotify** egy könnyű, saját hosztolt szerver valós idejű értesítések küldésére, hogy gyorsan értesüljek hibákról, állapotokról.  

**Előnyök:**
- **Saját hosztolt:** Teljes kontroll, nincs harmadik fél függés.
- **Egyszerű API:** Könnyen integrálható scriptekkel, **webhookkal**.
- **Valós idejű értesítések:** Push értesítések mobilra azonnal.

**Hol használom?**  
- Proxmox ha elveszíti a TrueNAS mountolásokat, erről értesítést kapok. ❗ Script: [/11-Scripts/proxmox/mount-monitor](/11-Scripts/proxmox/mount-monitor)
- Proxmox-ról értesítést kapok warnings/errors témákban, például ha kevés a lemezhely. Promox GUI-ban beállítható.
- S.m.a.r.t. hibákról kapok értesítést. ❗ Script: [/11-Scripts/proxmox/S.M.A.R.T.](/11-Scripts/proxmox/S.M.A.R.T.)
- Radarr/Sonarr ha végez a film/sorozat letöltésével, értesítést kapok erről. Radarr/Sonarr GUI-ja támogatja natívan, GUI-ból.
- Ansible update playbookom, ami updateli a klienseket, ha lefut, akkor ennek eredményéről értesítést kapok, hogy sikeresen vagy sikertelenül futott-e le.❗ Script: [/06-Automation/Ansible_Semaphore/Playbooks/upgrade-system.yaml](/06-Automation/Ansible_Semaphore/Playbooks/upgrade-system.yaml)
- Proxmox Backup Server-re törtétnő VM/LXC mentés után az eredményről értesítést kapok. PBS GUI-ban beállítható.
- Proxmox Backup Serveren a backupok verifikálásának eredményéről. PBS GUI-ban beállítható.
- Proxmox Backup Serveren a prune lefutásakor. PBS GUI-ban beállítható.

Lenti képen látható, 2 órán át nem volt elérhető a NAS és erről kaptam értesítést.
<p align="center">
  <img src="https://github.com/user-attachments/assets/1d20223d-ad7e-4579-a75d-40b5fbe3fe66" alt="Description" width="500">
</p>

---

← [Vissza a Homelab főoldalra](../README_HU.md)

























