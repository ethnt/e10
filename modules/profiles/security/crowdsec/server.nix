{
  imports = [
    ./common.nix
    ./postgresql.nix
  ];

  services.crowdsec.settings = {
    config = {
      api.server = {
        listen_uri = "0.0.0.0:8010";
      };

      prometheus = {
        enabled = true;
        level = "full";
        listen_addr = "0.0.0.0";
        listen_port = 6010;
      };
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    6010
    8010
  ];
}
