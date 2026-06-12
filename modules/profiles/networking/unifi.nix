{ config, ... }: {
  services.unifi-os-server = {
    enable = true;
    uosSystemIP =
      (builtins.head config.networking.interfaces.ens18.ipv4.addresses).address;
    openFirewallUiPort = true;
    openFirewallServicePorts = true;
  };

  # networking.firewall = {
  #   allowedTCPPorts = [ 6789 8080 8880 8443 8843 ];
  #   allowedUDPPorts = [ 8443 ];
  # };
}
