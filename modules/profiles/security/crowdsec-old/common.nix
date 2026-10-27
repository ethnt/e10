{
  config,
  hosts,
  lib,
  ...
}:
let
  cfg = config.services.crowdsec;

  # Parses a port from an address (e.g., `0.0.0.0:8180` -> `8180`)
  portFromAddress = addr: lib.lists.last (lib.strings.splitString ":" addr);

  lapiUrl =
    if cfg.settings.config.api.server.enable then
      "http://127.0.0.1:${portFromAddress cfg.settings.config.api.server.listen_uri}"
    else
      let
        server = hosts.controller.config;
      in
      "http://${server.networking.hostName}:${portFromAddress server.services.crowdsec.settings.config.api.server.listen_uri}";
in
{
  sops = {
    secrets = {
      crowdsec_lapi_password = {
        sopsFile = ./secrets.json;
        key = "crowdsec_lapi_password_${config.networking.hostName}";
        owner = cfg.user;
        inherit (cfg) group;
      };
    };

    templates = {
      crowdsec_lapi_credentials = {
        content = ''
          url: ${lapiUrl}
          login: ${config.networking.hostName}
          password: ${config.sops.placeholder.crowdsec_lapi_password}
        '';
        owner = cfg.user;
        inherit (cfg) group;
      };
    };
  };

  services.crowdsec = {
    enable = true;
    autoUpdateService = true;
    readOnlyPaths = lib.optionals config.services.caddy.enable [ config.services.caddy.logDir ];
    hub = {
      collections = [
        "crowdsecurity/linux"
        "crowdsecurity/iptables"
        "crowdsecurity/auditd"
        "crowdsecurity/sshd"
      ]
      ++ lib.optionals config.services.caddy.enable [ "crowdsecurity/caddy" ];
    };
    settings = {
      config.api.client.credentials_path = config.sops.templates.crowdsec_lapi_credentials.path;

      parsers.s02Enrich = [
        {
          name = "custom/tailnet-whitelist";
          description = "Whitelist trusted tailnet subnets";
          whitelist = {
            reason = "Trusted tailnet peer";
            cidr = [
              "100.64.0.0/10"
              "fd7a:115c:a1e0::/48"
            ];
          };
        }
      ];

      acquisitions = [
        {
          source = "journalctl";
          journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
          labels.type = "syslog";
        }
      ]
      ++ lib.optionals config.services.caddy.enable [
        {
          filenames = [ "${config.services.caddy.logDir}/access-*.log" ];
          labels.type = "caddy";
        }
      ];
    };
  };
}
