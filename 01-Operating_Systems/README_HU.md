# Operációs Rendszerek

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

Active Directory – mindkét Windows Server 2019 Desktop Experience-en, közös domainben  
Felhasználók létrehozása  
Group Policy-k létrehozása  
DHCP szerver – mindkét szerveren, load balancing beállítással  
DNS szerver – mindkét szerveren, secondary zone konfigurációval  
DNS forwarders: 192.168.3.1 (pfSense)  
Forward zone: trkrolf.com → *.trkrolf.com a 192.168.2.202 Nginx proxy-ra mutat  
Conditional forwarder: otthoni.local → 192.168.2.201 (Bind9), csak Windows Server 1-en  
Veeam Backup & Replication – csak Windows-t használó laptop mentésére  
Macrium Reflect – Windows+Linux dual boot laptopokhoz  
OpenVPN client  
Wireguard client  

---

### Megjegyzés a Windows szerver felépítésről

A két Windows Server 2019 egy magas rendelkezésre állású domain és DHCP setup része,  
minden szolgáltatás (AD, DNS, DHCP) tükrözve van mindkét szerveren, kivéve a conditional forwarder, ami lokális specializációt biztosít.  
Ez a felállás professzionális, redundáns és skálázható otthoni/teszt környezethez.
