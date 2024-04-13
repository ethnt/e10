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
  alias    = "anise"
  endpoint = "https://anise:8006/"
  username = data.sops_file.secrets.data["ANISE_PM_USERNAME"]
  password = data.sops_file.secrets.data["ANISE_PM_PASSWORD"]
  insecure = true

  ssh {
    agent    = true
    username = "deploy"
  }
}

provider "proxmox" {
  alias    = "basil"
  endpoint = "https://basil:8006/"
  username = data.sops_file.secrets.data["BASIL_PM_USERNAME"]
  password = data.sops_file.secrets.data["BASIL_PM_PASSWORD"]
  insecure = true

  ssh {
    agent    = true
    username = "deploy"
  }
}

provider "proxmox" {
  alias    = "cardamom"
  endpoint = "https://cardamom:8006/"
  username = data.sops_file.secrets.data["CARDAMOM_PM_USERNAME"]
  password = data.sops_file.secrets.data["CARDAMOM_PM_PASSWORD"]
  insecure = true

  ssh {
    agent    = true
    username = "deploy"
  }
}

provider "proxmox" {
  alias    = "dill"
  endpoint = "https://dill:8006/"
  username = data.sops_file.secrets.data["DILL_PM_USERNAME"]
  password = data.sops_file.secrets.data["DILL_PM_PASSWORD"]
  insecure = true

  ssh {
    agent    = true
    username = "deploy"
  }
}

provider "proxmox" {
  alias    = "elderflower"
  endpoint = "https://elderflower:8006/"
  username = data.sops_file.secrets.data["ELDERFLOWER_PM_USERNAME"]
  password = data.sops_file.secrets.data["ELDERFLOWER_PM_PASSWORD"]
  insecure = true

  ssh {
    agent    = true
    username = "deploy"
  }
}

provider "improvmx" {
  token = data.sops_file.secrets.data["IMPROVMX_API_TOKEN"]
}
