{ pkgs, ... }: {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/mholt/caddy-ratelimit@v0.1.1-0.20250318145942-a8e9f68d7bed"
      ];
      hash = "sha256-fB4HuGbjK9df+rIv0eCMyDvLaISaEeINyjwz+H8lM3g=";
    };
    globalConfig = ''
      admin :2019 {
        origins 127.0.0.1 100.0.0.0/8
      }

      debug

      metrics

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

  services.promtail.configuration.scrape_configs = [{
    job_name = "caddy";
    static_configs = [{
      targets = [ "localhost" ];
      labels = {
        job = "caddy";
        __path__ = "/var/log/caddy/*log";
        agent = "caddy-promtail";
      };
    }];
    pipeline_stages = [
      {
        json = {
          expressions = {
            duration = "duration";
            status = "status";
          };
        };
      }
      {
        labels = {
          duration = null;
          status = null;
        };
      }
    ];
  }];
}

