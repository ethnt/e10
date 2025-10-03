# https://nixos.github.io/amis/

# module "nixos_image" {
#   source  = "github.com/Gabriella439/terraform-nixos-ng//ami"
#   release = "23.11"
#   region  = var.region
# }

data "aws_ami" "nixos_x86_64" {
  owners      = ["427812963091"]
  most_recent = false

  filter {
    name   = "name"
    values = ["nixos/25.05.807027.3ff0e34b1383-x86_64-linux"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "nixos_arm64" {
  owners      = ["427812963091"]
  most_recent = false

  filter {
    name   = "name"
    values = ["nixos/25.05.807027.3ff0e34b1383-aarch64-linux"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}
