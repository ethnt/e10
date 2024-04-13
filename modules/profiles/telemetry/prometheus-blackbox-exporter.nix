{ pkgs, ... }: {
  services.prometheus.exporters.blackbox = {
    enable = true;
    enableConfigCheck = true;
    openFirewall = true;
    configFile = pkgs.writeText "prometheus-blackbox-configuration.yml" ''
      modules:
        blocky:
          prober: dns
          timeout: 5s
          dns:
            query_name: ethan.haus
            query_type: A
    '';
  };
}
