terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.7"
    }

    sops = {
      source = "carlpett/sops"
      version = "0.7.2"
    }
  }
}
