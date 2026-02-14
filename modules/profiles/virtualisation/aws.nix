{ modulesPath, ... }: {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

  ec2.hvm = true;

  # Limit number of configurations on AWS specifically. The `/boot` partition
  # is fairly small, so to prevent it getting full, limit the number of
  # configurations/kernels
  boot.loader.grub.configurationLimit = 10;
}
