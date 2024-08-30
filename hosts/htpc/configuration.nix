{ suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.hardware.nvidia
      profiles.sharing.nfs-client
      profiles.virtualisation.podman
      profiles.filesystems.blockbuster
      profiles.media-management.bazarr
      profiles.media-management.overseerr
      profiles.media-management.plex
      profiles.media-management.prowlarr
      profiles.media-management.radarr
      profiles.media-management.sabnzbd
      profiles.media-management.sonarr
      profiles.media-management.tautulli
      profiles.media-management.xteve
      profiles.media-management.fileflows
      profiles.media-management.recyclarr.default
      profiles.telemetry.prometheus-bazarr-exporter.default
      profiles.telemetry.prometheus-sonarr-exporter.default
      profiles.telemetry.prometheus-radarr-exporter.default
      profiles.telemetry.prometheus-prowlarr-exporter.default
      profiles.telemetry.prometheus-plex-media-server-exporter.default
      profiles.telemetry.prometheus-sabnzbd-exporter.default
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  deployment = {
    tags = [ "vm" ];
    buildOnTarget = true;
  };

  satan.address = "10.10.2.101";

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

  system.stateVersion = "23.11";
}
