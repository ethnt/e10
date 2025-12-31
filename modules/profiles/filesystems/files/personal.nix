{ config, hosts, ... }: {
  imports = [ ./common.nix ];

  fileSystems."/mnt/files/personal" = let
    # Use local network if local, otherwise use Tailscale
    host = if builtins.elem "@external" config.deployment.tags then
      hosts.omnibus.config.networking.hostName
    else
      hosts.omnibus.config.satan.address;
  in {
    device =
      "${host}:${hosts.omnibus.config.disko.devices.zpool.files.datasets.root.mountpoint}/personal";
    fsType = "nfs";
    options = [ "x-systemd.automount" "exec" ];
  };
}
