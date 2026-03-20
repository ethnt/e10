{ flake, config, lib, ... }: {
  services.caddy = {
    virtualHosts = flake.lib.provides.caddyVirtualHostsForServices config
      (flake.lib.provides.allHTTPServices (flake.lib.provides.allServices
        (lib.filterAttrs (name: _value: name == "monitor")
          flake.nixosConfigurations)));
  };
}
