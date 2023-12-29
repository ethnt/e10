{ lib, ... }: {
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  services.tailscale.extraUpFlags =
    lib.mkAfter [ "--advertise-exit-node" "--advertise-routes=192.168.10.0/24" ];
}
