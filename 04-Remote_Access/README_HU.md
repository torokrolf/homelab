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

### 1.3.1 SSH - Beállítások Linuxon

- **Timeout beállítása**: inaktív SSH session-ök automatikus bontása.
- **Root felhasználó tiltása SSH-n**: közvetlen root belépés megakadályozása.  
- **Jelszavas bejelentkezés letiltva**  
- **Kulcsalapú hitelesítés használata**  : jelszó alapú belépés minimalizálva, erősebb hitelesítés.
  - SSH key beállítva  
  - Passphrase (passkey) nélkül

 ---
 
### 1.3.2 SSH - Beállítások Linuxon

*   **Root felhasználó tiltása**: A `PermitRootLogin no` beállítással megakadályozom a közvetlen root belépést.
*   **Jelszó alapú hitelesítés letiltása**: Csak kulcsalapú hitelesítés engedélyezett (`PasswordAuthentication no`), így védve a rendszert a Brute-force támadások ellen.
*   **Automatikus Session Timeout**: Az `export TMOUT=900` beállítással 15 perc inaktivitás után a rendszer automatikusan bontja a kapcsolatot.
*   **Jogi figyelmeztetés (Banner)**: Minden belépésnél megjelenik a `/etc/issue.net` tartalma, figyelmeztetve a naplózásra.

 ---
 
### 1.3.3 SSH - Miért Termius

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
- **Full Tunnel**: Mobilról engedélyezve a teljes forgalom a hazai hálózaton megy át, így távolról is élvezhetem a **Pi-hole / AdGuard Home** reklámszűrését.

---
<a name="zerotrust"></a>

## 1.5 Zero Trust Remote Access 

A hagyományos VPN-nel szemben a Cloudflare Tunnel csak kifelé irányuló kapcsolatot hoz létre a homelab és a Cloudflare hálózata között.

- **Nincs Port Forwarding:** Nem kell megnyitni a  OpenVPN vagy WireGuard portokat a routeren. Ezzel teljesen elrejtem a publikus IP-címemet a közvetlen támadások elől.
- **Biztonsági rétegek:** A tunnel előtt bekapcsolható a **Cloudflare Access**, ami extra hitelesítést (pl. Google OAuth, GitHub login vagy Authentik) kér, mielőtt a kérés egyáltalán elérné a belső szerveremet.
- **WAF (Web Application Firewall):** Automatikus védelem a botok és a gyakori webes támadások (SQL injection, XSS) ellen.
- **Egyszerű kezelés:** A `cloudflared` egyetlen pehelykönnyű konténerként fut a Dockerben, és központilag, a Cloudflare Zero Trust műszerfaláról konfigurálható.

---

← [Vissza a Homelab főoldalra](../README_HU.md)





