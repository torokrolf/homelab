terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.2.199:8006/"
  api_token = "${var.proxmox_token_id}=${var.proxmox_token_secret}"
  insecure  = true
}
