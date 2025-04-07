{
  services.caddy.virtualHosts = {
    "http://e10.land:8090" = {
      extraConfig = ''
        file_server browse
        root * /var/www/e10.land/
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];
}
