module "nixos_image" {
  source  = "github.com/Gabriella439/terraform-nixos-ng//ami"
  release = "23.11"
  region  = var.region
}
