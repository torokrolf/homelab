← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 📚 Tartalomjegyzék

- [00. Homelab hardver](./00-Homelab_Hardware/README_HU.md)
- [01. Operációs rendszerek](./01-Operating_Systems/README_HU.md)
- [02. Virtualizáció](./02-Virtualization/README_HU.md)
- [03. Hálózat és szolgáltatások](./03-Network_and_Services/README_HU.md)
- [04. Távoli elérés](./04-Remote_Access/README_HU.md)
- [05. Monitorozás](./05-Monitoring/README_HU.md)
- [06. Automatizáció](./06-Automation/README_HU.md)
- [07. Mentés és helyreállítás](./07-Backup_and_Recovery/README_HU.md)
- [08. Dashboard](./08-Dashboard/README_HU.md)
- [09. Jelszókezelés](./09-Password_Management/README_HU.md)
- [10. Tárolás](./10-Storage/README_HU.md)
- [11. Scriptek](./11-Scripts/README.md)
- [12. Tervezési döntések](./12-Design_Decisions/README_HU.md)
- [13. Hibák és hibaelhárítás](./13-Errors/README_HU.md)

---

# Megvalósított mentési megoldások
 
- **Proxmox host mentés**
  - A Proxmox rendszer blokkszintű mentése **Clonezilla** segítségével.
  - Automatizálás **preseed** konfigurációval.
- **Virtuális környezet mentése**
  - VM-ek és LXC-k mentése egy virtualizált **Proxmox Backup Serverre**.
- **Kliens oldali mentések**
  - Windows laptopom mentése **Veeam Backup & Replication Community Edition** használatával SMB megosztásba.
  - **Személyes fájlok mentése és szinkronizációja**
  - **Nextcloud**: self-hosted fájlmegosztás laptop és telefon között.
  - **Telefon**: fényképek egyirányú szinkronizálása homelabra **FolderSync** segítségével.
  - **Laptop**: fájlok szinkronizálása homelabra **FreeFileSync** használatával, amit később **Restic**-re cseréltem.

---

← [Vissza a Homelab főoldalra](../README_HU.md)










