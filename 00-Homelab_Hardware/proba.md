```mermaid
graph LR
    %% Külső világ központi helyen
    Internet((Internet)) --- Asus[ASUS Router]

    %% Bal oldali ág: Otthoni cuccok
    subgraph Home_Net [Otthoni Hálózat - 192.168.1.0/24]
        Devices[TV, Telefonok, stb.]
    end
    Asus --- Home_Net

    %% Jobb oldali ág: A Homelab belépés
    Asus --- Entry[192.168.1.196]

    subgraph Homelab_System [HOMELAB RENDSZER]
        direction TB
        
        subgraph Node2 [Proxmox 2 - M920q]
            VMBR0_P2[vmbr0 - WAN Bridge]
            pfS{pfSense VM}
            VMBR1_P2[vmbr1 - LAN Bridge]

            VMBR0_P2 -- "enp1s0f0" --- pfS
            pfS -- "enp1s0f1" --- VMBR1_P2
        end

        Entry --- VMBR0_P2

        VMBR1_P2 --- SW_P1
        
        subgraph Switch [TP-Link TL-SG108E Switch]
            SW_P1[Port 1] -- "VLAN 30 Trunk" --- SW_P8[Port 8]
        end

        SW_P8 --- P1_NIC
        
        subgraph Node1 [Proxmox 1 - M70q]
            P1_NIC[NIC: enx503eaa522d61]
            P1_Bridge[vmbr0 - VLAN Aware]
            
            P1_NIC --- P1_Bridge

            subgraph Subnets [Hálózatok]
                P1_Bridge -- "Native" --- LAN2[192.168.2.0/24]
                P1_Bridge -- "VLAN 30" --- VLAN3[192.168.3.0/24]
            end

            subgraph VMs [Virtuális Gépek]
                LAN2 --- Ubu[Main Ubuntu]
                VLAN3 --- P1V[Proba 1 VLAN]
            end
        end
    end

    %% Stílusok a tiszta megjelenésért
    style Homelab_System fill:#f8f9fa,stroke:#333,stroke-width:2px,stroke-dasharray: 8 4
    style Entry fill:#fff3cd,stroke:#d4a017,font-weight:bold
    style pfS fill:#f96,stroke:#333,stroke-width:2px
    style Home_Net fill:#fffbe6,stroke:#d4a017,stroke-dasharray: 5 5
```
