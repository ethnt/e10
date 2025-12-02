terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.24.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.0.0"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.3"
    }

    improvmx = {
      source  = "issyl0/improvmx"
      version = "0.7.1"
    }

    opnsense = {
      source  = "browningluke/opnsense"
      version = "0.12.0"
    }
  }
}
