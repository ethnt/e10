{
  suites,
  profiles,
  secrets,
  ...
}:
{
  imports =
    with suites;
    core
    ++ hcloud
    ++ web
    ++ public
    ++ (with profiles; [
      security.lldap.default
    ])
    ++ [
      ./profiles/authelia/default.nix
      ./profiles/caddy/default.nix
      ./profiles/crowdsec/default.nix
    ]
    ++ [
      ./disk-config.nix
      ./hardware-configuration.nix
    ]
    ++ [ secrets.hosts.gateway.configuration ];

  deployment = {
    vmType = "hcloud";
    tags = [ "@external" ];
  };

  system.stateVersion = "26.05";
}
