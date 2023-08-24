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
  pm_api_url = "https://192.168.10.10:8006/api2/json"
}
