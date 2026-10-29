{ pkgs, ... }: {
  services.caddy = {
    package =
      (pkgs.caddy.withPlugins {
        plugins = [ "github.com/hslatman/caddy-crowdsec-bouncer/http@v0.14.1" ];
        hash = "sha256-3zj9JZnjagY2AQfgcMSDLMSmUxQdZE8OSp8e50o1fiQ=";
      }).overrideAttrs
        {
          doInstallCheck = false;
        };

    # environmentFile = config.sops.templates.crowdsec_caddy_bouncer_environment_file.path;

    globalConfig = ''
      crowdsec {
        api_url http://monitor:8010
        api_key {env.CROWDSEC_API_KEY}
        ticker_interval 15s
      }

      order crowdsec first
    '';
  };
}
