← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Távoli Elérés

## 1.1 Távoli elérés áttekintés

| Szolgáltatás / Terület                 | Eszközök / Szoftverek                                     
|----------------------------------------|----------------------------------------------------------
| [1.2 RDP](#rdp)        | Guacamole                                                              
| [1.3 SSH](#ssh)            | Termius, Teleport                                             
| [1.4 VPN](#vpn)                      | Wireguard, OpenVPN                                   
| [1.5 Zero Trust Remote Access](#zerotrust)     | Cloudflare tunnel                                        

---
<a name="rdp"></a>

## 1.2 RDP 

- **Miért Guacamole:**
  - Böngészőből kényelmesen elérhető több gép  
  - Jobb, mint a Proxmox beépített RDP, mert **hangot is átvisz**, ha kell  
  - Egy központi helyről, kattintással elérek **bármilyen gépet RDP-n**  
  - **Clipboard átviteli problémák** a Proxmoxnál nem mindig működtek, Guacamole-nál stabilan működik

---

<a name="ssh"></a>

## 1.3 SSH 

### 1.3.1 SSH - Linux konfiguráció és automatizált hardening

Az alábbi hardening intézkedéseket tettem:

*   **Root belépés tiltása**: A `PermitRootLogin no` beállítással megakadályozom a közvetlen root hozzáférést, így kötelező a sudo jogosultsággal rendelkező felhasználó használata.
*   **Kizárólag kulcsalapú hitelesítés**: A jelszavas bejelentkezést teljesen letiltottam (`PasswordAuthentication no`), így kiküszöbölve a brute-force támadások kockázatát.
*   **SSH kulcskezelés**: A hozzáférés kizárólag biztonságos SSH kulcsokkal (az automatizáció miatt jelszó nélkül) lehetséges, melyeket Ansible-lel menedzselek.
*   **Automatikus munkamenet-időtúllépés**: Az inaktív kapcsolatokat a rendszer 15 perc (900 másodperc) után automatikusan bontja az `/etc/profile` fájlban beállított `TMOUT` változó segítségével.
*   **Jogi figyelmeztető banner**: Minden belépési kísérletnél megjelenik az `/etc/issue.net` tartalma, amely tájékoztatja a felhasználót a tevékenységek naplózásáról.

 ---
 
### 1.3.2 SSH - Miért Termius

  - Több gép egyszerre kezelhető egy helyről, **profilokkal és csoportokkal**  
  - Beépített **SSH key management**: kulcsok egyszerű importálása és használata  
  - Kényelmes **multiplatform**: Windows, Linux, macOS, mobil  
  - Titkosított konfigurációk, könnyen **szinkronizálható eszközök között**

---

<a name="vpn"></a>

## 1.4 VPN használata a Homelabban

- **OpenVPN**-t és **WireGuard**-ot használok, de teszteltem a **Tailscale** és **NordVPN Meshnet** megoldásokat is.
- **Publikus szolgáltatások**: Közvetlenül elérhetők az internetről (Reverse Proxy-n keresztül) VPN nélkül is.
- **Belső szolgáltatások**: Kizárólag **VPN-en keresztül** érhetők el, biztosítva a menedzsment felületek védelmét.
- **Full Tunnel**: Mobilról engedélyezve a teljes forgalom a hazai hálózaton megy át, így távolról is élvezhetem az **AdGuard Home** reklámszűrését.

Full tunnel konfiguráció, az AllowedIPs = 0.0.0.0/0 beállítás azt jelenti, hogy a kliens összes forgalma a VPN-en keresztül megy, nem csak a homelab felé irányuló.
<img width="324" height="690" alt="kép" src="https://github.com/user-attachments/assets/8c4b9cf5-7c2e-4360-af11-372dc9466cf1" />


---
<a name="zerotrust"></a>

## 1.5 Zero Trust Remote Access 

A hagyományos VPN-nel szemben a Cloudflare Tunnel csak kifelé irányuló kapcsolatot hoz létre a homelab és a Cloudflare hálózata között.

- **Nincs Port Forwarding:** Nem kell megnyitni a  OpenVPN vagy WireGuard portokat a routeren. Ezzel teljesen elrejtem a publikus IP-címemet a közvetlen támadások elől.
- **Biztonsági rétegek:** A tunnel előtt bekapcsolható a **Cloudflare Access**, ami extra hitelesítést (pl. Google OAuth, GitHub login vagy Authentik) kér, mielőtt a kérés egyáltalán elérné a belső szerveremet.
- **WAF (Web Application Firewall):** Automatikus védelem a botok és a gyakori webes támadások (SQL injection, XSS) ellen.
- **Egyszerű kezelés:** A `cloudflared` egyetlen pehelykönnyű konténerként fut a Dockerben, és központilag, a Cloudflare Zero Trust műszerfaláról konfigurálható.
- **Geo-Blocking (Edge Protection):** A Cloudflare Web Application Firewall (WAF) segítségével aktiváltam a Geo-Blocking funkciót, így a hozzáférést földrajzi elhelyezkedés (IP-alapú országkód) alapján korlátozom, ezzel minimálisra csökkentve a hálózati támadási felületet.

---

← [Vissza a Homelab főoldalra](../README_HU.md)





