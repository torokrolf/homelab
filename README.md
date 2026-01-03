# 🏡 Homelabom rövid összefoglalója 

## 🏠 Homelab projekt ismertetése

Ez a projekt egy saját tervezésű, vállalati környezet szerű homelabot mutat be, ahol Linux és Windows rendszereken gyakorlok virtualizációt, hálózatbiztonságot és üzemeltetést. Windows és Linux megoldásokat egyaránt tartalmaz. A konkrét megvalósításhoz és a mögöttes elmélet elsajátításához Udemy-n vásárolt videók, YouTube videók, cikkek és fórumok sokat segítettek, mindez angol nyelven. Elkezdtem használni a ChatGPT-t is, amit hasznosnak találtam, az információgyűjtést és keresést drasztikusan felgyorsítja.

❗❗❗Részletes dokumentációt készítettem magamnak az installálási folyamatokról, konfigurációs fájlokról, mit és hogyan állítottam be, felmerülő problémákról és megoldásaikról, képekkel illusztrálva, de ezek itt nem kerültek publikálásra. 

> 🎯 **Célom**:
Az elméleti tudásom mellett gyakorlati tapasztalat szerzése, új technológiák kipróbálása és megismerése. A technológiák kiválasztásakor figyelembe vettem a jelenlegi munkaerőpiaci trendeket, amit olykor a célra rendelkezésemre álló büdzsé befolyásolt.
Emellett fontos szempont volt, hogy az álláspályázatok során a munkáltatók könnyebben megismerhessék a tudásomat,  és könnyebben eldönthessék, hogy én vagyok-e a keresett személy.

---

## 🔍 Felhasznált technológiák részletes ismertetése







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
**Köszönöm, hogy megnézted!**

