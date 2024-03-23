terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.13"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.0.0"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "0.46.3"
    }
  }
}
