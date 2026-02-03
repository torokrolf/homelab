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

## VPN használat a homelabhoz

- **OpenVPN** és **WireGuard** VPN szervereket használok, de kipróbáltam a **Tailscale**-t is.
- Telefonról így egyszerűen elérem a homelabomat és a rajta futó szolgáltatásokat.
- A **full tunnel** mód beállításával a telefon a **AdGuard Home forwarder DNS-t** használja reklámblokkolásra.
- Jellyfin szerverem nyilvánosan elérhető internet felől, hogy egyszerűen hozzáférhessek bárhonnan.
- Minden más szolgáltatás VPN-en keresztül fut, így ezek biztonságban vannak az interneten.

---

← [Vissza a Homelab főoldalra](../README_HU.md)


