{ config, pkgs, ... }: {
  sops.secrets = {
    netbox_secret_key = {
      sopsFile = ./secrets.json;
      owner = "netbox";
    };
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox_3_7;
    settings = {
      CSRF_TRUSTED_ORIGINS = [
        "https://netbox.e10.camp"
        "http://${config.networking.hostName}:8001"
        "http://${config.networking.hostName}:8002"
      ];
    };
    secretKeyFile = config.sops.secrets.netbox_secret_key.path;
    listenAddress = "0.0.0.0";
  };

  services.nginx.group = "netbox";
  services.nginx.virtualHosts = {
    "netbox.e10.camp" = {
      listen = [{
        addr = "0.0.0.0";
        port = 8002;
      }];

      locations."/".proxyPass =
        "http://localhost:${toString config.services.netbox.port}";
      locations."/static".root = "${config.services.netbox.dataDir}";
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.netbox.port 8002 ];
}
