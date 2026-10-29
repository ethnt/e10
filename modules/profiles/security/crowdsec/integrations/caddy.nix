{ config, ... }: {
  services.crowdsec = {
    readOnlyPaths = [ config.services.caddy.logDir ];
    hub.collections = [ "crowdsecurity/caddy" ];
    settings = {
      acquisitions = [
        {
          filenames = [ "${config.services.caddy.logDir}/access-*.log" ];
          labels.type = "caddy";
        }
      ];
    };
  };
}
