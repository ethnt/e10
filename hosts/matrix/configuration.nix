{ lib, suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.databases.postgresql.default
      profiles.emulation.aarch64-linux
      profiles.filesystems.blockbuster
      profiles.filesystems.files.services
      profiles.hardware.intel
      profiles.media-management.fileflows.node
      profiles.media-management.immich
      profiles.networking.printing
      profiles.power.tripp-lite-smart1500lcd
      profiles.services.attic-watch-store.default
      profiles.services.change-detection.default
      profiles.services.e10-land
      profiles.services.glance.default
      profiles.services.miniflux.default
      profiles.services.netbox.default
      profiles.services.opengist.default
      profiles.services.paperless.default
      profiles.telemetry.prometheus-nut-exporter
      profiles.virtualisation.docker
      profiles.web-servers.caddy
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  satan.address = "10.10.3.101";

  deployment = {
    buildOnTarget = true;
    tags = [ "@vm" "@build-on-target" ];
  };

  networking = {
    useDHCP = false;

    nameservers = [ "10.10.0.1" ];

    vlans.vlan10 = {
      id = 10;
      interface = "ens18";
    };

    interfaces = {
      vlan10.ipv4 = {
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.10.0.1";
          options.src = "10.10.3.101";
          options.onlink = "";
        }];
        addresses = [{
          address = "10.10.3.101";
          prefixLength = 24;
        }];
      };
    };
  };

  services.fileflows-node.enableIntelQuickSync = true;

  services.borgmatic.configurations.system.source_directories =
    lib.mkAfter [ "/var/www" ];

  system.stateVersion = "24.05";
}
