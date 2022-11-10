# Access key ID and secret access key are provided by environment variables
provider "aws" {
  region = var.region
}

# API token ID and secret provided by environment variables
provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url      = "https://192.168.1.200:8006/api2/json"
}
