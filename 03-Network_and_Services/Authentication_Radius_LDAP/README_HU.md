# RADIUS & LDAP

## FreeIPA szerver mint LDAP (CentOS 9)

- Egységes felhasználó- és jogosultságkezelés az infrastruktúrán belül.

### Megvalósított funkciók

- Felhasználók létrehozása és kezelése.
- Sudo jogokkal rendelkező felhasználók konfigurálása.

## FreeRADIUS szerver mint RADIUS – Pfsense GUI hitelesítés

### Megvalósított funkciók

- RADIUS beléptetés: a Pfsense GUI-ra történő bejelentkezés Radius hitelesítéssel.
- Authentication fallback: ha a RADIUS szerver leáll, a lokális felhasználóval is be lehet jelentkezni.
- A lokális és RADIUS felhasználók neve/jelszava azonos, így a felhasználónak nem kell tudnia, melyik hitelesítésen keresztül lép be.
- SQL adatbázis + PhpMyAdmin: a felhasználók és jogosultságok kezelése kényelmesen, grafikus felületen, hogy ne fájlokba kelljen szerkeszteni és logolni, hanem adatbázisba.











