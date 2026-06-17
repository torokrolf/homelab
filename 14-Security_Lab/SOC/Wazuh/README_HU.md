← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Security Operations (SIEM & Detection)

A cél egy működő Security Operations Center (SOC) alapfolyamatainak gyakorlása: log-alapú behatolásészlelés, szabályírás, incidens kivizsgálás és automatizált védelmi reakció kiépítése **Wazuh** SIEM/XDR platformmal.

---

## 📚 Tartalomjegyzék

- [Architektúra & Telepítés](#archit)
- [Hogyan dolgozik fel egy logot a Wazuh? (Decoder → Rule)](#decoder)
- [Autentikációs események figyelése (SSH & sudo)](#auth)
- [Parancsvégrehajtás detektálása (auditd)](#auditd)
- [SSH Brute Force — Active Response demonstráció](#bruteforce)
- [Fájlintegritás-monitoring (FIM)](#fim)
- [Malware detektálás (FIM + VirusTotal)](#virustotal)
- [Sebezhetőség-kezelés (Vulnerability Detection)](#vuln)
- [Biztonsági megfelelőség-vizsgálat (CIS Benchmark)](#cis)
- [Log retenció](#logretention)
- [Jelenlegi állapot & további tervek](#tervek)

---

<a name="archit"></a>

## Architektúra & Telepítés

A **Wazuh manager** natív, szkriptalapú telepítéssel került fel egy dedikált Ubuntu VM-re (4.14-es verzió), agentek pedig minden monitorozni kívánt Linux és Windows gépre.

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash wazuh-install.sh -a
```

A telepítés sikerét a generált admin jelszó visszaigazolása jelzi, amit biztonságosan elmentettem. Agent oldalon a Wazuh dashboard generál egyedi telepítő parancsot gép- és platform-specifikusan (Linux esetén shell parancs, Windows esetén admin PowerShell), ami tartalmazza a manager IP-jét és az agent nevét.

> **Megjegyzés a telepítésről:** sikertelen/megszakadt telepítés esetén (jellemzően helyhiány miatt — minimum 10 GB szabad terület szükséges) a manager maradék fájljait manuálisan kell eltávolítani újratelepítés előtt (`dpkg` cache, `/var/ossec`, `wazuh-install-files`), különben a script hibára fut.

A manager és agent konfigurációs fájlja egységesen: `/var/ossec/etc/ossec.conf`

---

<a name="decoder"></a>

## Hogyan dolgozik fel egy logot a Wazuh? (Decoder → Rule)

A bejövő nyers logok önmagukban strukturálatlan szöveg. A Wazuh két lépésben alakítja ezeket kiértékelhető, riasztható eseményekké:

**1. Decoder** — kinyeri és standardizálja a mezőket, platformtól függetlenül (ugyanúgy néz ki egy Cisco switch logja és egy Ubuntu sshd logja a feldolgozás után).

**2. Rule** — a standardizált mezőket kiértékeli, és eldönti, hogy az esemény riasztást generáljon-e, és milyen szinten.

**Példa — nyers SSH log:**
```
Jun 15 14:00:00 server sshd[123]: Failed password for root from 192.168.1.50 port 22
```

**Decoder kimenete:**
| Mező | Érték |
|---|---|
| user | root |
| srcip | 192.168.1.50 |
| protocol | ssh |
| action | failed |

**Rule kiértékelés:** a `failed` action és a `root` user kombinációja a szabálykönyv szerint tiltott mintázat → riasztás generálódik.

### Rule hierarchia (öröklődés)

A beépített SSH szabályok jól mutatják a Wazuh rule-rendszerének hatékonyságát:

- **Rule 5700** (`level="0" noalert="1"`) — szülő/tároló szabály, csak csoportosít (`decoded_as: sshd`), önmagában nem riaszt.
- **Rule 5701** (`if_sid: 5700`, `level="8"`) — csak az 5700-on átment logokat nézi tovább, és ha az adott mintázatra illik (pl. `Bad protocol version identification`), felülírja a szülő szintjét és riaszt.

Ennek két előnye van: **hatékonyság** (a decoder-illesztést nem kell minden gyermek-szabálynak újra elvégeznie), és **modularitás** (új gyermek-szabály bármikor hozzáadható a meglévő szülőre hivatkozva, anélkül hogy az alapszűrést újra kellene definiálni).

- Beépített szabályok helye: `/var/ossec/ruleset/rules` — ezt **soha nem szerkesztem**, mert frissítéskor felülíródik.
- Egyedi szabályok helye: `/var/ossec/etc/rules/local_rules.xml` — ez az, amit én bővítek.
- A szabályok GUI-ból és CLI-ből is tesztelhetők (`Ruleset test`) mielőtt élesítem őket.

---

<a name="auth"></a>

## Autentikációs események figyelése (SSH & sudo)

A beépített szabálykészlet alapján a következő rule ID-kat azonosítottam és teszteltem valós bejelentkezési kísérletekkel:

**SSH (Linux):**

| Rule ID | Jelentés |
|---|---|
| 5710 | Nem létező felhasználónév (pl. vak `admin`/`root` próbálkozás) |
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

---

<a name="auditd"></a>

## Parancsvégrehajtás detektálása (auditd)

A syslog csak az alkalmazás-szintű naplókat látja (pl. mit ír az SSH daemon). Az **auditd** ezzel szemben kernel-szinten figyel, ezért olyan eseményeket is rögzít, amik egy alkalmazáslogban nem jelennének meg — elsősorban azt, hogy **milyen parancsokat futtat a root felhasználó**.

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

Egyedi audit szabály, amely minden root által indított process-execution eseményt logol (64 és 32 bites parancsokra is):

```
-a exit,always -F euid=0 -F arch=b64 -S execve -k audit-wazuh-c
-a exit,always -F euid=0 -F arch=b32 -S execve -k audit-wazuh-c
```

| Paraméter | Jelentés |
|---|---|
| `-a exit,always` | minden rendszerhívás végén írjon naplót |
| `-F euid=0` | csak a root (UID 0) által indított eseményeket figyelje |
| `-S execve` | a program/parancs-indítást jelző rendszerhívás |
| `-k audit-wazuh-c` | címke, amivel a Wazuh oldalon könnyen visszakereshető a forrás |

Betöltés: `sudo augenrules --load`

### Zajszűrés saját rule-lal

Az auditd minden root execve hívást naplóz, beleértve a háttérben automatikusan lefutó, nem releváns parancsokat is (`sed`, `df`, `systemctl`, stb.). Ezt két egymásra épülő saját szabállyal szűrtem:

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

**Fontos technikai részlet:** a `firewall-drop` script közvetlenül `iptables`-t használ, így a védelem akkor is működik, ha az `ufw` ki van kapcsolva — az `ufw` valójában csak egy wrapper az `iptables` köré.

---

<a name="fim"></a>

## Fájlintegritás-monitoring (FIM)

Az alapértelmezett FIM konfiguráció 12 óránként (`<frequency>43200</frequency>`) ellenőrzi a kijelölt könyvtárakat (`/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin`, `/boot`), ami nem valós idejű, de kíméli az erőforrásokat.

A `/root` könyvtárra — mint a rendszer legérzékenyebb pontja — valós idejű, teljes körű figyelést állítottam be:

```xml
<directories check_all="yes" report_changes="yes" realtime="yes">/root</directories>
```

| Paraméter | Hatás |
|---|---|
| `realtime="yes"` | azonnali észlelés, nem kell várni a következő scan-ciklusra |
| `report_changes="yes"` | nem csak azt jelzi, hogy változott valami, hanem azt is, *mi* változott |
| `check_all="yes"` | méret, jogosultság, tulajdonos és tartalom-hash egyaránt vizsgálva |

**Tesztelt és validált eseménytípusok:**

| Rule ID | Esemény |
|---|---|
| 554 | Fájl létrehozása |
| 550 | Fájl tartalmának módosítása (checksum változás) |
| 553 | Fájl törlése |

Minden esetet valós teszttel igazoltam: fájl létrehozása (`touch`), tartalom módosítása, jogosultság-változtatás és tulajdonos-váltás — minden alkalommal a dashboard pontosan megmutatta a régi és az új értéket (pl. `rw-r--r--` → módosított jogosultság, vagy `root` → `rolf` tulajdonosváltás).

---

<a name="virustotal"></a>

## Malware detektálás (FIM + VirusTotal)

A FIM-re épülő, automatizált malware-szűrési folyamat: ha egy figyelt könyvtárban (jelen esetben `/root`) új fájl jelenik meg vagy módosul, a Wazuh kiszámolja a fájl hash-ét, és a **VirusTotal API**-n keresztül lekérdezi, hogy a hash ismert kártékony fájlhoz tartozik-e.

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

<a name="cis"></a>

## Biztonsági megfelelőség-vizsgálat (CIS Benchmark)

A **Configuration Assessment** modul a CIS (Center for Internet Security) iparági szabvány alapján auditálja a rendszerkonfigurációt. Egy Windows 11 Enterprise kliensen futtatott vizsgálat a **CIS Microsoft Windows 11 Enterprise Benchmark v3.0.0** ellen 23%-os megfelelést mutatott (113 ellenőrzés sikeres, 360 sikertelen), részletes bontással arról, mely beállítások térnek el az ajánlott biztonsági konfigurációtól.

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

<a name="tervek"></a>

## Jelenlegi állapot & további tervek

- [x] Wazuh manager natív telepítése, agentek Linux és Windows kliensekre
- [x] Decoder/Rule logika és hierarchia megértése, gyakorlati tesztelés
- [x] SSH és sudo autentikációs események azonosítása valós teszttel
- [x] Auditd integráció root parancsvégrehajtás figyelésére, egyedi zajszűrő szabállyal
- [x] SSH brute force end-to-end demonstráció (támadás → detekció → Active Response → automatikus feloldás)
- [x] Fájlintegritás-monitoring valós idejű figyeléssel és validált eseménytípusokkal
- [x] Malware detektálás FIM + VirusTotal API integrációval, EICAR teszttel validálva
- [x] Vulnerability Detection valós CVE-vel demonstrálva
- [x] CIS Benchmark alapú Configuration Assessment
- [ ] Suricata (IDS/IPS) integrálása a pfSense-en, alertek továbbítása Wazuh-ba
- [ ] Nessus Essentials alapú sebezhetőség-szkennelés, before/after összevetéssel
- [ ] Wazuh + Suricata közös incidens-korreláció (SOC use case)
- [ ] Egyedi incidens-riport sablon kialakítása valós eseményekhez

---

← [Vissza a Homelab főoldalra](../README_HU.md)


