{ config, lib, hosts, ... }: {
  imports = [ ./common.nix ];

  # Only mount this if it's *not* omnibus -- it's not possible to conditionally import, and this needs to be imported
  # for backups to work elsewhere, so better to add the conditional here
  fileSystems = lib.mkIf (config.networking.hostName != "omnibus") {
    "/mnt/files/backup" = let
      # Use local network if local, otherwise use Tailscale
      host = if builtins.elem "@external" config.deployment.tags then
        hosts.omnibus.config.networking.hostName
      else
        hosts.omnibus.config.satan.address;
    in {
      device =
        "${host}:${hosts.omnibus.config.disko.devices.zpool.files.datasets.root.mountpoint}/backup";
      fsType = "nfs";
      options = [ "x-systemd.automount" "exec" ];
    };
  };
}
