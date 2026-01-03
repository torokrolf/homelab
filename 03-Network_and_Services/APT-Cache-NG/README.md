# APT cache proxy
  - Hajnali 3-ra időzített **Ansible** által vezényelt VM és LXC frissítésekhez használom.
  - Cél: ne kelljen minden VM/LXC-re külön letölteni a csomagokat, felesleges adatforgalmat generálva.
  - A cache proxy tárolja a letöltött csomagokat, így a gépek a frissítéseket az APT cache proxy szerverről töltik, nem az internetről.
