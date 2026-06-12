{ config, ... }: {
  services.unifi-os-server = {
    enable = true;
    uosSystemIP =
      (builtins.head config.networking.interfaces.ens18.ipv4.addresses).address;
    openFirewallUiPort = true;
    openFirewallServicePorts = true;
  };
}
