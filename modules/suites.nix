{ profiles }: {
  core = [
    profiles.backups.borgmatic.system
    profiles.core.caching
    profiles.core.common
    profiles.core.nix-config
    profiles.core.sops
    profiles.core.tooling
    profiles.networking.mosh
    profiles.networking.networkd
    profiles.networking.openssh
    profiles.networking.resolved
    profiles.networking.tailscale.default
    profiles.security.fail2ban
    profiles.shell.fish
    profiles.system.earlyoom
    profiles.telemetry.prometheus-borgmatic-exporter
    profiles.telemetry.prometheus-node-exporter
    profiles.telemetry.promtail
    profiles.users.root
  ];

  web = [ profiles.security.acme profiles.web-servers.caddy ];

  minimal = [
    profiles.core.common
    profiles.core.nix-config
    profiles.core.tooling
    profiles.core.caching
    profiles.networking.networkd
    profiles.networking.resolved
    profiles.networking.openssh
    profiles.shell.fish
    profiles.users.root
  ];

  # homelab = [ profiles.networking.satan ];

  nuc = [
    profiles.filesystems.hybrid-boot
    profiles.filesystems.zfs
    profiles.hardware.intel
    profiles.hardware.hidpi
    profiles.hardware.ssd
  ];

  aws = [ profiles.virtualisation.aws profiles.networking.quad9 ];

  proxmox-vm = [
    profiles.virtualisation.qemu
    profiles.filesystems.hybrid-boot
    profiles.filesystems.zfs
    profiles.hardware.intel
    profiles.hardware.hidpi
    profiles.hardware.ssd
  ];
}
