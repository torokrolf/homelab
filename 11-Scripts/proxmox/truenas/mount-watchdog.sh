#!/bin/bash
# ----------------------------
# Mount Watchdog (Proxmox VE9) - ENTERPRISE K8S-AWARE VERSION
# ----------------------------

# --- LXC KONFIGURÁCIÓ ---
declare -A LXC_LIST=( [1010]="/mnt/torrent" )

# --- VM KONFIGURÁCIÓ ---
declare -A VM_LIST=( [1101]="/mnt/pxeiso" )

# Docker VM KONFIGURÁCIÓ
#DOCKER_VM_ID=1102
#DOCKER_VM_IP="192.168.2.230"
#DOCKER_VM_USER="rolf"
#DOCKER_STACK_PATH="/opt/apps-stack/media-stack"

# K3S VM Konfiguráció
K3S_VM_ID=1105
K3S_VM_IP="192.168.2.225"
K3S_VM_USER="rolf"
K3S_NAMESPACE="media"
K3S_APPS="bazarr prowlarr qbittorrent radarr seerr sonarr"

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GOTIFY_SCRIPT="/usr/local/bin/send-gotify.sh"
NAS_IP="192.168.2.220"
STATE_FILE="/var/lib/mount-watchdog/nas_status.state"

mkdir -p /var/lib/mount-watchdog

# --- TrueNAS állapot ellenőrzés ---
if ping -c1 -W1 $NAS_IP >/dev/null 2>&1; then
    NAS_ONLINE=0
    CURRENT_STATUS="UP"
else
    NAS_ONLINE=1
    CURRENT_STATUS="DOWN"
fi

PREVIOUS_STATUS="DOWN"
[ -f "$STATE_FILE" ] && PREVIOUS_STATUS=$(cat "$STATE_FILE")

if [ "$CURRENT_STATUS" == "$PREVIOUS_STATUS" ]; then
    exit 0
fi

echo "$(date '+%F %T') - Státuszváltás észlelve: $PREVIOUS_STATUS -> $CURRENT_STATUS"

if [ "$CURRENT_STATUS" == "UP" ]; then
    $GOTIFY_SCRIPT "✅ TrueNAS újra elérhető! A rendszerek indulnak."
else
    $GOTIFY_SCRIPT "⚠️ HIBA: TrueNAS elérhetetlen! A függő rendszerek leállításra kerülnek."
fi

# --- Kezelő függvények ---

handle_lxc() {
    local ID=$1
    [ $NAS_ONLINE -eq 0 ] && pct start $ID 2>/dev/null || pct stop $ID 2>/dev/null
}

handle_vm() {
    local ID=$1
    [ $NAS_ONLINE -eq 0 ] && qm start $ID 2>/dev/null || qm stop $ID 2>/dev/null
}

handle_vm_docker() {
    if qm status $DOCKER_VM_ID | grep -q "status: running"; then
        if [ $NAS_ONLINE -eq 0 ]; then
            ssh -o ConnectTimeout=3 ${DOCKER_VM_USER}@${DOCKER_VM_IP} "cd ${DOCKER_STACK_PATH} && docker compose start" >/dev/null 2>&1
        else
            ssh -o ConnectTimeout=3 ${DOCKER_VM_USER}@${DOCKER_VM_IP} "timeout 15s docker compose -f ${DOCKER_STACK_PATH}/docker-compose.yml stop" >/dev/null 2>&1
        fi
    fi
}

handle_k3s_media() {
    if qm status $K3S_VM_ID | grep -q "status: running"; then
        local REPLICAS=0
        [ $NAS_ONLINE -eq 0 ] && REPLICAS=1

        echo "K3S: $K3S_APPS skálázása $REPLICAS példányra..."
        for APP in $K3S_APPS; do
            ssh -o ConnectTimeout=3 ${K3S_VM_USER}@${K3S_VM_IP} "kubectl scale deployment $APP --replicas=$REPLICAS -n $K3S_NAMESPACE" >/dev/null 2>&1 &
        done
    fi
}

# --- FUTTATÁS PÁRHUZAMOSAN ---

for ID in "${!LXC_LIST[@]}"; do handle_lxc "$ID" & done
for ID in "${!VM_LIST[@]}"; do handle_vm "$ID" & done
handle_vm_docker &
handle_k3s_media &

wait

echo "$CURRENT_STATUS" > "$STATE_FILE"
echo "$(date '+%F %T') - Minden művelet befejezve."
exit 0
