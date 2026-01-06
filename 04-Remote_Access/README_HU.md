← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Távoli Elérés

| Szolgáltatás / Eszköz | Leírás |
|----------------------|--------|
| **Távoli elérés**    | SSH (Termius), RDP (Guacamole) |

---

## RDP 

- **Miért Guacamole:**
  - Böngészőből kényelmesen elérhető több gép  
  - Jobb, mint a Proxmox beépített RDP, mert **hangot is átvisz**, ha kell  
  - Egy központi helyről, kattintással elérek **bármilyen gépet RDP-n**  
  - **Clipboard átviteli problémák** a Proxmoxnál nem mindig működtek, Guacamole-nál stabilan működik

---

## SSH 

### SSH - Beállítások Linuxon

- **Timeout beállítása**: inaktív SSH session-ök automatikus bontása.
- **Root felhasználó tiltása SSH-n**: közvetlen root belépés megakadályozása.  
- **Jelszavas bejelentkezés letiltva**  
- **Kulcsalapú hitelesítés használata**  : jelszó alapú belépés minimalizálva, erősebb hitelesítés.
  - SSH key beállítva  
  - Passphrase (passkey) nélkül
 
 ---
 
### SSH - Miért Termius

  - Több gép egyszerre kezelhető egy helyről, **profilokkal és csoportokkal**  
  - Beépített **SSH key management**: kulcsok egyszerű importálása és használata  
  - Kényelmes **multiplatform**: Windows, Linux, macOS, mobil  
  - Titkosított konfigurációk, könnyen **szinkronizálható eszközök között**

---

← [Vissza a Homelab főoldalra](../README_HU.md)





