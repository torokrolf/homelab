← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Távoli Elérés

| Szolgáltatás / Eszköz | Leírás |
|----------------------|--------|
| **Távoli elérés**    | SSH (Termius), RDP (Guacamole) |

---

## 🖥️ RDP (Guacamole)

- **Előny:** Böngészőből kényelmesen elérhető több gép  
- **Miért Guacamole:**  
  - Jobb, mint a Proxmox beépített RDP, mert **hangot is átvisz**, ha kell  
  - Egy helyről, kattintással elérek **bármilyen gépet RDP-n**  
  - **Clipboard átviteli problémák** a Proxmoxnál nem mindig működtek, Guacamole-nál stabilan működik

---

## 🔐 SSH beállítások Linuxon

- **Timeout beállítása**: inaktív SSH session-ök automatikus bontása.
- **Root felhasználó tiltása SSH-n**: közvetlen root belépés megakadályozása.  
- **Jelszavas bejelentkezés letiltva**  
- **Kulcsalapú hitelesítés használata**  : jelszó alapú belépés minimalizálva, erősebb hitelesítés.
  - SSH key beállítva  
  - Passphrase (passkey) nélkül

---

← [Vissza a Homelab főoldalra](../README_HU.md)


