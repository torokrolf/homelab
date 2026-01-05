← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Automation

| Szolgáltatás / Eszköz | Leírás |
|---------------|-------------|
| Automation    | Ansible, Semaphore, Cron, Cronicle |

<img src="https://github.com/user-attachments/assets/d2541a25-8dd5-45f3-b828-d7ed8bf819ad" alt="Semaphore" width="700">

# Ansible + Semaphore Server

Ansible szerver célja: központi automatizáció és konfiguráció‑menedzsment a homelab kliensgépein.
Semaphore szerver célja: egyszerű grafikus felületen vezényelni az Ansible playbookokat.

---

## ⚙️ Megvalósított automatizálási feladatok

- **Update task**: Operációs rendszerek és alkalmazások frissítése a klienseken.  
- **Időzónák beállítása**:  Minden kliensgépen a helyes időzóna konfigurálva van.  
- **APT Cache NG kezelése**:  Lokális APT Cache NG-t nem egyesével állítottam be a kliensekhez, hanem Ansible-el.
- **User létrehozása és jelszó beállítása**: Azonos nevű felhasználót hoztam létre minden célgépen a **sima, egyszerű vezénylés** érdekében.  
- **SSH kulcsok megosztása**

---

← [Vissza a Homelab főoldalra](../README_HU.md)







