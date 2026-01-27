← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. 📚 Automation

---

## 1.1 Tartalomjegyzék

- [Ansible_Semaphore](./Ansible_Semaphore/README_HU.md)
- [Cron_Cronicle](./Cron_Cronicle/README_HU.md)

---

## 1.2 Szolgáltatások

| Szolgáltatás / Eszköz | Funkció / Leírás |
|-----------------------|-----------------|
| **Ansible**           | Központi konfiguráció‑menedzsment és automatizáció VM-ek és LXC-k kezelésére |
| **Semaphore**         | Webes felület az Ansible playbookok vezénylésére, egyszerű és áttekinthető menedzsment |
| **Cron**              | Időzített feladatok futtatása Linux rendszereken |
| **Cronicle**          | A Cron webes felülete |


---

## 1.3 Ansible + Semaphore Server

Ansible szerver célja: központi automatizáció és konfiguráció‑menedzsment a homelab kliensgépein.
Semaphore szerver célja: egyszerű grafikus felületen vezényelni az Ansible playbookokat.

**Lenti képen látható a Semaphore.**

<img src="https://github.com/user-attachments/assets/d2541a25-8dd5-45f3-b828-d7ed8bf819ad" alt="Semaphore" width="900">

---

### 1.3.1 Megvalósított automatizálási feladatok

- **Update task**: Operációs rendszerek és alkalmazások frissítése a Proxmox VM/LXC klienseken.  
- **Időzónák beállítása**:  Minden kliensgépen a helyes időzóna konfigurálva van.  
- **APT Cache NG kezelése**:  Lokális APT Cache NG-t nem egyesével állítottam be a kliensekhez, hanem Ansible-el.
- **User létrehozása és jelszó beállítása**: Azonos nevű felhasználót hoztam létre minden célgépen a **sima, egyszerű vezénylés** érdekében.  
- **SSH kulcsok megosztása**

---

← [Vissza a Homelab főoldalra](../README_HU.md)

















