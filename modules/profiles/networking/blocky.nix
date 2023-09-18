{ config, pkgs, ... }: {
  services.blocky = {
    enable = true;
    settings = {
      ports.http = 4022;
      upstreams = {
        groups = {
          default = [
            "https://one.one.one.one/dns-query"
            "https://dns10.quad9.net/dns-query"
            "https://dns-unfiltered.adguard.com/dns-query"
          ];
        };
        timeout = "10s";
      };
      bootstrapDns = "208.67.222.222";
      filtering.queryTypes = [ "AAAA" ];
      blocking = {
        loading.downloads = {
          attempts = 5;
          cooldown = "2s";
          timeout = "30s";
        };
        blackLists = {
          ads = [
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/multi.txt"
          ];
          development = [ ];
        };
        whiteLists = {
          development = [
            (pkgs.writeText "development.txt" ''
              analytics.google.com
              googleanalytics.com
              www.googleanalytics.com
              google-analytics.com
              www.google-analytics.com
              googletagmanager.com
              www.googletagmanager.com
              px.ads.linkedin.com
              ad.doubleclick.net
              munchkin.marketo.net
              stats.g.doubleclick.net
              p.adsymptotic.com
              adservice.google.com
            '')
          ];
        };
        clientGroupsBlock = {
          default = [ "ads" ];
          "st-eturkeltaub2*" = [ "ads" "development" ];
        };
        loading.concurrency = 16;
      };
      caching = {
        prefetching = true;
        prefetchExpires = "2h";
        prefetchThreshold = 5;
        minTime = "2h";
        maxTime = "12h";
        maxItemsCount = 0;
      };
      clientLookup = {
        upstream = "192.168.1.1:5335";
        singleNameOrder = [ 1 2 ];
      };
      conditional = {
        mapping = {
          "arpa" = "192.168.1.1:5335";
          "1.168.192.in-addr.arpa" = "192.168.1.1:5335";
          "168.192.in-addr.arpa" = "192.168.1.1:5335";
          "." = "192.168.1.1:5335";
        };
      };
      prometheus = {
        enable = true;
        path = "/metrics";
      };
      redis = {
        address = "${config.services.redis.servers.blocky.bind}:${
            toString config.services.redis.servers.blocky.port
          }";
      };
      ede.enable = true;
      queryLog = {
        type = "postgresql";
        target = "postgres://blocky?host=/run/postgresql";
        logRetentionDays = 90;
      };
    };
  };

  systemd.services.blocky = {
    after = [ "postgresql.service" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "1";
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 4022 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
