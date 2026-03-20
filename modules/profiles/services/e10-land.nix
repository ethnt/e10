let port = 8090;
in {
  services.caddy.virtualHosts = {
    "http://e10.land:${toString port}" = {
      extraConfig = ''
        file_server browse
        root * /var/www/e10.land/
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];

  provides.e10-land = {
    name = "e10.land";
    http = {
      inherit port;
      proxy = {
        enable = true;
        domain = "e10.land";
        extraVirtualHostConfig = ''
          encode gzip zstd
        '';
      };
    };
  };
}
