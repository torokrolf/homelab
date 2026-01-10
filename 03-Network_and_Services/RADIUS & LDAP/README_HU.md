← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# RADIUS & LDAP

---

## FreeIPA szerver mint LDAP (CentOS 9)

- Egységes felhasználó- és jogosultságkezelés az infrastruktúrán belül.

---

### Megvalósított funkciók

- Felhasználók létrehozása és kezelése.
- Sudo jogokkal rendelkező felhasználók konfigurálása.

---

## FreeRADIUS szerver mint RADIUS – Pfsense GUI hitelesítés

---

### Megvalósított funkciók

- **Pfsense-re RADIUS beléptetéssel**: a Pfsense GUI-ra  bejelentkezés Radius hitelesítéssel.
- **Authentication fallback**: ha a RADIUS szerver leáll, a lokális felhasználóval is be lehet jelentkezni.
- **A lokális és RADIUS felhasználók neve/jelszava azonos**, így a felhasználónak nem kell tudnia, melyik hitelesítésen keresztül lép be.
- **SQL adatbázis + PhpMyAdmin**: a felhasználók és jogosultságok kényelmesen kezelhetők grafikus felületen, így nem kell fájlokban szerkeszteni vagy logolni, hanem közvetlenül az adatbázisból történik a kezelés.

---

← [Vissza a Homelab főoldalra](../README_HU.md)










