{ profiles }: {
  core = [
    profiles.core.common
    profiles.core.nix-config
    profiles.core.sops
    profiles.core.tooling
    profiles.networking.openssh
    profiles.shell.fish
    profiles.users.root
    profiles.networking.tailscale.default
    profiles.monitoring.prometheus-node-exporter
  ];

  web = [ profiles.web-servers.caddy ];

  monitor =
    [ profiles.monitoring.prometheus profiles.monitoring.grafana.default ];

  minimal = [
    profiles.core.common
    profiles.core.nix-config
    profiles.core.tooling
    profiles.networking.openssh
    profiles.shell.fish
    profiles.users.root
  ];
}
