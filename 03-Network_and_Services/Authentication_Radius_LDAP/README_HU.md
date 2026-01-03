# RADIUS & LDAP

## FreeIPA szerver mint LDAP (CentOS 9)

-### Megvalósított funkciók
- Felhasználók létrehozása és kezelése.
- Sudo jogokkal rendelkező felhasználók konfigurálása.
- Egységes felhasználó- és jogosultságkezelés az infrastruktúrán belül.

## FreeRADIUS szerver mint RADIUS – Pfsense GUI hitelesítés
- RADIUS beléptetés: a Pfsense GUI-ra történő bejelentkezés Radius hitelesítéssel.
- Authentication fallback: ha a RADIUS szerver leáll, a lokális felhasználóval is be lehet jelentkezni.
- A lokális és RADIUS felhasználók neve/jelszava azonos, így a felhasználónak nem kell tudnia, melyik hitelesítésen keresztül lép be.

- SQL adatbázis + PhpMyAdmin: a felhasználók és jogosultságok kezelése kényelmesen, grafikus felületen, fájlok helyett.

# Megvalósított funkciók
> Az automatizáció jelenleg az alap rendszerkarbantartási és konfigurációs feladatokra fókuszál; további playbookok és workflow-k későbbi bővítése tervben van.

  - Használat CLI-ből és Semaphore Web UI-n keresztül.
  - VM-ek és LXC-k frissítésének automatizálása playbookokkal.
  - Közös felhasználók létrehozása több gépen.
  - SSH kulcsok egységes kezelése és kiosztása.
  - Közös konfigurációs fájlok kezelése (pl. NTP szerver beállítása).
  - Időzóna egységes beállítása az infrastruktúrán belül.






