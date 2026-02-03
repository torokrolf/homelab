← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Network and services

---

## 1.1 Hálózat és Szolgáltatások

| Szolgáltatás / Terület | Eszközök / Szoftverek |
|------------------------|----------------------|
| **Tűzfal / Router**     | pfSense |
| **VLAN**               | TP-LINK SG108E switch |
| **DHCP**               | ISC-KEA, Windows Server 2019 DHCP szerver |
| **DNS**                | BIND9 + Namecheap + Cloudflare, Windows Server 2019 DNS szerver |
| **VPN**                | Tailscale, WireGuard, OpenVPN, NordVPN |
| **Reverse Proxy**      | Nginx Proxy Manager (lecseréltem), Traefik (használom jelenleg) |
| **Reklámszűrés**       | Pi-hole |
| **PXE Boot**           | iVentoy |
| **Radius / LDAP**      | FreeRADIUS, FreeIPA |
| **Hálózati hibakeresés** | Wireshark |
| **APT cache proxy** | APT-Cache-NG        |

---

## 1.2 VPN használat a homelabhoz

- **OpenVPN** és **WireGuard** VPN szervereket használok, de kipróbáltam a **Tailscale**-t és a **NordVPN Meshnet** rendszerét is.
- A nyilvánosan elérhető szolgáltatások internet felől közvetlenül elérhetők, hogy ne legyen szükség VPN kliens beállítására a használatukhoz.
- A belső, privát szolgáltatások kizárólag VPN-en keresztül érhetők el, így csak a megfelelő jogosultsággal rendelkező felhasználók férhetnek hozzájuk.
- A **full tunnel** mód beállításával a telefon a **AdGuard Home forwarder DNS-t** használja reklámblokkolásra.

---

← [Vissza a Homelab főoldalra](../README_HU.md)




