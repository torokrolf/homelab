# Virtualization

## VMs and LXCs Running on Proxmox
<img src="https://github.com/user-attachments/assets/e218f011-7896-4dbe-b5e2-0e13861d0909" alt="Kép leírása" width="500"/>

## 🖥️ Proxmox Ubuntu VM Template

Mivel a legtöbb VM-et Ubuntu-val használom Proxmoxon, készítettem egy **Ubuntu VM template-et**, hogy ne kelljen mindig új OS-t telepíteni, frissíteni, vagy SSH kulcsokat beállítani.  

**Elkészítés menete:**  
- Az alap VM-et konfiguráltam (frissítések, SSH kulcsok, hostname)  
- Ezután templatté alakítottam:  
  - SSH kulcsok törlése  
  - Hostname törlése  
  - DHCP engedélyezése  
- Feltelepítettem a **cloud-init**-et, hogy az OS személyre szabása gyors legyen  

**Használat:**  
- Új VM-et egyszerűen klónozok a templatról  
- Cloud-init segítségével beállítom a fontosabb konfigurációkat:  
  - Hostname  
  - SSH kulcsok  
  - Hálózat  
  - Domain és DNS szerver
