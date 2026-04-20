{ pkgs, ... }: {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/mholt/caddy-ratelimit@v0.1.1-0.20250318145942-a8e9f68d7bed"
      ];
      hash = "sha256-aHIvnWU/PGspL/aDCTLkenl3IVZfd5H9NljJaEUAmH0=";
    };
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
