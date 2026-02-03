← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

## 1. APT Cache NG

---

# 1.2 Miért használom?

- Hajnali 3-ra időzített **Ansible** által vezényelt VM és LXC frissítésekhez használom.  
- Cél: ne kelljen minden VM/LXC-re külön letölteni a csomagokat, felesleges adatforgalmat generálva.  
- A cache proxy tárolja a letöltött csomagokat, amiket egy kliens már kért. Ha egy másik gép kéri ugyanazt a csomagot, és szerepel a cache-ben, azaz van hit, akkor a gépek a frissítéseket az APT cache proxy szerverről töltik, nem az internetről, ezzel sávszélességet és adatforgalmat spórolok.

Látható, hogy volt olyan nap, amikor a találati arány 88,26% volt: a 34,05 MB forgalomból 30,05 MB-ot a cache-ből tudott kiszolgálni. A legrosszabb napokon is a 996 MB forgalomból 526 MB-ot szolgált ki, ami 52%-os hatékonyságot jelent. Összességében 6,3 GB adatot szolgáltatott, amelyből csupán 2,2 GB kellett az internetről letölteni, így kb. 4 GB sávszélességet spóroltam.
<div align="center">
  <img src="https://github.com/user-attachments/assets/d2e4134c-879c-4b88-b3f6-ccb0553a6d9f" alt="Leírás" width="800">
</div>

---

← [Vissza a Homelab főoldalra](../README_HU.md)
  


