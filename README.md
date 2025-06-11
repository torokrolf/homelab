# 🏡 Homelabom rövid összefoglalója (folyamatosan bővül)

## Bemutatkozás
Ez a projekt egy önállóan kialakított homelabot mutat be, amely egy vállalati környezet modellez, a hálózati biztonság alapjait is szem előtt tartva. Windows és Linux megoldásoakt egyaránt tartalmaz. A konkrét megvalósításhoz és a mögöttes elmélet elsajátításához Udemy-n vásárolt videók, Youtube videók, angol nyelvű cikkek és fórumok sokat segítettek. Elkezdtem használni a ChatGPT is, amit hasznosnak találtam, de tudni kell jól kérdezni, és fenntartásokkal kezelni a válaszokat,  de az információgyűjtést egyértelműen felgyorsítja.

❗❗❗Részletes dokumentációt készítettem az installálási folyamatokról, konfigurációs fálokról, mit és hogyan állítottam be, felmerülő problémákról és megoldásaikról, de ezeket nem kerültek publikálásra. 

> 🎯 **Célom**:
Az elméleti tudásom mellett gyakorlati tapasztalat szerzése, új technológiák kipróbálása és megismerése. A technológiák kiválasztásakor figyelembe vettem a jelenlegi munkaerőpiaci trendeket, de az erre rendelkezésemre álló büdzsét is.
Emellett fontos szempont volt, hogy az álláspályázatok során a munkáltatók könnyebben megismerhessék a tudásomat, hogy én vagyok-e a keresett személy, segítve így a kiválasztási folyamatot.

---

## 🛠️ Felhasznált technológiák általános áttekintése

| Terület              | Használt eszközök                       |
|----------------------|---------------------------------------------------|
| **OS** | CentOS 9 Stream, Ubuntu 22.04 desktop, Ubuntu 22.04 server, Windows 11, Windows Server 2019      |   
| **Virtualizáció**     | Proxmox VE (2 gépen), LXC, VM, Template + Cloud init  |
| **Tűzfal-router** | pfSense   |
| **DHCP** | ISC-KEA, Windows Server 2019 DHCP szerver   |   
| **DNS** | DNS (Bind9) + Namecheap + Cloudflare, Windows Server 2019 DNS szerver |
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
- **Publikus és privát domain névoldásának mechanizmusa:** Én a **Namecheap-en** regisztráltam saját domain-t, amit a **Cloudflare** nameserverre költöztettem. Publikusan nem tettem elérhetővé szolgáltatásokat. Az **Nginx Proxy Manager** segítségével a szolgáltatásaimat nevükön érem el, és nem kell IP címeket portszámokkal megjegyeznem. **SSL tanúsítványt** is szereztem az Nginix Proxy Manager-en futó Let's Encrypt szolgáltatással, ehhez jól jött a korábban regisztrált publikus domain, a **DNS 01 challanger + wildcard** megvalósításához. A privát domainem (otthoni.local) a **Bind9** DNS szerverem oldja fel, amit nem tud feloldani, a 8.8.8.8-ra forwardolja. **DNS override-ot** is alkalmazok annak érdekében, hogy ha a homelabommal egy hálózaton vagyok, akkor példáu a nextcloud.trkrolf.com kérést ne a publikus DNS szerverek oldják fel, hanem az én privát DNS szerverem. Ennek érdekében a *.trkrolf.com-ot a lokális DNS szerverem ip címére irányítom.
- **VPN:** A távoli elérésre egy ideig Tailscale-t használtam, kipróbáltam az OpenVPN-t is, de végül aktívan a Wiregard használata mellett döntöttem. Így például telefon kényelmesen elérem az otthoni hálózatomat, vagy a full tunnel segítségével az otthoni Pi-hole DNS szűrőmet használhatom a reklámok ellen.
- **Távoli elérés:** Guacamole-t használok, aminek előnye, hogy egy böngészőablakban elérhetek több gépet.
- **Monitorozás:** Zabbix Agent beállítása Linux és Windows gépre. Csináltam pár alap **problem triggerelést**, például 1 percig nem pingelhető egy gép, szabad tárhely egy szint alá csökken, CPU használtal egy érték fölő megy. Ugyanezeket riasztásban is megvalósítottam, **email értesítést** küldve. Saját **dashboard** létrehozása.
- **Ansible automation:** Használom CLI-ből és Semaphroe Web UI-ból egyaránt. Playbook segítségével VM és LXC frissítéseket automatizálom, közös usereket hozok létre, közös konfig fájlokat szerkesztek (pl.: NTP szerver megadása), időzóna beállítása.
- **Rendszer backup:** A **Clonezillával** mentem el a Proxmox partíciót blokkszinten. Egy Proxmoxon virtualizált **Proxmox Backup Serverre** mentem a másik fizikai gépen futó VM és LXC példányokat.
- **Személyes fájlok backupja/szinkronizációja:**  **Nextcloud-ot** használok a fájlok megosztására a laptopommal. A fényképeimet a telefonomról egyirányú szinkronizációval mentem a homelabomra **FolderSync-el**, ugyanígy laptopomon erre a **FreeFileSync-et** használom. 
- **Reklámszűrés:** Pi-hole-t használok böngészéshez, hogy a reklálmokat DNS kérés szintjén szűrje, upstream szervere a BIND9 szerverem.
- **APT cache proxy:** Hajnali 3-ra időzítettem az Ansible által vezényelt VM és LXC updatelést, naponta. Feleslegesnek éreztem, hogy sokszor ugyanazt a frissítést, tegyük fel 10 alkalommal az internetről szedje le. Elég lenne 1-szer leszedni, és egy gép továbbosztaná ezt annak, akinek kell a kérdéses csomag. A cache proxy segítségével elérem, hogy cacheli a letöltött csomagokat.
- **Dashboard:** A sok szolgáltatás közötti válogatás kezdett kényelmetlen lenni, így dashboard-ra rendezve könnyebb az indításuk. Erre én a Homarr dashboard szolgáltatást használom.
- **Radius, LDAP:** FreeRadius-al beállítottam, hogy rajta keresztül a Pfsense GUI-ra be tudjak jelentkezni. Természetesen van lokális userem, ha a radius szerver nem üzemelne, akkor is be tudjak jelentkezni. A lokális user és a radius user felhasználóneve és jelszava azonos, hogy a usernek ne kelljen tudnia, hogy most éppen a radius szerveren keresztül vagy a lokális useren keresztül tud-e belépni. Phpmyadmidn-t telepítettem, hogy kényelmesebben lássam az adatbázisoakt.
- **IDS/IPS:** CrowdSec segítségével jelenleg firewall-bouncer-nftables helyi bouncer-t használok, és a CrowdSec konzolt beállítottam. 
- **SSH biztonságossá tétele**: **Timeout** beállítása, jelszó helyett **SSH key** használata, lehetőség szerint **root user tiltása** SSH-n.

---

## 🔮 Jövőbeli tervek (folyamatosan bővöl)

- **Monitorozás továbbfejlesztése** Grafana + Prometheus megismerése. Zabbix-al elkezdtem ismerkedni, de az Udemy videót félbehagytam, ezt befejezni.
- **Cloud computing elmélyítése:** Érdekel ez a terület, szeretném jobban megismerni (AWS, Azure).
- **Cloud storage** (Hetzned vagy Pcloud).
- **Magas rendelkezésre állás:** Három darab 2,5"-os SSD és egy Lenovo M920q Tiny PC beszerzése van tervben, amelyre Proxmoxot telepítek, hogy a meglévő gépeimmel együtt háromtagú **klasztert** alakíthassak ki. A célom, hogy a három SSD-t **Ceph**-be integráljam.
- **DIY PiKVM:**  KVM over IP hasznos lenne, ám az olcsóbb alternatívája, a PiKVM is igen költséges, ha készen veszi az ember, így én megamtól építeném meg. Venni szeretnék használtan RPI 4-et, amit megosztana a három gép között egy USB switch és HDMI switch. Az olcsóbb switch-ek csatornaváltása gombbal történik, én a gombot lecserélném egy ESP32-vel vezérelt tranzisztorra. Ehhez persze fontos, hogy a switch-ek könnyen szétszedhetőek legyenek, nagyobb roncsolás nélkül. Kicsit költségesebb, ha három RPI4-et veszek, minden géphez egyet, így nem kell USB switch és HDMI switch, és egyszerre mindhárom gép vezérelhető böngészőből, nem kell váltani köztük.
- **IDS/IPS továbbfejlesztése:** CrowdSec beállítása Nginx Proxy Managerre, és Suricata implementálása.
- **Biztonság és mentés bővítése:** Rsync, Rclone megismerése. Bareos és Kopia alkalmazása ezidáig sikeretelen volt, a klienseket nem tudom bevonni, ezt megoldani.
- **Komolyabb switch vásárlása:** Ki szeretném próbálni a 802.1x port based autentikációt és beállítani a Radius felügyeletet a portokon. DHCP snooping és port security által még tovább növelhetném a biztonságot.
- **DNSSEC** 
- **Python** programozási nyelv mélyebb megismerése.

---

## 🖼️ Projekt képernyőképek

- Hálózati topológiám
<img src="https://github.com/user-attachments/assets/fc9e9cd0-65cb-4c82-87c7-5d898270f6b1" alt="Kép leírása" width="700"/>

- Proxmox interfész VM/LXC listával
<img src="https://github.com/user-attachments/assets/57194fcc-daf3-44e3-86fc-ff3ca8bb0144" alt="Kép leírása" width="600"/>

- Proxmox Backup Server mentések
<img src="https://github.com/user-attachments/assets/d700185b-89c6-47a2-ada7-5a3d8ed707bd" alt="Kép leírása" width="700"/>

- Homarr dashboard
<img src="https://github.com/user-attachments/assets/ef9a5781-1872-4bb6-9933-77cbfd524f54" alt="Kép leírása" width="700"/>

- Nginx Proxy Manager-ből egy részlet a proxy hosts-ról
<img src="https://github.com/user-attachments/assets/0ef39cc8-e57b-450f-8bc1-836287ca640f" alt="Kép leírása" width="700"/>

- Pi-hole
<img src="https://github.com/user-attachments/assets/688a9e5b-2ae9-4ff7-80dc-de0ca6e5379f" alt="Kép leírása" width="700"/>

- Részlet a BIND9 db.otthoni.local zónafájljáról
<img src="https://github.com/user-attachments/assets/f9ab28e9-3c35-4b7e-b2ea-a1fdb786f6c7" alt="Kép leírása" width="500"/>

---
**Köszönöm, hogy megnézted!**

