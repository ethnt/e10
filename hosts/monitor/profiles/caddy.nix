{ flake, lib, hosts, ... }: {
  services.caddy = {
    virtualHosts = flake.lib.provides.caddyVirtualHostsForServices hosts.monitor
      (flake.lib.provides.allHTTPServices
        (flake.lib.provides.allServicesForHosts
          (lib.filterAttrs (name: _value: name == "monitor")
            flake.nixosConfigurations)));
  };
}
