{ config, lib, ... }: {
  sops.secrets = { tailscale_auth_key = { sopsFile = ./secrets.json; }; };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    useRoutingFeatures = lib.mkDefault "client";
    extraUpFlags = [ "--hostname=${config.networking.hostName}" "--reset" ];
    openFirewall = true;
  };

  networking = {
    nameservers = lib.mkBefore [ "100.100.100.100" ];

    firewall = {
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
