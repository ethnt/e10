{ pkgs, lib, ... }: {
  environment.systemPackages = [ pkgs.blocky ];

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
      customDNS = {
        mapping = {
          "anise.satan.network" = "10.10.1.0";
          "basil.satan.network" = "10.10.2.0";
          "cardamom.satan.network" = "10.10.3.0";
          "elderflower.satan.network" = "10.2.1.0";
        };
      };
      blocking = {
        loading = {
          downloads = {
            attempts = 5;
            cooldown = "2s";
            timeout = "30s";
          };
          concurrency = 16;
        };
        denylists = { ads = [ "https://big.oisd.nl/domainswild" ]; };
        allowlists = {
          ads = [
            (pkgs.writeText "ads-allowlist.txt" ''
              cdn.cookielaw.org
              l.food52.com
              link.dwell.com
            '')
          ];
        };
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
      clientLookup = {
        upstream = "192.168.1.1:5335";
        singleNameOrder = [ 1 2 ];
      };
      conditional = {
        mapping = let
          reverseDnsServer = "192.168.1.1:5335";
          addresses = [
            "arpa"
            "1.168.192.in-addr.arpa"
            "168.192.in-addr.arpa"
            "10.10.in-addr.arpa"
            "."
          ];
        in builtins.listToAttrs (map (name: {
          inherit name;
          value = reverseDnsServer;
        }) addresses);
      };
      prometheus = {
        enable = true;
        path = "/metrics";
      };
      ede.enable = true;
      ecs = {
        useAsClient = true;
        ipv4Mask = 32;
        ipv6Mask = 128;
      };
      queryLog.type = lib.mkDefault "console";
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 4022 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
