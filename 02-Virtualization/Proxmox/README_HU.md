← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Proxmox

---

## VMs and LXCs Running on Proxmox
<img src="https://github.com/user-attachments/assets/e218f011-7896-4dbe-b5e2-0e13861d0909" alt="Kép leírása" width="500"/>

---
## VM / LXC elnevezési konvenció

A Proxmox környezetben futó összes virtuális gép és LXC konténer egységes elnevezési szabályt követ a könnyebb azonosíthatóság érdekében.

**LXC formátum:**
<szolgáltatás-neve>-<ip-utolsó-oktett>

- **Például:** unbound-223, traefik-224

**VM formátum:**
<OS-neve>-<ip-utolsó-oktett>

- **Például:** winszerver-234, win11kliens-231

---

## VM Template + Cloud-init használata

**LXC-re használható template, de Cloud-init nem!**

Mivel a legtöbb VM-et Ubuntu-val használom Proxmoxon, készítettem egy **Ubuntu VM template-et**, hogy ne kelljen mindig új OS-t telepíteni, frissíteni, vagy SSH kulcsokat beállítani.  

**Elkészítés menete:**  
- Az alap VM-et konfiguráltam (frissítések, cloud-init telepítése)  
- Felkészítettem a VM-et a template-té alakításra:  
  - SSH kulcsokat törlöm  
  - Hostname-et törlöm  
  - DHCP-t engedélyezem  
- Template-té alakítom

**Használat:**  
- Új VM-et egyszerűen klónozok a template-ből  
- Cloud-init segítségével beállítom a fontosabb konfigurációkat:  
  - Hostname  
  - SSH kulcsok  
  - Hálózat  
  - Domain és DNS szerver

---

## Proxmox 8 → 9 és PBS 3 → 4 Frissítés

Már néhány hónapja használom a rendszert, és amikor megjelent a Proxmox 9 és a PBS 4, kíváncsi voltam, hogy sikerül-e egy már beállított rendszert problémamentesen frissíteni.

- Proxmox **8 → 9** frissítés megtörtént.  
  - Egyik Proxmox hoston **upgrade** segítségével frissítettem.
  - Másik Proxmox hoston **újratelepítés** segítségével telepítettem a Proxmox VE 9-et, majd a VM-eket visszaállítottam **PBS mentésekből**.

- Proxmox Backup Server (**PBS**) is frissítve: **3 → 4**.

---

← [Vissza a Homelab főoldalra](../README_HU.md)





