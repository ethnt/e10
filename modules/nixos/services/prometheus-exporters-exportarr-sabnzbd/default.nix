{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.prometheus.exporters.exportarr-sabnzbd;

in {
  options.services.prometheus.exporters.exportarr-sabnzbd = {
    enable = mkEnableOption "Enable sabnzbd exportarr";

    url = mkOption { type = types.str; };

    port = mkOption {
      type = types.port;
      default = 9709;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.exportarr;
    };

    apiKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.prometheus-exportarr-sabnzbd-exporter = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      script = ''
        ${getExe cfg.package} sabnzbd --port ${
          toString cfg.port
        } --url ${cfg.url} --api-key-file ${cfg.apiKeyFile}
      '';
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
