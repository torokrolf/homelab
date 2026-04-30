#!/bin/bash

# --- 1. DOCKER IMAGE TAKARÍTÁS (OKOSAN) ---
# Törli az összes nem használt image-et, KIVÉVE azokat, amik:
# - éppen futnak
# - vagy rajtuk van a "cleanup=ignore" címke
docker image prune -a -f --filter "label!=cleanup=ignore"

# --- 2. RENDSZERNAPLÓK (JOURNAL) ---
# Csak az utolsó 24 órát tartjuk meg, a többi repül (helyfelszabadítás)
sudo journalctl --vacuum-time=1d

# --- 3. RÉGI ARCHÍV LOGOK ---
# A /var/log mappából a tömörített régi szemetet kiszórjuk
sudo find /var/log -type f -name "*.gz" -delete

# --- 4. CONTAINERTD MÉLYTAKARÍTÁS ---
# Ez a parancs takarít be a Docker alatt. 
# Mivel a fenti prune parancsnál VÉDETTÜK a Renovate-et, 
# a containerd is látni fogja a hivatkozást (reference), és nem törli le.
sudo ctr -n moby content prune references
