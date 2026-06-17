← [Vissza a Homelab főoldalra](../../../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Security Operations (SIEM & Detection)

---

## 📚 Tartalomjegyzék

- [Architektúra & Telepítés](#archit)
- [Autentikációs események figyelése (SSH & sudo)](#auth)
- [Parancsvégrehajtás detektálása (auditd)](#auditd)
- [SSH Brute Force — Active Response demonstráció](#bruteforce)
- [Fájlintegritás-monitoring (FIM)](#fim)
- [Malware detektálás (FIM + VirusTotal)](#virustotal)
- [Sebezhetőség-kezelés (Vulnerability Detection)](#vuln)
- [Log retenció](#logretention)

---

<a name="archit"></a>

## Architektúra & Telepítés

A **Wazuh manager** natív, szkriptalapú telepítéssel került fel egy dedikált Ubuntu VM-re, agentek pedig minden monitorozni kívánt Linux és Windows gépre.

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash wazuh-install.sh -a
```

A telepítés után a generált admin jelszóvalé tudok belépni a webes felületre. Agent oldalon a Wazuh dashboard generál egyedi telepítő parancsot gép- és platform-specifikusan.

<img width="945" height="413" alt="kép" src="https://github.com/user-attachments/assets/d6d00d4e-ce43-4886-b610-c8340428fa3d" />

---

<a name="auth"></a>

## Autentikációs események figyelése (SSH & sudo)

A beépített szabálykészlet alapján a következő rule ID-kat azonosítottam és teszteltem valós bejelentkezési kísérletekkel:

**SSH (Linux):**

| Rule ID | Jelentés |
|---|---|
| 5710 | Nem létező felhasználónév |
| 5760 | Létező felhasználónév, hibás jelszó |
| 5715 | Sikeres SSH belépés — élesben mindig figyelendő |

**Sudo (Linux):**

| Rule ID | Jelentés |
|---|---|
| 5401 | Hibás sudo jelszó (1–2. próbálkozás) |
| 5404 | Hibás sudo jelszó 3. alkalommal — kizárás |
| 5403 | Adott felhasználó életében első sikeres sudo használata |
| 5402 | Normál, megszokott sikeres sudo használat |

Mindegyik eseményt valós teszttel validáltam (létező/nem létező felhasználónévvel SSH-zás, helyes és helytelen sudo jelszó megadása, 3x egymás után hibás jelszó), és a dashboardon ellenőriztem, hogy a megfelelő rule ID-val jelenik-e meg.

Nem létező userrel belépési kísérlet ssh-n. Wazuh eseményeknél ezt kaptam. 
<img width="612" height="53" alt="kép" src="https://github.com/user-attachments/assets/9a2115b5-c2ac-475e-baeb-d66226d951fa" />

Létező userrel ssh bejelentkezésnél ezt kaptam Wazuh eseményeknél.
<img width="623" height="59" alt="kép" src="https://github.com/user-attachments/assets/518ed23d-d3d0-4d08-8ff9-180eeaed195b" />

Létező userrel, de rossz jelszóval ssh belépésnél ezt az eseményt generálta.
<img width="629" height="54" alt="kép" src="https://github.com/user-attachments/assets/ccc8b52d-ecd4-47fc-9ee9-fe06e9530574" />

Rendszer életében első sikeres root-ba lépésnél ezt írja.
<img width="945" height="58" alt="kép" src="https://github.com/user-attachments/assets/17b3ecb1-006e-44bf-a11b-6b018e9966e7" />

További sikeres root-ba lépésnél már ezt fogom látni.
<img width="945" height="52" alt="kép" src="https://github.com/user-attachments/assets/61162a41-351b-4b2b-9d3c-de1aee91f71c" />

Egy vagy két sikertelen jelszónál ezt az eseményt generálja.
<img width="945" height="51" alt="kép" src="https://github.com/user-attachments/assets/995ef402-6ac5-48c7-8a22-b7cb173e74a4" />

Három sikertelen jelszónál az alábbi eseményt kapom.
<img width="945" height="50" alt="kép" src="https://github.com/user-attachments/assets/dcfd5217-6236-4e2c-bb22-a071ba758e62" />

---

<a name="auditd"></a>

## Parancsvégrehajtás detektálása (auditd)

A syslog csak az alkalmazás-szintű naplókat látja (pl. mit ír az SSH daemon). Az **auditd** ezzel szemben kernel-szinten figyel, ezért olyan eseményeket is rögzít, amik egy alkalmazáslogban nem jelennének meg — elsősorban azt, hogy **milyen parancsokat futtat a root felhasználó**.

Feltelepítem az auditd-t a monitorozott gépre.

```bash
apt install auditd -y
```

Az agent konfigjához hozzáadva a log forrást:

```xml
<localfile>
    <log_format>audit</log_format>
    <location>/var/log/audit/audit.log</location>
</localfile>
```

Egyedi audit szabály a kliensen, amely minden root által indított process-execution eseményt logol (64 és 32 bites parancsokra egyaránt):

```
-a exit,always -F euid=0 -F arch=b64 -S execve -k audit-wazuh-c
-a exit,always -F euid=0 -F arch=b32 -S execve -k audit-wazuh-c
```

Betöltés: `sudo augenrules --load`

### Zajszűrés saját rule-lal

Az auditd minden root execve hívást naplóz, beleértve a háttérben automatikusan lefutó, nem releváns parancsokat is (`sed`, `df`, `systemctl`, stb.).
A képen is látható hogy noha kliensen csak netstat parancsot futtattam, mégis rengeteg más parancsot is megjelenít.
<img width="1207" height="587" alt="kép" src="https://github.com/user-attachments/assets/fec136e8-5a71-4986-aac8-40fb40dfb131" />

Ezt két egymásra épülő saját szabállyal szűrtem szerveren:

```xml
<rule id="100005" level="7">
    <if_sid>80700</if_sid>
    <field name="audit.key">audit-wazuh-c</field>
    <description>Audit: Kiemelt Root parancs futtatva: $(audit.exe)</description>
    <group>audit_command</group>
</rule>

<rule id="100006" level="0">
    <if_sid>100005</if_sid>
    <field name="audit.exe">/usr/bin/sed|/usr/bin/dash|/usr/bin/sort|/usr/bin/last|/usr/bin/df|/usr/bin/systemctl|/usr/bin/sleep|/usr/bin/date|/usr/bin/mountpoint|/usr/bin/ping</field>
    <description>Audit: Zaj eldobva.</description>
</rule>
```

A `100005` minden kiemelt root parancsot 7-es szinten riaszt, a `100006` pedig — ami a `100005`-ön örökölve fut — a whitelistben szereplő, ártalmatlan parancsokat 0 szintre állítja, így azok nem jelennek meg riasztásként a dashboardon, de a naplóból visszakereshetők maradnak.

Most már ha netstat-ot futtatom kliensen, akkor nem ugrik fel sok más hozzátartozó parancs, csak a netstat.
<img width="1203" height="91" alt="kép" src="https://github.com/user-attachments/assets/5c4ab93c-41e0-4c70-89d2-1612f5ec7e4f" />

---

<a name="bruteforce"></a>

## SSH Brute Force — Active Response demonstráció

Ez a teszt a teljes detekciós láncot mutatja be, a támadás szimulálásától az automatikus tűzfal-blokkig.

**1. Active Response konfigurálása a manageren** — az 5763-as (SSH brute force) szabály kiváltásakor a megadott agentre `firewall-drop` parancsot futtat, 180 másodperces blokkal:

```xml
<active-response>
    <command>firewall-drop</command>
    <location>defined-agent</location>
    <agent_id>005</agent_id>
    <rules_id>5763</rules_id>
    <timeout>180</timeout>
</active-response>
```

**2. Támadás szimulálása** egy Kali Linux VM-ről, Hydra-val a célgép SSH portja ellen:

```bash
sudo gunzip /usr/share/wordlists/rockyou.txt.gz
hydra -t 4 -l root -P /usr/share/wordlists/rockyou.txt 192.168.2.200 ssh
```

**3. Detekció:** a beépített logika 120 másodpercen belüli 8 sikertelen bejelentkezést azonosít be brute force-ként (rule 5763, level 10). A riasztás után 60 másodperces "ignore" időszak akadályozza meg, hogy minden további próbálkozás újra-riasszon.

**4. Automatikus válasz:** a riasztás triggereli az Active Response-t, amely a célgép tűzfalán (iptables) blokkolja a támadó IP-jét. A teszt ideje alatt a támadó gépről sem ping, sem SSH nem volt elérhető a célpont felé.

```bash
sudo iptables -L INPUT -v -n --line-numbers
```

**5. Automatikus feloldás:** a beállított 180 másodperces timeout lejártával a Wazuh önműködően eltávolítja a tűzfalszabályt.

---

<a name="fim"></a>

## Fájlintegritás-monitoring (FIM)

Az alapértelmezett FIM konfiguráció 12 óránként (`<frequency>43200</frequency>`) ellenőrzi a kijelölt könyvtárakat (`/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin`, `/boot`), ami nem valós idejű, de kíméli az erőforrásokat.

A `/root` könyvtárra valós idejű, teljes körű figyelést állítottam be a kliensen:

```xml
<directories check_all="yes" report_changes="yes" realtime="yes">/root</directories>
```

**Tesztelt és validált eseménytípusok:**

| Rule ID | Esemény |
|---|---|
| 554 | Fájl létrehozása |
| 550 | Fájl tartalmának módosítása (checksum változás) |
| 553 | Fájl törlése |

Minden esetet valós teszttel igazoltam: fájl létrehozása a figyelt könyvtárban, tartalom módosítása, jogosultság-változtatás és tulajdonos-váltás — minden alkalommal a dashboard pontosan megmutatta a régi és az új értéket, ami változott.

---

<a name="virustotal"></a>

## Malware detektálás (FIM + VirusTotal)

A fájl integritás monitorozásra épülő, automatizált malware-szűrési folyamat: ha egy figyelt könyvtárban (jelen esetben `/root`) új fájl jelenik meg vagy módosul, a Wazuh kiszámolja a fájl hash-ét, és a **VirusTotal API**-n keresztül lekérdezi, hogy a hash ismert kártékony fájlhoz tartozik-e.

**1. Célzott szabályok** a `/root`-ban történő FIM eseményekre (öröklődve az 550/554 alap szabályokból):

```xml
<rule id="100200" level="7">
    <if_sid>550</if_sid>
    <field name="file">/root</field>
    <description>File modified in /root directory.</description>
</rule>

<rule id="100201" level="7">
    <if_sid>554</if_sid>
    <field name="file">/root</field>
    <description>File added to /root directory.</description>
</rule>
```

**2. VirusTotal integráció** a manager konfigjában, a fenti két szabály ID-jára kötve:

```xml
<integration>
    <name>virustotal</name>
    <api_key>***</api_key>
    <rule_id>100200,100201</rule_id>
    <alert_format>json</alert_format>
</integration>
```

**3. Validáció valós teszt-malware-rel:** az EICAR teszt fájl (iparági szabvány, ártalmatlan, de minden antivírus malware-ként ismeri fel) letöltése a figyelt könyvtárba:

```bash
curl -Lo eicar.com https://secure.eicar.org/eicar.com
```

A Wazuh detektálta az új fájlt, lekérdezte a VirusTotal API-n, és riasztást generált arra, hogy a fájl ismert kártékony kód.

---

<a name="vuln"></a>

## Sebezhetőség-kezelés (Vulnerability Detection)

A Wazuh beépített Vulnerability Detection modulja az agenteken telepített szoftverleltárt összeveti ismert CVE adatbázisokkal, és valós időben jelzi az érintett komponenseket.

**Valós eset:** egy kritikus Google Chrome sebezhetőség (CVSS **9.6**) detektálása, amely a 149.0.7827.103-as verzióig érintett minden telepítést. A részletes CVSS bontás:

| Metrika | Érték | Jelentés |
|---|---|---|
| Attack Complexity | Low | nem igényel speciális hozzáférést vagy tudást |
| Attack Vector | Network | távolról, internet felől kihasználható |
| Confidentiality Impact | High | bizalmas adatokhoz (jelszavak, böngészési előzmények) való hozzáférés |
| Integrity Impact | High | rendszer- vagy böngészőfájlok módosíthatók |
| Availability Impact | High | a rendszer/böngésző lefagyasztható, összeomlasztható |

A saját rendszerem az érintett verziótartományba esett (149.0.7827.102), a Chrome frissítése után a sebezhetőség automatikusan lekerült a Wazuh dashboardról.

---

<a name="logretention"></a>

## Log retenció

A Wazuh saját szolgáltatás-logjai (`ossec.log`, `api.log`, `cluster.log`, `active-responses.log`) logrotate-tel kerülnek kezelésre:

```
{
    daily
    rotate 30
    missingok
    notifempty
    compress
    delaycompress
    maxsize 100M
    dateext
    dateformat -%Y%m%d
    copytruncate
}
```

Napi rotáció, 30 napos megőrzés, 100 MB méretkorlát naponta — ha egy nap alatt ez túllépésre kerül, a rendszer azon a napon több fájlt képez, ami arányosan csökkenti a tényleges megőrzési időt (pl. napi 150 MB mellett napi 2 fájl képződik, így a 30 fájl ~15 napot fed le).

Az alert/archive logok (`*.gz`) 30 napnál régebbi tételeinek takarítását egy cron job végzi:

```bash
0 0 * * * find /var/ossec/logs/alerts/ -name "*.gz" -type f -mtime +30 -exec rm -f {} \;
0 0 * * * find /var/ossec/logs/archives/ -name "*.gz" -type f -mtime +30 -exec rm -f {} \;
```

---

← [Vissza a Homelab főoldalra](../../../README_HU.md)


