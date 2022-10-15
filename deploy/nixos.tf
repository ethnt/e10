module "nixos_image" {
  source  = "git::https://github.com/ethnt/terraform-nixos.git//aws_image_nixos?ref=f9f4114766c692d66dfee1f8b0c661a363d78959"
  release = "22.05"
}
