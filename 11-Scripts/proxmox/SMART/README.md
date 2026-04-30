# Lemezállapot jelentés (S.M.A.R.T. & HDSentinel)

Ez a Bash script a szerver fizikai meghajtóinak állapotát figyeli és küldi el Gotify-ra. A cél az volt, hogy ne kelljen manuálisan ellenőrizni a logokat, hanem minden reggel érkezzen egy friss állapotjelentés a mobilomra.

## Működési elv

1.  **Automatikus detektálás:** A script magától felismeri a rendszerben lévő SATA SSD-ket és NVMe meghajtókat.
2.  **Aktív tesztelés:** Nem csak a korábbi adatokat olvassa ki, hanem indít egy rövid öntesztet (short test) minden meghajtón.
3.  **Adatgyűjtés:** Összefésüli a smartctl short test és a hdsentinel állapotjelentő kimenetét egyetlen jelentésbe.
4.  **Értesítés:** Az összeállított riportot egy POST kéréssel küldi el a Gotify szervernek, ami azonnal push értesítést generál.

### Miért hasznos?

*   **Időzített ellenőrzés:** Cron segítségével (pl. napi futtatással) automatizálható a teljes folyamat, én is ezt alkalmazom.
*   **Hiba-megelőzés:** Az öntesztek futtatásával még azelőtt kiszűrhetők a gyengélkedő szektorok, mielőtt adatvesztés történne.
*   **Központi naplózás:** Minden lemez adata (hőmérséklet, kondíció, hátralévő élettartam) egy helyen látható.

