# EZEK NEM LÉTEZŐ ADATOK ITT!!!!!!!!!!!!

# PROXMOX KAPCSOLATI ADATOK
# Ezeket a Proxmox API felületén tudom legenerálni.
proxmox_token_id     = "root@pam!terraform"
proxmox_token_secret = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"

# ANSIBLE USER KONFIGURÁCIÓ
# Az Ansible az új VM-eken ezt a felhasználót hozza majd létre.
ans_username          = "ansible"
ans_username_pwd      = "vEletLen_jElsZo_99_XYZ"

# SSH KULCSOK
ansible_target_key_pub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXAMPLE1234567890abcdef1234567890ABC ansible_machine"
laptopom_pub           = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXAMPLE0987654321fedcba0987654321ZYX rolf-pc"

# HÁLÓZATI KONFIGURÁCIÓ (MAC CÍMEK)
# Ezek fix MAC címek, amikkel a DHCP szerveren a statikus IP-ket osztod.
mac_mgmt-core-01-204   = "BC:24:11:69:F6:3C"
mac_template_vm        = "BC:24:11:08:32:85"
mac_access-core-01-206 = "BC:24:11:3E:A2:F5"
mac_edge-gw-01-230     = "BC:24:11:8A:4D:C2"