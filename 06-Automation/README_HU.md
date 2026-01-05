← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Automation

| Service / Tool | Description |
|---------------|-------------|
| Automation    | Ansible, Semaphore, Cron, Cronicle |


# Ansible + Semaphore Server

A szerver célja: **központi automatizáció és konfiguráció‑menedzsment** a homelab kliensgépein.

---

## 👤 Felhasználók kezelése

- **User létrehozása és jelszó beállítása**:  
  Azonos nevű felhasználót hoztam létre minden célgépen a **sima, egyszerű vezénylés** érdekében.  
- **SSH kulcsok kezelése**:  
  A felhasználóknak kiosztott SSH kulcsok segítségével **passwordless hozzáférést** biztosítok az Ansible szerverről.

---

## ⚙️ Automatizált feladatok

- **Update task**:  
  - Operációs rendszerek és alkalmazások frissítése a klienseken.  
- **Időzónák beállítása**:  
  - Minden kliensgépen a helyes időzóna konfigurálva van.  
- **APT Cache NG kezelése**:  
  - Lokális apt cache a gyorsabb frissítésekért és sávszélesség megtakarításért.

---

## 🛠️ Előnyök

- Központi vezénylés **egyszerű felhasználói modellel**  
- Biztonságos, kulcs alapú SSH hozzáférés  
- Időzónák és frissítések **automatizált menedzsmentje**  
- Sávszélesség-takarékos **APT cache használat**  

---

← [Vissza a Homelab főoldalra](../README_HU.md)


