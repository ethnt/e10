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
      bootstrapDns = {
        upstream = "tcp-tls:dns10.quad9.net/dns-query";
        ips = [ "9.9.9.9" ];
      };
      clientLookup.upstream = "tcp+udp:192.168.1.1:5353";
      conditional = {
        mapping = {
          "168.192.in-addr.arpa" = "192.168.1.1:5353";
          "." = "192.168.1.1:5353";
        };
      };
      blocking = {
        blackLists = {
          ads = [
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://abp.oisd.nl"
          ];
        };
        clientGroupsBlock.default = [ "ads" ];
        processingConcurrency = 16;
      };
      customDNS = {
        mapping = {
          pve = "192.168.1.200";
          omnibus = "192.168.1.201";
        };
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
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 4022 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
