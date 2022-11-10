{
  services.nginx.virtualHosts = {
    "e10.land" = {
      listen = [{
        addr = "0.0.0.0";
        port = 8090;
      }];

      locations."/" = {
        root = "/var/www/e10.land";
        extraConfig = ''
          autoindex on;
          fancyindex on;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];
}
