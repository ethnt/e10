{ suites, profiles, ... }: {
  imports =
    with suites;
    core
    ++ hcloud
    ++ web
    ++ (with profiles; [
      security.lldap.default
    ])
    ++ [
      ./profiles/authelia/default.nix
      ./profiles/caddy/default.nix
    ]
    ++ [
      ./disk-config.nix
      ./hardware-configuration.nix
    ];

  deployment = {
    vmType = "hcloud";
    tags = [ "@external" ];
  };

  system.stateVersion = "26.05";
}
