#PROXMOX NODE1-HEZ VALO KAPCSOLODASHOZ SZUKSEGES ADATOK 
variable "proxmox_token_id" {
  type = string
}

variable "proxmox_token_secret" {
  type      = string
  sensitive = true
}

#ANSIBLE USER LETREHOZASAHOZ SZUKSEGES ADATOK

variable "ans_username" {
  type    = string
}

variable "ansible_user_pwd" {
  type    = string
  sensitive = true
}

#AZ ANSIBLE GEP ES A LAPTOPOM SSH KULCSA, HOGY AZ ANSIBLE USERHEZ BE TUDJAK LEPNI LAPTOPOMROL ES AZ ANSIBLE SERVER GEPROL SSH KULCCSAL

variable "laptopom_pub" {
  type    = string
}

variable "ansible_target_key_pub" {
  type    = string
}

#MAC CÍMEK

variable "mac_mgmt-core-01-204" {
  type    = string
}

variable "mac_template_vm" {
  type    = string
}

variable "mac_access-core-01-206" {
  type    = string
}

variable "mac_edge-gw-01-230" {
  type    = string
}


