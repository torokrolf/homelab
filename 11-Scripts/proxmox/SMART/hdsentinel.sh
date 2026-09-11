#!/bin/bash

# --- BEÁLLÍTÁSOK ---
GOTIFY_URL="http://192.168.2.225:30080"
APP_TOKEN="A2FEaTL2A5g77PA"
HOSTNAME=$(hostname)
TEMP_FILE="/tmp/hds_report.txt"

# Teljes elérési utak a biztonság kedvéért (cron-hoz kell)
SMARTCTL="/usr/sbin/smartctl"
HDSENTINEL="/usr/local/bin/hdsentinel"
CURL="/usr/bin/curl"

# 1. LEMEZKERESÉS
# Az 'n1' végződést levágjuk az nvme-nél a teszt indításához
DISKS=$(lsblk -dno NAME | grep -E '^sd[a-z]$|^nvme[0-9]n[0-9]$')

echo "Észlelt lemezek: $DISKS"

# 2. ÖNTESZTEK INDÍTÁSA
for D in $DISKS; do
    DEV="/dev/$D"
    [[ $D == nvme* ]] && DEV="/dev/${D%n*}" # nvme0n1 -> /dev/nvme0
    
    echo "Rövid önteszt indítása: $DEV"
    $SMARTCTL -t short $DEV > /dev/null 2>&1
done

# 3. VÁRAKOZÁS (5 perc = 300 mp)
echo -n "Várakozás a tesztek befejezésére (300 mp)"
for i in {1..30}; do 
    echo -n "."
    sleep 10
done
echo " KÉSZ!"

# 4. JELENTÉS ÖSSZEÁLLÍTÁSA
echo "HDSentinel Jelentés - $HOSTNAME" > $TEMP_FILE
echo "Dátum: $(date '+%Y-%m-%d %H:%M:%S')" >> $TEMP_FILE
echo "-----------------------------------" >> $TEMP_FILE

# HDSentinel adatok (fejléc levágva)
$HDSENTINEL | sed '1,4d' >> $TEMP_FILE

echo -e "\n--- UTOLSÓ ÖNTESZTEK ELLENŐRZÉSE ---" >> $TEMP_FILE

for D in $DISKS; do
    DEV="/dev/$D"
    [[ $D == nvme* ]] && DEV="/dev/${D%n*}"

    if [[ $D == nvme* ]]; then
        # NVMe: Keressük a "Short" bejegyzést a selftest logban
        RESULT=$($SMARTCTL -l selftest $DEV 2>/dev/null | grep -i "Short" | head -n 1 | xargs)
    else
        # SATA SSD: Keressük a sor eleji # jelet és az 1-est (bármennyi szóközzel)
        # Ez javítja ki az sda: Nincs friss adat hibát
        RESULT=$($SMARTCTL -l selftest $DEV 2>/dev/null | grep -E "^#[[:space:]]+1" | head -n 1 | xargs)
    fi

    echo "$D: ${RESULT:-Nincs friss adat / Teszt még fut}" >> $TEMP_FILE
done

# 5. KÜLDÉS GOTIFY-RA
$CURL -s -X POST "$GOTIFY_URL/message?token=$APP_TOKEN" \
    -F "title=Napi Jelentés - $HOSTNAME" \
    -F "message=<$TEMP_FILE" \
    -F "priority=5"

# 6. TAKARÍTÁS
rm -f $TEMP_FILE
