← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

## 1. APT Cache NG

---

# 1.2 Miért használom?

- Hajnali 3-ra időzített **Ansible** által vezényelt VM és LXC frissítésekhez használom.  
- Cél: ne kelljen minden VM/LXC-re külön letölteni a csomagokat, felesleges adatforgalmat generálva.  
- A cache proxy tárolja a letöltött csomagokat, amiket egy kliens már kért. Ha egy másik gép kéri ugyanazt a csomagot, és szerepel a cache-ben, azaz van hit, akkor a gépek a frissítéseket az APT cache proxy szerverről töltik, nem az internetről, ezzel sávszélességet és adatforgalmat spórolok.

Láthatom, hogy volt nap mikor 88,26% volt a találat, és 34,05mb-ből 30.05mb-ot cache-ből tudott szolgálni, míg a legrosszabb napon is 526mb-ot szolgáltatott a 996mb-ból tehát 52%-os aránnyal futott. 6,3Gb-t volt az összes adat amit szolgáltatott és csak 2,2Gb-ot kellett az internetről leszednie, tehát kb 4Gb-ot spórolt.
<div align="center">
  <img src="https://github.com/user-attachments/assets/d2e4134c-879c-4b88-b3f6-ccb0553a6d9f" alt="Leírás" width="400">
</div>


  


