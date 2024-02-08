{ pkgs, ... }: {
  imports = [ ./common.nix ];

  services.telegraf.extraConfig = { inputs.zfs = { poolMetrics = true; }; };
}
