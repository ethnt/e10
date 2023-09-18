{ profiles }: {
  core = [
    profiles.core.common
    profiles.core.nix-config
    profiles.core.sops
    profiles.core.tooling
    profiles.core.cachix
    profiles.networking.openssh
    profiles.networking.mosh
    profiles.shell.fish
    profiles.users.root
    profiles.networking.tailscale.default
    profiles.security.fail2ban
    profiles.telemetry.prometheus-node-exporter
    profiles.telemetry.promtail
    profiles.backups.borg.default
    profiles.backups.borg.system
  ];

  web = [ profiles.web-servers.nginx ];

  minimal = [
    profiles.core.common
    profiles.core.nix-config
    profiles.core.tooling
    profiles.core.cachix
    profiles.networking.openssh
    profiles.shell.fish
    profiles.users.root
  ];

  homelab = [ profiles.networking.satan ];

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
