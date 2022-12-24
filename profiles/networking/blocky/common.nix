{ config, pkgs, lib, hosts, ... }: {
  services.blocky = {
    enable = true;
    settings = {
      httpPort = 4022;
      upstream = {
        default = [
          "https://one.one.one.one/dns-query"
          "https://dns10.quad9.net/dns-query"
          "https://dns-unfiltered.adguard.com/dns-query"
        ];
      };
      upstreamTimeout = "2s";
      bootstrapDns = "208.67.222.222";
      filtering.queryTypes = [ "AAAA" ];
      blocking = {
        downloadAttempts = 10;
        downloadCooldown = "2s";
        downloadTimeout = "4m";
        blackLists = {
          ads = [
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://abp.oisd.nl"
          ];
          development = [ ];
        };
        whiteLists = {
          development = let
            whitelist = pkgs.writeTextFile {
              name = "blocky-whitelist";
              text = ''
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
              '';
            };
          in [ whitelist ];
        };
        clientGroupsBlock = {
          default = [ "ads" ];
          "st-eturkeltaub2*" = [ "ads" "development" ];
        };
        processingConcurrency = 16;
      };
      caching = {
        prefetching = true;
        prefetchExpires = "2h";
        prefetchThreshold = 5;
        minTime = "2h";
        maxTime = "12h";
        maxItemsCount = 0;
      };
      prometheus = {
        enable = true;
        path = "/metrics";
      };
      redis = {
        address = "${hosts.matrix.config.services.redis.servers.blocky.bind}:${
            toString hosts.matrix.config.services.redis.servers.blocky.port
          }";
      };
      queryLog = {
        type = "postgresql";
        target = "postgres://blocky:blocky@localhost/blocky";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 4022 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
