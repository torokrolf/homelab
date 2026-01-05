← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Operációs rendszerek összefoglaló

| Platform | Típus    | Verziók |
|----------|---------|---------|
| Linux    | Szerver | CentOS 9 Stream, Ubuntu 22.04 Server |
| Linux    | Kliensek| Ubuntu 22.04 Desktop |
| Windows  | Szerver | Windows Server 2019 |
| Windows  | Kliensek| Windows 10, Windows 11 |

---

## Linux szervereken használt szolgáltatások (LXC)
- Bind9
- Nginx
- Ansible + Semaphore
- Zabbix server
- Pi-hole
- FreeIPA
- FreeRADIUS
- APT-Cacher NG
- Vaultwarden
- Restic
- Open WebUI + OpenAI API
- Truenas
- Wireguard
- OpenVPN
- chronyd (NTP)

---

## Linux szervereken használt szolgáltatások (VM)
- iVentoy

---

## Windows szervereken használt szolgáltatások és implementációk

- 2 gépen Windows Server 2019
- Active Directory  
- Felhasználók létrehozása  
- Group Policy-k létrehozása  
- DHCP szerver – mindkét szerveren, load balancing beállítással  
- DNS szerver – mindkét szerveren, secondary zone konfigurációval, arra az esetre ha az egyik szerver kiesne  
- DNS forwarders: 192.168.3.1 (pfSense), amit nem tud feloldani a DNS szerver, azt ide továbbítja
- Forward zone: trkrolf.com → *.trkrolf.com a 192.168.2.202 Nginx proxy-ra mutat  
- Conditional forwarder: otthoni.local → 192.168.2.201 Bind9 DNS szerverre irányítva, csak Windows Server 1-en, hogy tudja oldani az otthoni.local-t  
- Veeam Backup & Replication – csak Windows-t használó laptop mentésére  
- Macrium Reflect – Windows+Linux dual boot laptopokhoz  
- OpenVPN client  
- Wireguard client  

---

← [Vissza a Homelab főoldalra](../README_HU.md)

