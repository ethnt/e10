{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.bentopdf;
in {
  options.services.bentopdf = {
    enable = mkEnableOption "Enable bentopdf";

    package = mkPackageOption pkgs "bentopdf" {
      extraDescription = ''
        To use the "simple mode" variant of bentopdf, which removes all socials, marketing and explanatory texts,
        set this option to `pkgs.bentopdf.overrideAttrs { SIMPLE_MODE = true; }`
      '';
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "The host to listen on.";
    };

    port = mkOption {
      type = types.port;
      default = 4152;
      description = "The port nginx is listening on for bentopdf.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the port nginx is listening on for bentopdf.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      virtualHosts."bentopdf" = {
        listen = [{
          addr = cfg.host;
          inherit (cfg) port;
        }];

        root = cfg.package;

        locations."/".extraConfig = ''
          try_files $uri $uri/ /index.html;
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
        '';

        locations."~* .(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$".extraConfig =
          ''
            expires 1y;
            add_header Cache-Control "public, immutable";
          '';
      };
    };

    networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.port;
  };
}
