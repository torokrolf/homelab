# Lemezállapot jelentés (S.M.A.R.T. & HDSentinel)

Ez a Bash script a szerver fizikai meghajtóinak állapotát figyeli és küldi el Gotify-ra. A cél az volt, hogy ne kelljen manuálisan ellenőrizni a logokat, hanem minden reggel érkezzen egy friss állapotjelentés a mobilomra.

## Működési elv

**Automatikus detektálás:** A script magától felismeri a rendszerben lévő SATA SSD-ket és NVMe meghajtókat.
**Aktív tesztelés:** Nem csak a korábbi adatokat olvassa ki, hanem indít egy rövid öntesztet (short test) minden meghajtón.
**Adatgyűjtés:** Összefésüli a smartctl short test és a hdsentinel állapotjelentő kimenetét egyetlen jelentésbe.
**Értesítés:** Az összeállított riportot egy POST kéréssel küldi el a Gotify szervernek, ami azonnal push értesítést generál.

### Miért hasznos?

**Időzített ellenőrzés:** Cron segítségével (pl. napi futtatással) automatizálható a teljes folyamat, én is ezt alkalmazom.
**Hiba-megelőzés:** Az öntesztek futtatásával még azelőtt kiszűrhetők a gyengélkedő szektorok, mielőtt adatvesztés történne.
**Központi naplózás:** Minden lemez adata (hőmérséklet, kondíció, hátralévő élettartam) egy helyen látható.

  Itt láthatom az értesítés egy részletét Gotify-on.
•	<p align="center">
  <img src="https://github.com/user-attachments/assets/1e7ee0e3-a313-4e9f-af83-dfee54403e0a" alt="Description" width="300">
</p>


