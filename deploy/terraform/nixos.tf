# module "nixos_image" {
#   source  = "github.com/Gabriella439/terraform-nixos-ng//ami"
#   release = "23.11"
#   region  = var.region
# }

data "aws_ami" "nixos_x86_64" {
  owners      = ["427812963091"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nixos/25.05*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
