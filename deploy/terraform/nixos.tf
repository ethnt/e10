module "nixos_image" {
  source  = "github.com/Gabriella439/terraform-nixos-ng//ami"
  release = "24.05"
  region  = var.region
}
