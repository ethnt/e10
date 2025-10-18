{ suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.filesystems.blockbuster
      profiles.hardware.nvidia
      profiles.media-management.bazarr.default
      # profiles.media-management.fileflows.server
      profiles.media-management.huntarr
      profiles.media-management.jellyseerr
      profiles.media-management.plex
      profiles.media-management.profilarr
      profiles.media-management.prowlarr.default
      profiles.media-management.radarr.default
      profiles.media-management.sabnzbd.default
      profiles.media-management.sonarr.default
      profiles.media-management.tautulli
      profiles.media-management.wizarr
      profiles.services.attic-watch-store.default
      profiles.sharing.nfs-client
      profiles.telemetry.prometheus-dcgm-exporter
      profiles.telemetry.prometheus-plex-media-server-exporter.default
      profiles.virtualisation.docker
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  deployment = {
    tags = [ "@vm" "@build-on-target" ];
    buildOnTarget = true;
  };

  satan.address = "10.10.2.101";

  boot.kernel.sysctl."kernel.sysrq" = 502;

  networking = {
    useDHCP = false;
    nameservers = [ "10.10.0.1" ];

    vlans.vlan10 = {
      id = 10;
      interface = "enp6s18";
    };

    interfaces = {
      vlan10.ipv4 = {
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.10.0.1";
          options.src = "10.10.2.101";
          options.onlink = "";
        }];
        addresses = [{
          address = "10.10.2.101";
          prefixLength = 24;
        }];
      };
    };
  };

  services.borgmatic.configurations.system.exclude_patterns =
    [ "/var/lib/sabnzbd/downloads" "/var/lib/plex/transcodes" ];

  system.stateVersion = "24.05";
}
