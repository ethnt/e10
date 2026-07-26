{ config, ... }: {
  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_HOST = "0.0.0.0";
      SERVER_PORT = 8055;
      SECURITY_ENABLELOGIN = false; # Handled by Authelia
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.stirling-pdf.environment.SERVER_PORT ];
}
