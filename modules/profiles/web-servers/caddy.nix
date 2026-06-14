{
  services.caddy = {
    enable = true;
    globalConfig = ''
      admin :2019 {
        origins 127.0.0.1 100.0.0.0/8
      }

      debug

      metrics {
        per_host
      }

      servers {
        trusted_proxies static private_ranges 100.0.0.0/8
      }
    '';
    email = "admin@e10.camp";
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 2019 ];
    allowedUDPPorts = [ 80 443 ];
  };
}
