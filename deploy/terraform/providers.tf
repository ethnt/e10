terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
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

    porkbun = {
      source  = "kyswtn/porkbun"
      version = "0.1.3"
    }
  }
}
