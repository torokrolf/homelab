# Docker és Rendszertakarítás

A homelab folyamatos működése során jelentős mennyiségű "szemét" (régi Docker image-ek, logfájlok, archívumok) keletkezik. Ez a script automatizálja a helyfelszabadítást úgy, hogy közben ügyel a speciális szolgáltatások (pl. Renovate) integritására.

# Szelektív Image Takarítás

A hagyományos takarító scriptekkel szemben ez a megoldás címke (label) alapú szűrést használ. 

*   **A probléma:** Bizonyos szolgáltatások, mint a **Renovate**, csak időszakosan (pl. óránként egyszer) futnak le. Egy sima takarítás során a Docker "nem használtnak" ítélné az image-ét és törölné, ami felesleges hálózati forgalmat és lassabb indulást eredményezne.
*   **A megoldás:** A Renovate konténerhez a Docker Compose-ban hozzáadtam a `cleanup=ignore` matricát.
*   **Szűrés:** A script a `docker image prune -a -f --filter "label!=cleanup=ignore"` parancsot használja, így a védelemmel ellátott image-ek érintetlenek maradnak akkor is, ha éppen nem fut belőlük konténer.

# További Takarítási Lépések

*   **Naplókezelés:** A `journalctl --vacuum-time=1d` parancs korlátozza a rendszernaplók méretét, csak az utolsó 24 órát tartja meg a lemezen.
*   **Archívumok törlése:** A `/var/log` mappából automatikusan eltávolítja a régi, tömörített (`.gz`) logfájlokat.
*   **Containerd mélytakarítás:** A `ctr -n moby content prune` parancs elvégzi a Docker alatti rétegek tisztítását is, de a label-alapú védelem miatt a hivatkozott (referenced) image-eket itt is megkíméli[cite: 1].

# Ütemezés

A script futtatása **root crontabból** történik minden vasárnap hajnali 3 órakor:
`0 3 * * 0 /usr/local/bin/docker-clean.sh`[cite: 1]

---
← [Vissza a Homelab főoldalra](../README_HU.md)