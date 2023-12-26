provider "tailscale" {
  oauth_client_id     = data.sops_file.secrets.data["TAILSCALE_OAUTH_CLIENT_ID"]
  oauth_client_secret = data.sops_file.secrets.data["TAILSCALE_OAUTH_CLIENT_SECRET"]
  tailnet             = data.sops_file.secrets.data["TAILSCALE_TAILNET"]
}

provider "aws" {
  access_key = data.sops_file.secrets.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.sops_file.secrets.data["AWS_SECRET_ACCESS_KEY"]
  region     = var.region
}

provider "proxmox" {
  alias               = "anise"
  pm_api_url          = "https://anise:8006/api2/json"
  pm_api_token_id     = data.sops_file.secrets.data["ANISE_PM_API_TOKEN_ID"]
  pm_api_token_secret = data.sops_file.secrets.data["ANISE_PM_API_TOKEN_SECRET"]
}

provider "proxmox" {
  alias               = "basil"
  pm_api_url          = "https://basil:8006/api2/json"
  pm_api_token_id     = data.sops_file.secrets.data["BASIL_PM_API_TOKEN_ID"]
  pm_api_token_secret = data.sops_file.secrets.data["BASIL_PM_API_TOKEN_SECRET"]
}

provider "proxmox" {
  alias               = "cardamom"
  pm_api_url          = "https://cardamom:8006/api2/json"
  pm_api_token_id     = data.sops_file.secrets.data["CARDAMOM_PM_API_TOKEN_ID"]
  pm_api_token_secret = data.sops_file.secrets.data["CARDAMOM_PM_API_TOKEN_SECRET"]
}
