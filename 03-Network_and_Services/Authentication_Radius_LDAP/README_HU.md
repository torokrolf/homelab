# RADIUS & LDAP

## FreeIPA szerver (CentOS 9)
  - Felhasználók létrehozása és kezelése.
  - Sudo jogokkal rendelkező felhasználók konfigurálása.

## RADIUS & LDAP
  - **FreeRADIUS** segítségével a Pfsense GUI-ra történő belépés Radius hitelesítéssel is működik.
  - **Authentication fallback:** ha a RADIUS szerver leáll, a lokális felhasználóval is be lehet jelentkezni.
  - A lokális és RADIUS felhasználók neve/jelszava azonos, így a felhasználónak nem kell tudnia, melyik hitelesítésen keresztül lép be.
  - **SQL adatbázis + PhpMyAdmin:** a felhasználók és jogosultságok kezelése kényelmesen, grafikus felületen, fájlok helyett.
