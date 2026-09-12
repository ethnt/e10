{ suites, profiles, ... }: {
  imports =
    with suites;
    core
    ++ web
    ++ (with profiles; [
      security.lldap.default
      virtualisation.qemu
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
    targetHost = "5.161.98.131";
  };

  system.stateVersion = "26.05";
}
