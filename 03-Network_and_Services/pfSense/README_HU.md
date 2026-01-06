← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# pfSense

Homelabomban egy **pfSense alapú tűzfalat és routert** használok.  


# 📚 Tartalomjegyzék – pfSense

- [NAT és Routing](#nat-es-routing)
- [Core Network Services](#core-network-services)
  - [DHCP szerver](#dhcp-szerver)
  - [NTP szerver](#ntp-szerver)
- [VPN megoldások](#vpn-megoldasok)
  - [WireGuard VPN](#wireguard-vpn)
  - [OpenVPN](#openvpn)
- [Dynamic DNS (DDNS)](#dynamic-dns-ddns)

---

## NAT & Routing
- **Outbound NAT** konfigurálása belső hálózat számára
- **Port Forward NAT** külső szolgáltatások publikálásához
- Belső erőforrások védelme NAT-on keresztül
- Routing logika és forgalomirányítás megértése

---

## DHCP szerver konfigurálása és üzemeltetése

  - IP tartományok kezelése
  - Statikus DHCP lease-ek
  - Gateway és DNS kiosztás

---

## NTP szerver futtatása
  - Időszinkron biztosítása belső klienseknek 

---

## VPN megoldások
- **WireGuard VPN**
  - Modern, gyors VPN megoldás
  - Távoli hozzáférés biztosítása belső hálózathoz
- **OpenVPN**
  - Tanúsítvány-alapú hitelesítés
  - Kompatibilitás különböző kliensekkel
- VPN-en keresztüli routing és tűzfalszabályok kialakítása

---

## Dynamic DNS (DDNS)
- **DDNS kliens konfigurálása**
- Dinamikus publikus IP-cím kezelése
- Külső elérés stabil biztosítása (VPN, szolgáltatások)

---



← [Vissza a Homelab főoldalra](../README_HU.md)





