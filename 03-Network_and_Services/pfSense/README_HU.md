## pfSense – Network & Security Setup

Ebben a projektben egy **pfSense alapú peremhálózati (edge) tűzfalat és routert** terveztem, konfiguráltam és üzemeltetek egy **valós homelab / otthoni környezetben**.  
A célom vállalati környezetben is releváns **hálózati és biztonsági megoldások** megvalósítása volt.

---

### 🔐 Firewall & Network Security
- Egyedi **tűzfalszabályok** tervezése és implementálása (LAN / WAN / VPN)
- **Stateful firewall** működésének gyakorlati alkalmazása
- Bejövő és kimenő forgalom szeparálása
- Szolgáltatás- és IP-alapú engedélyezés
- VPN interfészekhez dedikált firewall szabályok

---

### 🌐 NAT & Routing
- **Outbound NAT** konfigurálása belső hálózat számára
- **Port Forward NAT** külső szolgáltatások publikálásához
- Belső erőforrások védelme NAT-on keresztül
- Routing logika és forgalomirányítás megértése

---

### 📡 Core Network Services
- **DHCP szerver** konfigurálása és üzemeltetése
  - IP tartományok kezelése
  - Statikus DHCP lease-ek
  - Gateway és DNS kiosztás
- **NTP szerver** futtatása
  - Időszinkron biztosítása belső klienseknek

---

### 🔑 VPN megoldások
- **WireGuard VPN**
  - Modern, gyors VPN megoldás
  - Távoli hozzáférés biztosítása belső hálózathoz
- **OpenVPN**
  - Tanúsítvány-alapú hitelesítés
  - Kompatibilitás különböző kliensekkel
- VPN-en keresztüli routing és tűzfalszabályok kialakítása

---

### 🌍 Dynamic DNS (DDNS)
- **DDNS kliens konfigurálása**
- Dinamikus publikus IP-cím kezelése
- Külső elérés stabil biztosítása (VPN, szolgáltatások)

---

### 🛠️ Használt technológiák
- pfSense
- Firewall & NAT
- DHCP, NTP
- WireGuard, OpenVPN
- Dynamic DNS (DDNS)
- TCP/IP, routing, network security

---

### 🎯 Mit bizonyít ez a projekt?
- Valós hálózati problémák megoldása gyakorlatban
- Biztonságtudatos hálózattervezés
- VPN és tűzfal technológiák stabil ismerete
- Homelab környezetben szerzett, **valós életben alkalmazható tapasztalat**

> Ez a projekt bemutatja, hogyan tervezek és üzemeltetek  
> **biztonságos, skálázható hálózati infrastruktúrát**,  
> amely megfelel junior / medior rendszer- vagy hálózati üzemeltetői elvárásoknak.
