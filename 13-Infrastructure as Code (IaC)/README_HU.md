---

## 1.1 Infrastructure as Code (IaC) - Terraform & Provisioning

A virtuális infrastruktúrát **Terraform** segítségével hozom létre és kezelem, ami biztosítja a környezet gyors és egységes reprodukálhatóságát.

*   **Provisioning folyamat:** A virtuális gépeket egy általam előkészített **Golden Image** (Ubuntu 22.04 Proxmox template) alapján hozom létre. A Terraform a sablonról **Full Clone** másolatot készít, így az új VM-ek teljesen függetlenek az alaprendszertől.
*   **Erőforrás menedzsment:** A VM-ek hardveres paramétereit (CPU, RAM, Disk, Network) deklaratív módon, a kódban definiálom. Ez lehetővé teszi az eltérő terhelésű csomópontok — például a memóriaigényesebb **k3s server** és a kisebb erőforrásigényű **gateway** — pontos méretezését.
*   **Cloud-Init Automatizáció:** A Terraform `initialization` blokkján keresztül dinamikusan beállítom a biztonsági hozzáféréseket (SSH kulcsok). Ez a folyamat teljesen kiváltja a manuális konfigurációt: a gép az első indítás után azonnal "ready-to-use" állapotba kerül az Ansible számára.

---