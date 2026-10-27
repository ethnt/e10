{ config, lib, pkgs, ... }: {
  # Run the bouncer on every virtual host
  options.services.caddy.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config.extraConfig = lib.mkBefore ''
          crowdsec
        '';
      }
    );
  };

  config = lib.mkIf config.services.caddy.enable {
    sops.templates.crowdsec_caddy_bouncer_environment_file = {
      content = ''
        CROWDSEC_API_KEY=${config.sops.placeholder.crowdsec_caddy_bouncer_api_key}
      '';
    };

    services.caddy = {
      package =
        (pkgs.caddy.withPlugins {
          plugins = [ "github.com/hslatman/caddy-crowdsec-bouncer/http@v0.14.1" ];
          hash = "sha256-3zj9JZnjagY2AQfgcMSDLMSmUxQdZE8OSp8e50o1fiQ=";
        }).overrideAttrs
          {
            doInstallCheck = false;
          };

      environmentFile = config.sops.templates.crowdsec_caddy_bouncer_environment_file.path;

      globalConfig = ''
        crowdsec {
          api_url http://controller:8180
          api_key {env.CROWDSEC_API_KEY}
          ticker_interval 15s
        }

        order crowdsec first
      '';
    };
  };
}
