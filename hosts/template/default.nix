{ suites, ... }: {
  imports = with suites; base;

  # services.qemuGuest.enable = true;

  # boot.loader = {
  #   systemd-boot.enable = true;
  #   efi.canTouchEfiVariables = true;
  # };
}
