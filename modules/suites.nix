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
  ];

  web = [ profiles.web-servers.caddy ];
}
