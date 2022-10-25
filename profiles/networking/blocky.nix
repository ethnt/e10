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
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 4022 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
