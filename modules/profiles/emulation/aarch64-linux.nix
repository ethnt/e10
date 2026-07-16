{
  imports = [ ./common.nix ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
