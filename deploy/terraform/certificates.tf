variable "acme_staging_directory" {
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
  type    = string
}

variable "acme_production_directory" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
  type    = string
}

variable "acme_tos" {
  default = "https://letsencrypt.org/documents/LE-SA-v1.4-April-3-2024.pdf"
  type    = string
}

resource "proxmox_virtual_environment_acme_account" "anise_staging" {
  provider = proxmox.anise

  name      = "staging"
  contact   = var.admin_email_address
  directory = var.acme_staging_directory
  tos       = var.acme_tos
}

resource "proxmox_virtual_environment_acme_account" "anise_production" {
  provider = proxmox.anise

  name      = "production"
  contact   = var.admin_email_address
  directory = var.acme_production_directory
  tos       = var.acme_tos
}

resource "proxmox_virtual_environment_acme_dns_plugin" "anise_dns_plugin" {
  provider = proxmox.anise

  plugin = "anise-dns-plugin"
  api    = "aws"

  data = {
    AWS_ACCESS_KEY_ID     = data.sops_file.secrets.data["AWS_ACCESS_KEY_ID"]
    AWS_SECRET_ACCESS_KEY = data.sops_file.secrets.data["AWS_SECRET_ACCESS_KEY"]
  }
}

resource "proxmox_virtual_environment_acme_account" "basil_staging" {
  provider = proxmox.basil

  name      = "staging"
  contact   = var.admin_email_address
  directory = var.acme_staging_directory
  tos       = var.acme_tos
}

resource "proxmox_virtual_environment_acme_account" "basil_production" {
  provider = proxmox.basil

  name      = "production"
  contact   = var.admin_email_address
  directory = var.acme_production_directory
  tos       = var.acme_tos
}

resource "proxmox_virtual_environment_acme_dns_plugin" "basil_dns_plugin" {
  provider = proxmox.basil

  plugin = "basil-dns-plugin"
  api    = "aws"

  data = {
    AWS_ACCESS_KEY_ID     = data.sops_file.secrets.data["AWS_ACCESS_KEY_ID"]
    AWS_SECRET_ACCESS_KEY = data.sops_file.secrets.data["AWS_SECRET_ACCESS_KEY"]
  }
}

resource "proxmox_virtual_environment_acme_account" "cardamom_staging" {
  provider = proxmox.cardamom

  name      = "staging"
  contact   = var.admin_email_address
  directory = var.acme_staging_directory
  tos       = var.acme_tos
}

resource "proxmox_virtual_environment_acme_account" "cardamom_production" {
  provider = proxmox.cardamom

  name      = "production"
  contact   = var.admin_email_address
  directory = var.acme_production_directory
  tos       = var.acme_tos
}

resource "proxmox_virtual_environment_acme_dns_plugin" "cardamom_dns_plugin" {
  provider = proxmox.cardamom

  plugin = "cardamom-dns-plugin"
  api    = "aws"

  data = {
    AWS_ACCESS_KEY_ID     = data.sops_file.secrets.data["AWS_ACCESS_KEY_ID"]
    AWS_SECRET_ACCESS_KEY = data.sops_file.secrets.data["AWS_SECRET_ACCESS_KEY"]
  }
}

resource "proxmox_virtual_environment_acme_account" "elderflower_staging" {
  provider = proxmox.elderflower

  name      = "staging"
  contact   = var.admin_email_address
  directory = var.acme_staging_directory
  tos       = var.acme_tos
}

resource "proxmox_virtual_environment_acme_account" "elderflower_production" {
  provider = proxmox.elderflower

  name      = "production"
  contact   = var.admin_email_address
  directory = var.acme_production_directory
  tos       = var.acme_tos
}

resource "proxmox_virtual_environment_acme_dns_plugin" "elderflower_dns_plugin" {
  provider = proxmox.elderflower

  plugin = "elderflower-dns-plugin"
  api    = "aws"

  data = {
    AWS_ACCESS_KEY_ID     = data.sops_file.secrets.data["AWS_ACCESS_KEY_ID"]
    AWS_SECRET_ACCESS_KEY = data.sops_file.secrets.data["AWS_SECRET_ACCESS_KEY"]
  }
}
