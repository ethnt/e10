# TODO: Have a second instance locally and sync via Redis: https://0xerr0r.github.io/blocky/configuration/#redis
# TODO: TLS https://github.com/rafaelsgirao/dotfiles/blob/f5f6b8026d57ea1f70a5a563b94212b5fcdc5ac1/nixos/modules/blocky.nix#L128-L131

{ config, pkgs, lib, ... }: {
  services.blocky = {
    enable = true;
    settings = {
      httpPort = 4042;
      upstream = {
        default = [
          "https://dns10.quad9.net/dns-query"
          "https://one.one.one.one/dns-query"
          "https://dns-unfiltered.adguard.com/dns-query"
        ];
      };
      upstreamTimeout = "2s";
      bootstrapDns = "tcp+udp:1.1.1.1";
      blocking = {
        blackLists = { ads = [ "https://dbl.oisd.nl" ]; };
        clientGroupsBlock = { default = [ "ads" ]; };
      };
      caching = {
        prefetching = true;
        prefetchExpires = "2h";
        prefetchThreshold = 5;
        minTime = "2h";
        maxTime = "12h";
        maxItemsCount = 0;
      };
      customDNS = {
        mapping = {
          gateway = "10.10.0.1";
          monitor = "10.10.0.2";
          errata = "10.10.0.4";
        };
      };
      prometheus = {
        enable = true;
        path = "/metrics";
      };
      queryLog = {
        type = "mysql";
        target =
          "blocky@unix(/var/run/mysqld/mysqld.sock)/blocky?charset=utf8mb4&parseTime=True&loc=Local";
        logRetentionDays = 30;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 config.services.blocky.settings.httpPort ];
    allowedUDPPorts = [ 53 ];
  };

  users.groups.blocky = { };

  users.users.blocky = {
    isSystemUser = true;
    group = "blocky";
  };

  services.mysql = {
    ensureUsers = [{
      name = "blocky";
      ensurePermissions = { "blocky.*" = "ALL PRIVILEGES"; };
    }];
    ensureDatabases = [ "blocky" ];
    initialScript = pkgs.writeText "mysql-initialScript" ''
      CREATE USER 'grafana'@'%' IDENTIFIED BY 'grafana';
      GRANT SELECT, REFERENCES ON blocky.* TO 'grafana'@'%';
    '';
  };
}
