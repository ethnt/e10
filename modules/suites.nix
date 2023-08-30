{ profiles }: {
  core = [
    profiles.core.common
    profiles.core.nix-config
    profiles.core.sops
    profiles.core.tooling
    profiles.networking.openssh
    profiles.networking.mosh
    profiles.shell.fish
    profiles.users.root
    profiles.networking.tailscale.default
    profiles.security.fail2ban
    profiles.telemetry.prometheus-node-exporter
    profiles.telemetry.promtail
  ];

  web = [ profiles.web-servers.nginx ];

  minimal = [
    profiles.core.common
    profiles.core.nix-config
    profiles.core.tooling
    profiles.networking.openssh
    profiles.shell.fish
    profiles.users.root
  ];

  aws = [ profiles.virtualisation.aws profiles.networking.quad9 ];
}
