# https://nixos.github.io/amis/

# data "aws_ami" "nixos_arm64" {
#   owners      = ["427812963091"]
#   most_recent = false

#   filter {
#     name   = "name"
#     values = ["nixos/25.05.807027.3ff0e34b1383-aarch64-linux"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["arm64"]
#   }
# }

variable "aws_ami_nixos_arm64" {
  default = "ami-0da2240a68445a0f9"
}
