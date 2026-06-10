#"proxmox_virtual_environment_vm" "edge-gw-01-230"
resource "proxmox_virtual_environment_vm" "edge-gw-01-230" {
    acpi                    = true
    bios                    = "ovmf"
    description             = null
    keyboard_layout         = null
    kvm_arguments           = null
    machine                 = "q35"
    name                    = "edge-gw-01-230"
    node_name               = "proxmoxom"
    protection              = false
    scsi_hardware           = "virtio-scsi-single"
    started                 = true
    tablet_device           = true
    tags                    = []
    template                = false
    vm_id                   = 520

    clone {
    vm_id = 8000 # Itt hivatkozol a template-ed ID-jára
    full  = true
    }

    agent {
        enabled = true
        timeout = "15m"
        trim    = false
        type    = null
    }

    cpu {
        affinity     = null
        architecture = null
        cores        = 2
        flags        = []
        hotplugged   = 0
        limit        = 0
        numa         = false
        sockets      = 1
        type         = "x86-64-v2-AES"
        units        = 1024
    }

    disk {
        aio               = "io_uring"
        backup            = true
        cache             = "none"
        datastore_id      = "vm_tarolo"
        discard           = "on"
        file_format       = "raw"
        file_id           = null
        interface         = "scsi0"
        iothread          = true
        replicate         = true
        serial            = null
        size              = 10
        ssd               = true
    }

    efi_disk {
        datastore_id      = "vm_tarolo"
        file_format       = "raw"
        pre_enrolled_keys = true
        type              = "4m"
    }

    initialization {
        datastore_id         = "vm_tarolo"
        interface            = "scsi1"
        meta_data_file_id    = null
        network_data_file_id = null
        type                 = null
        user_data_file_id    = null
        vendor_data_file_id  = null

        ip_config {
            ipv4 {
                address = "dhcp"
                gateway = null
            }
            ipv6 {
                address = "dhcp"
                gateway = null
            }
        }

        user_account {
            keys     = [
                var.laptopom_pub,
                var.ansible_target_key_pub,
            ]
            password = var.ansible_user_pwd
            username = var.ans_username
        }
    }

    memory {
        dedicated      = 4096
        floating       = 0
        hugepages      = null
        keep_hugepages = false
        shared         = 0
    }

    network_device {
        bridge       = "vmbr0"
        disconnected = false
        enabled      = true
        firewall     = true
        mac_address  = var.mac_edge-gw-01-230
        model        = "virtio"
        mtu          = 0
        queues       = 0
        rate_limit   = 0
        trunks       = null
        vlan_id      = 0
    }

    operating_system {
        type = "l26"
    }

    tpm_state {
        datastore_id = "vm_tarolo"
        version      = "v2.0"
    }

    vga {
        clipboard = null
        memory    = 16
        type      = null
    }
}

#"proxmox_virtual_environment_vm" "access-core-01-206"
resource "proxmox_virtual_environment_vm" "access-core-01-206" {
    acpi                    = true
    bios                    = "ovmf"
    description             = null
    keyboard_layout         = null
    kvm_arguments           = null
    machine                 = "q35"
    name                    = "access-core-01-206"
    node_name               = "proxmoxom"
    protection              = false
    scsi_hardware           = "virtio-scsi-single"
    started                 = true
    tablet_device           = true
    tags                    = []
    template                = false
    vm_id                   = 510

    clone {
    vm_id = 8000 # Itt hivatkozol a template-ed ID-jára
    full  = true
    }

    agent {
        enabled = true
        timeout = "15m"
        trim    = false
        type    = null
    }

    cpu {
        affinity     = null
        architecture = null
        cores        = 2
        flags        = []
        hotplugged   = 0
        limit        = 0
        numa         = false
        sockets      = 1
        type         = "x86-64-v2-AES"
        units        = 1024
    }

    disk {
        aio               = "io_uring"
        backup            = true
        cache             = "none"
        datastore_id      = "vm_tarolo"
        discard           = "on"
        file_format       = "raw"
        file_id           = null
        interface         = "scsi0"
        iothread          = true
        replicate         = true
        serial            = null
        size              = 20
        ssd               = true
    }

    efi_disk {
        datastore_id      = "vm_tarolo"
        file_format       = "raw"
        pre_enrolled_keys = true
        type              = "4m"
    }

    initialization {
        datastore_id         = "vm_tarolo"
        interface            = "scsi1"
        meta_data_file_id    = null
        network_data_file_id = null
        type                 = null
        user_data_file_id    = null
        vendor_data_file_id  = null

        ip_config {
            ipv4 {
                address = "dhcp"
                gateway = null
            }
            ipv6 {
                address = "dhcp"
                gateway = null
            }
        }

        user_account {
            keys     = [
                var.laptopom_pub,
                var.ansible_target_key_pub,
            ]
            password = var.ansible_user_pwd
            username = var.ans_username
        }
    }

    memory {
        dedicated      = 4096
        floating       = 0
        hugepages      = null
        keep_hugepages = false
        shared         = 0
    }

    network_device {
        bridge       = "vmbr0"
        disconnected = false
        enabled      = true
        firewall     = true
        mac_address  = var.mac_access-core-01-206
        model        = "virtio"
        mtu          = 0
        queues       = 0
        rate_limit   = 0
        trunks       = null
        vlan_id      = 0
    }

    operating_system {
        type = "l26"
    }

    tpm_state {
        datastore_id = "vm_tarolo"
        version      = "v2.0"
    }

    vga {
        clipboard = null
        memory    = 16
        type      = null
    }
}

# proxmox_virtual_environment_vm.k3s-server-01-225:
resource "proxmox_virtual_environment_vm" "k3s-server-01-225" {
    acpi                    = true
    bios                    = "ovmf"
    description             = null
    keyboard_layout         = "en-us"
    kvm_arguments           = null
    machine                 = "q35"
    name                    = "k3s-server-01-225"
    node_name               = "proxmoxom"
    protection              = false
    scsi_hardware           = "virtio-scsi-single"
    started                 = true
    tablet_device           = true
    tags                    = []
    template                = false
    vm_id                   = 1105

    clone {
    vm_id = 8000 # Itt hivatkozol a template-ed ID-jára
    full  = true
    }


    agent {
        enabled = true
        timeout = "15m"
        trim    = false
        type    = "virtio"
    }

    cpu {
        affinity     = null
        architecture = null
        cores        = 4
        flags        = []
        hotplugged   = 0
        limit        = 0
        numa         = false
        sockets      = 1
        type         = "x86-64-v2-AES"
        units        = 1024
    }

    disk {
        aio               = "io_uring"
        backup            = true
        cache             = "none"
        datastore_id      = "vm_tarolo"
        discard           = "on"
        file_format       = "raw"
        file_id           = null
        interface         = "scsi0"
        iothread          = true
	path_in_datastore = "vm-1105-disk-1"
        replicate         = true
        serial            = null
        size              = 50
        ssd               = true
    }

    efi_disk {
        datastore_id      = "vm_tarolo"
        file_format       = "raw"
        pre_enrolled_keys = true
        type              = "4m"
    }

    initialization {
        datastore_id         = "vm_tarolo"
        interface            = "scsi1"
        meta_data_file_id    = null
        network_data_file_id = null
        type                 = null
        user_data_file_id    = null
        vendor_data_file_id  = null

        ip_config {
            ipv4 {
                address = "dhcp"
                gateway = null
            }
            ipv6 {
                address = "dhcp"
                gateway = null
            }
        }

        user_account {
            keys     = [
                var.ansible_target_key_pub,
		var.laptopom_pub,
            ]
            password = var.ansible_user_pwd
            username = var.ans_username
        }
    }

    memory {
        dedicated      = 12000
        floating       = 0
        hugepages      = null
        keep_hugepages = false
        shared         = 0
    }

    network_device {
        bridge       = "vmbr0"
        disconnected = false
        enabled      = true
        firewall     = true
        mac_address  = "BC:24:11:3D:77:34"
        model        = "virtio"
        mtu          = 0
        queues       = 0
        rate_limit   = 0
        trunks       = null
        vlan_id      = 0
    }

    operating_system {
        type = "l26"
    }

    tpm_state {
        datastore_id = "vm_tarolo"
        version      = "v2.0"
    }
}

# proxmox_virtual_environment_vm.mgmt-core-01-204:
resource "proxmox_virtual_environment_vm" "mgmt-core-01-204" {
    acpi                    = true
    bios                    = "ovmf"
    description             = null
    keyboard_layout         = null
    kvm_arguments           = null
    machine                 = "q35"
    name                    = "mgmt-core-01-204"
    node_name               = "proxmoxom"
    protection              = false
    scsi_hardware           = "virtio-scsi-single"
    started                 = true
    tablet_device           = true
    tags                    = []
    template                = false
    vm_id                   = 1103

    agent {
        enabled = true
        timeout = "15m"
        trim    = false
        type    = null
    }

    cpu {
        affinity     = null
        architecture = null
        cores        = 2
        flags        = []
        hotplugged   = 0
        limit        = 0
        numa         = false
        sockets      = 1
        type         = "x86-64-v2-AES"
        units        = 1024
    }

    disk {
        aio               = "io_uring"
        backup            = true
        cache             = "none"
        datastore_id      = "vm_tarolo"
        discard           = "on"
        file_format       = "raw"
        file_id           = null
        interface         = "scsi0"
        iothread          = true
        path_in_datastore = "vm-1103-disk-1"
        replicate         = true
        serial            = null
        size              = 10
        ssd               = true
    }

    efi_disk {
        datastore_id      = "vm_tarolo"
        file_format       = "raw"
        pre_enrolled_keys = true
        type              = "4m"
    }

    initialization {
        datastore_id         = "vm_tarolo"
        interface            = "scsi1"
        meta_data_file_id    = null
        network_data_file_id = null
        type                 = null
        user_data_file_id    = null
        vendor_data_file_id  = null

        ip_config {
            ipv4 {
                address = "dhcp"
                gateway = null
            }
            ipv6 {
                address = "dhcp"
                gateway = null
            }
        }

        user_account {
            keys     = [
                var.laptopom_pub,
                var.ansible_target_key_pub,
            ]
            password = var.ansible_user_pwd
            username = var.ans_username
        }
    }

    memory {
        dedicated      = 4096
        floating       = 0
        hugepages      = null
        keep_hugepages = false
        shared         = 0
    }

    network_device {
        bridge       = "vmbr0"
        disconnected = false
        enabled      = true
        firewall     = true
        mac_address  = var.mac_mgmt-core-01-204
        model        = "virtio"
        mtu          = 0
        queues       = 0
        rate_limit   = 0
        trunks       = null
        vlan_id      = 0
    }

    operating_system {
        type = "l26"
    }

    tpm_state {
        datastore_id = "vm_tarolo"
        version      = "v2.0"
    }

    vga {
        clipboard = null
        memory    = 16
        type      = null
    }
}

# proxmox_virtual_environment_vm.template_vm:
resource "proxmox_virtual_environment_vm" "template_vm" {
    acpi                    = true
    bios                    = "ovmf"
    description             = null
    keyboard_layout         = null
    kvm_arguments           = null
    machine                 = "q35"
    name                    = "ubuntu-server-22.04.5-cloudinit"
    node_name               = "proxmoxom"
    protection              = false
    scsi_hardware           = "virtio-scsi-single"
    started                 = false
    tablet_device           = true
    tags                    = []
    template                = true
    vm_id                   = 8000

    agent {
        enabled = true
        timeout = "15m"
        trim    = false
        type    = null
    }

    cpu {
        affinity     = null
        architecture = null
        cores        = 2
        flags        = []
        hotplugged   = 0
        limit        = 0
        numa         = false
        sockets      = 1
        type         = "x86-64-v2-AES"
        units        = 1024
    }

    disk {
        aio               = "io_uring"
        backup            = true
        cache             = "none"
        datastore_id      = "vm_tarolo"
        discard           = "on"
        file_format       = "raw"
        file_id           = null
        interface         = "scsi0"
        iothread          = true
        path_in_datastore = "vm-8000-disk-1"
        replicate         = true
        serial            = null
        size              = 10
        ssd               = true
    }

    efi_disk {
        datastore_id      = "vm_tarolo"
        file_format       = "raw"
        pre_enrolled_keys = true
        type              = "4m"
    }

    initialization {
        datastore_id         = "vm_tarolo"
        interface            = "scsi1"
        meta_data_file_id    = null
        network_data_file_id = null
        type                 = null
        user_data_file_id    = null
        vendor_data_file_id  = null

        ip_config {
            ipv4 {
                address = "dhcp"
                gateway = null
            }
            ipv6 {
                address = "dhcp"
                gateway = null
            }
        }

        user_account {
            keys     = [
                var.ansible_target_key_pub,
                var.laptopom_pub,
            ]
            password = var.ansible_user_pwd
            username = var.ans_username
        }
    }

    memory {
        dedicated      = 4096
        floating       = 0
        hugepages      = null
        keep_hugepages = false
        shared         = 0
    }

     network_device {
        bridge       = "vmbr0"
        disconnected = false
        enabled      = true
        firewall     = true
        mac_address  = var.mac_template_vm
        model        = "virtio"
        mtu          = 0
        queues       = 0
        rate_limit   = 0
        trunks       = null
        vlan_id      = 0
    } 
    
    operating_system {
        type = "l26"
    }

    tpm_state {
        datastore_id = "vm_tarolo"
        version      = "v2.0"
    }

    vga {
        clipboard = null
        type      = null
    }
}
