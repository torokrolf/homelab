# 🏡 Homelabom rövid összefoglalója 

## 🏠 Homelab projekt ismertetése

Ez a projekt egy saját tervezésű, vállalati környezet szerű homelabot mutat be, ahol Linux és Windows rendszereken gyakorlok virtualizációt, hálózatbiztonságot és üzemeltetést. Windows és Linux megoldásokat egyaránt tartalmaz. A konkrét megvalósításhoz és a mögöttes elmélet elsajátításához Udemy-n vásárolt videók, YouTube videók, cikkek és fórumok sokat segítettek, mindez angol nyelven. Elkezdtem használni a ChatGPT-t is, amit hasznosnak találtam, az információgyűjtést és keresést drasztikusan felgyorsítja.

❗❗❗Részletes dokumentációt készítettem magamnak az installálási folyamatokról, konfigurációs fájlokról, mit és hogyan állítottam be, felmerülő problémákról és megoldásaikról, képekkel illusztrálva, de ezek itt nem kerültek publikálásra. 

> 🎯 **Célom**:
Az elméleti tudásom mellett gyakorlati tapasztalat szerzése, új technológiák kipróbálása és megismerése. A technológiák kiválasztásakor figyelembe vettem a jelenlegi munkaerőpiaci trendeket, amit olykor a célra rendelkezésemre álló büdzsé befolyásolt.
Emellett fontos szempont volt, hogy az álláspályázatok során a munkáltatók könnyebben megismerhessék a tudásomat,  és könnyebben eldönthessék, hogy én vagyok-e a keresett személy.

---

## 🔍 Felhasznált technológiák részletes ismertetése


- **VLAN:**  TP-LINK SG108E switch + Proxmox + pfSense segítségével megvalósítva, hogy a Windows és linux infrastruktúra elkülönüljön.
- **Távoli elérés:** Guacamole-t használok, aminek segítségével kényelmesen egy böngészőablakban elérhetek több gépet.
- **Monitorozás:** Zabbix Agent beállítása Linux és Windows gépre. Csináltam pár alap **problem triggerelést**, például 1 percig nem pingelhető egy gép, szabad tárhely egy bizonyos szint alá csökken, CPU használtal egy érték fölé emelkedik. Ugyanezeket riasztásban is megvalósítottam, **email értesítést** küldve.
- **Ansible automation:** Használom CLI-ből és Semaphore Web UI-ból egyaránt. Playbook segítségével VM és LXC frissítéseket automatizálom, közös usereket hoztam létre és SSH kulcsokat  osztottam meg, közös konfig fájlokat szerkesztek (pl.: NTP szerver megadása), időzóna beállítása.
- **Rendszer backup:** A **Clonezillával** mentem el image-be a Proxmox partíciót blokkszinten, **preseed** segítségével automatizálva. Egy Proxmoxon virtualizált **Proxmox Backup Serverre** pedig a VM és LXC példányokat mentését végzem. Laptopomat **Veeam Backup & Replication Community Edition**-el mentem egy smb megosztásba. 
- **Személyes fájlok backupja/szinkronizációja:**  **Nextcloud-ot** használok self hosted fájlmegosztásra a laptopommal, telefonommal. A fényképeimet a telefonomról egyirányú szinkronizációval mentem a homelabomra **FolderSync-el**, ugyanígy laptopomon erre a **FreeFileSync-et** használom. 
- **Reklámszűrés:** Böngészéshez **Pi-hole**-t használok, hogy a reklámokat DNS kérés szintjén szűrje, upstream szervere a BIND9 szerverem.
- **APT cache proxy:** Hajnali 3-ra időzítettem az Ansible által vezényelt VM és LXC updatelést, naponta. Felesleges minden VM/LXC-re külön letölteni. A cache proxy segítségével elérem, hogy cacheli a letöltött csomagokat, és amelyik gépnek szüksége van a frissítésekre, az a cache proxy-ról tölti le, és nem az internetről.
- **Dashboard:** A sok szolgáltatás közötti válogatás kényelmetlenné vált, így dashboard-ra rendezve könnyebb az indításuk. Erre én a Homarr dashboard szolgáltatást használom.
- **Radius, LDAP:** FreeRADIUS-al beállítottam, hogy rajta keresztül a Pfsense GUI-ra be tudjak jelentkezni. Természetesen van lokális userem, ha a radius szerver nem üzemelne, akkor is be tudjak jelentkezni. A lokális user és a radius user felhasználóneve és jelszava azonos, hogy a usernek ne kelljen tudnia, hogy  éppen a radius szerveren keresztül vagy a lokális useren keresztül tud-e belépni. PhpMyAdmin-t telepítettem, hogy kényelmesebben lássam az adatbázisokat.
- **SSH biztonságossá tétele**: **Timeout** beállítása, jelszó helyett **SSH key** használata, lehetőség szerint **root user tiltása** SSH-n.

---

## 🔮 További tanulási és megvalósítási célkitűzéseim

- **Python** programozási nyelv mélyebb megismerése.
- **Cloud computing.** Érdekel ez a terület, szeretném jobban megismerni (AWS, Azure).
- **Monitorozás továbbfejlesztése.** Grafana + Prometheus megtanulása. Zabbix ismeretet elmélyíteni.
- **Cloud storage** (Hetzner vagy pCloud).
- **Magas rendelkezésre állás.** Három darab 2,5"-os SSD és egy Lenovo M920q Tiny PC beszerzése van tervben, amelyre Proxmoxot telepítek, hogy a meglévő gépeimmel együtt háromtagú **klasztert** alakíthassak ki. A célom, hogy a három SSD-t **Ceph**-be integráljam.
- **DIY PiKVM.**  KVM over IP hasznos lenne. Venni szeretnék RPI 4-et, amin a PiKVM-et megvalósítanám.
- **IDS/IPS továbbfejlesztése.** CrowdSec elmélyítése, Nginx Proxy Managerre történő beállítása és Suricata implementálása.
- **Komolyabb switch vásárlása.** Ki szeretném próbálni a 802.1x port based autentikációt és beállítani a Radius felügyeletet a portokon. DHCP snooping és port security által még tovább növelhetném a biztonságot.

---

## 🖼️ Projekt képernyőképek








- Nginx Proxy Manager-ből egy részlet a proxy hosts-ról
<img src="https://github.com/user-attachments/assets/3a8d190b-52aa-4a94-be9f-9aec13829945" alt="Kép leírása" width="700"/>

- Pi-hole
<img src="https://github.com/user-attachments/assets/2d1971e8-aa55-4ebf-9fb2-3b0e95681515" alt="Kép leírása" width="700"/>

- Részlet a BIND9 db.otthoni.local zónafájljáról
<img src="https://github.com/user-attachments/assets/12686bdf-316a-4b5a-9f78-95d481fe005f" alt="Kép leírása" width="500"/>

---
**Köszönöm, hogy megnézted!**

