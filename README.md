# 🏡 Homelabom rövid összefoglalója (folyamatosan bővül)

## 🏠 Homelab projekt ismertetése

Ez a projekt egy saját tervezésű, vállalati szintű homelab környezetet mutat be, ahol Linux és Windows rendszereken gyakorlok virtualizációt, hálózatbiztonságot és üzemeltetést. Windows és Linux megoldásokat egyaránt tartalmaz. A konkrét megvalósításhoz és a mögöttes elmélet elsajátításához Udemy-n vásárolt videók, YouTube videók, cikkek és fórumok sokat segítettek, mindez angol nyelven. Elkezdtem használni a ChatGPT is, amit hasznosnak találtam, az információgyűjtést és keresést drasztikusan felgyorsítja.

❗❗❗Részletes dokumentációt készítettem az installálási folyamatokról, konfigurációs fájlokról, mit és hogyan állítottam be, felmerülő problémákról és megoldásaikról, de ezek itt nem kerültek publikálásra. 

> 🎯 **Célom**:
Az elméleti tudásom mellett gyakorlati tapasztalat szerzése, új technológiák kipróbálása és megismerése. A technológiák kiválasztásakor figyelembe vettem a jelenlegi munkaerőpiaci trendeket, amit olykor a célra rendelkezésemre álló büdzsé befolyásolt.
Emellett fontos szempont volt, hogy az álláspályázatok során a munkáltatók könnyebben megismerhessék a tudásomat, hogy én vagyok-e a keresett személy, segítve így a kiválasztási folyamatot.

---

## 🛠️ Felhasznált technológiák általános áttekintése

| Terület              | Használt eszközök                       |
|----------------------|---------------------------------------------------|
| **Operációs rendszer** | CentOS 9 Stream, Ubuntu 22.04 desktop, Ubuntu 22.04 server, Windows 11, Windows Server 2019      |   
| **Virtualizáció**     | Proxmox VE (2 gépen), LXC, VM, Template + Cloud init  |
| **Tűzfal-router** | pfSense   |
| **DHCP** | ISC-KEA, Windows Server 2019 DHCP szerver   |   
| **DNS** | DNS (BIND9) + Namecheap + Cloudflare, Windows Server 2019 DNS szerver |
| **VPN** | Tailscale, Wireguard, Openvpn|
| **Távoli elérés**     | SSH (Termius), RDP (Guacamole) |
| **Reverse proxy** | Nginx Proxy Manager               |
| **Monitorozás**       | Zabbix|
| **Automatizálás**     | Ansible+Semaphore, Cron+Cronicle       |
| **Biztonság és mentés**| Proxmox Backup Server, Clonezilla, Rclone, Nextcloud, FreeFileSync, Urbackup|
| **Reklámszűrés** | Pi-hole        |
| **APT cache proxy** | APT-Cache-NG        |
| **Dashboard** | Homarr        |
| **Radius, LDAP** | FreeRADIUS, FreeIPA |
| **Password management** | Vaultwarden        |
| **PXE boot** | iVentoy        |
| **IDS/IPS** | CrowdSec        |

---

## 🔍 Felhasznált technológiák részletesebb ismertetése

- **Windows Server 2019**: DNS Szerver, DHCP szerver beállítások, Active Directory kezelés (gépek domainbe vonása, user létrehozás, groupok kezelése).
- **Pfsense:** Beállítottam  pár **tűzfalszabályt** rajta, és szükséges volt **NAT**-olás. Futtatok rajta **DHCP szervert**, **NTP szervert**, **Wireguardot**, **OpenVPN-t**, beállítottam rajta **DDNS-t**.
- **Publikus és privát domain névoldásának mechanizmusa:** Én a **Namecheap-en** regisztráltam saját domain-t, amit a **Cloudflare** nameserverre költöztettem. Publikusan nem tettem elérhetővé szolgáltatásokat. Az **Nginx Proxy Manager** segítségével a szolgáltatásaimat nevükön érem el, és nem kell IP címeket portszámokkal megjegyeznem. **SSL tanúsítványt** is szereztem az Nginx Proxy Manager-en futó Let's Encrypt szolgáltatással, ehhez jól jött a korábban regisztrált publikus domain, a **DNS 01 challenge + wildcard** megvalósításához. A privát domainem (otthoni.local) a **BIND9** DNS szerverem oldja fel, amit nem tud feloldani, a 8.8.8.8-ra forwardolja. **DNS override-ot** is alkalmazok annak érdekében, hogy ha a homelabommal egy hálózaton vagyok, akkor például a nextcloud.trkrolf.com kérést ne a publikus DNS szerverek oldják fel, hanem az én privát DNS szerverem. Ennek érdekében a *.trkrolf.com-ot a lokális DNS szerverem ip címére irányítom.
- **VPN:** A távoli elérésre egy ideig Tailscale-t használtam, kipróbáltam az OpenVPN-t is, de végül aktívan a Wiregard használata mellett döntöttem. Így például telefonról kényelmesen elérem az otthoni hálózatomat, vagy a full tunnel segítségével az otthoni Pi-hole DNS szűrőmet használhatom a reklámok ellen.
- **Távoli elérés:** Guacamole-t használok, segítségével kényelmesen egy böngészőablakban elérhetek több gépet.
- **Monitorozás:** Zabbix Agent beállítása Linux és Windows gépre. Csináltam pár alap **problem triggerelést**, például 1 percig nem pingelhető egy gép, szabad tárhely egy szint alá csökken, CPU használtal egy érték fölő megy. Ugyanezeket riasztásban is megvalósítottam, **email értesítést** küldve. Saját **dashboard** létrehozása.
- **Ansible automation:** Használom CLI-ből és Semaphroe Web UI-ból egyaránt. Playbook segítségével VM és LXC frissítéseket automatizálom, közös usereket hozok létre, közös konfig fájlokat szerkesztek (pl.: NTP szerver megadása), időzóna beállítása.
- **Rendszer backup:** A **Clonezillával** mentem el a Proxmox partíciót blokkszinten. Egy Proxmoxon virtualizált **Proxmox Backup Serverre** mentem a másik fizikai gépen futó VM és LXC példányokat.
- **Személyes fájlok backupja/szinkronizációja:**  **Nextcloud-ot** használok self hosted fájlmegosztásra a laptopommal. A fényképeimet a telefonomról egyirányú szinkronizációval mentem a homelabomra **FolderSync-el**, ugyanígy laptopomon erre a **FreeFileSync-et** használom. 
- **Reklámszűrés:** Pi-hole-t használok böngészéshez, hogy a reklálmokat DNS kérés szintjén szűrje, upstream szervere a BIND9 szerverem.
- **APT cache proxy:** Hajnali 3-ra időzítettem az Ansible által vezényelt VM és LXC updatelést, naponta. Feleslegesnek éreztem, hogy sokszor ugyanazt a frissítést, tegyük fel 10 alkalommal az internetről szedje le. Elég lenne 1-szer leszedni, és egy gép továbbosztaná ezt annak, akinek kell a kérdéses csomag. A cache proxy segítségével elérem, hogy cacheli a letöltött csomagokat.
- **Dashboard:** A sok szolgáltatás közötti válogatás kényelmetlenné vált, így dashboard-ra rendezve könnyebb az indításuk. Erre én a Homarr dashboard szolgáltatást használom.
- **Radius, LDAP:** FreeRadius-al beállítottam, hogy rajta keresztül a Pfsense GUI-ra be tudjak jelentkezni. Természetesen van lokális userem, ha a radius szerver nem üzemelne, akkor is be tudjak jelentkezni. A lokális user és a radius user felhasználóneve és jelszava azonos, hogy a usernek ne kelljen tudnia, hogy most éppen a radius szerveren keresztül vagy a lokális useren keresztül tud-e belépni. Phpmyadmidn-t telepítettem, hogy kényelmesebben lássam az adatbázisoakt.
- **IDS/IPS:** CrowdSec segítségével jelenleg firewall-bouncer-nftables helyi bouncer-t használok, és a CrowdSec konzolt beállítottam. 
- **SSH biztonságossá tétele**: **Timeout** beállítása, jelszó helyett **SSH key** használata, lehetőség szerint **root user tiltása** SSH-n.

---

## 🔮 További tanulási és megvalósígási célkitűzéseim

- **Python** programozási nyelv mélyebb megismerése.
- - **Cloud computing:** Érdekel ez a terület, szeretném jobban megismerni (AWS, Azure).
- **Monitorozás továbbfejlesztése** Grafana + Prometheus megtanulása. Zabbix ismeretet elmélyíteni.
- **Cloud storage** (Hetzned vagy Pcloud).
- **Magas rendelkezésre állás:** Három darab 2,5"-os SSD és egy Lenovo M920q Tiny PC beszerzése van tervben, amelyre Proxmoxot telepítek, hogy a meglévő gépeimmel együtt háromtagú **klasztert** alakíthassak ki. A célom, hogy a három SSD-t **Ceph**-be integráljam.
- **DIY PiKVM:**  KVM over IP hasznos lenne. Venni szeretnék RPI 4-et, amin a PiKVM-et megvalósítanám.
- **IDS/IPS továbbfejlesztése:** CrowdSec elmélyítése, Nginx Proxy Managerre történő beállítása és Suricata implementálása.
- **Komolyabb switch vásárlása:** Ki szeretném próbálni a 802.1x port based autentikációt és beállítani a Radius felügyeletet a portokon. DHCP snooping és port security által még tovább növelhetném a biztonságot.

---

## 🖼️ Projekt képernyőképek

- Hálózati topológiám
<img src="https://github.com/user-attachments/assets/2c9e553e-bc88-44d1-8b1a-7349573afb81" alt="Kép leírása" width="700"/>

- Proxmox interfész VM/LXC listával
<img src="https://github.com/user-attachments/assets/7429e3db-88db-4365-9a8b-26ff0d13bc5e" alt="Kép leírása" width="500"/>

- Proxmox Backup Server mentések
<img src="https://github.com/user-attachments/assets/8da41e1f-81c7-4997-9749-a45668bd0832" alt="Kép leírása" width="800"/>

- Homarr dashboard
<img src="https://github.com/user-attachments/assets/befc202e-0867-4c7d-80f1-fca57f7bf42a" alt="Kép leírása" width="700"/>

- Nginx Proxy Manager-ből egy részlet a proxy hosts-ról
<img src="https://github.com/user-attachments/assets/3a8d190b-52aa-4a94-be9f-9aec13829945" alt="Kép leírása" width="700"/>

- Pi-hole
<img src="https://github.com/user-attachments/assets/2d1971e8-aa55-4ebf-9fb2-3b0e95681515" alt="Kép leírása" width="700"/>

- Részlet a BIND9 db.otthoni.local zónafájljáról
<img src="https://github.com/user-attachments/assets/12686bdf-316a-4b5a-9f78-95d481fe005f" alt="Kép leírása" width="500"/>

---
**Köszönöm, hogy megnézted!**

