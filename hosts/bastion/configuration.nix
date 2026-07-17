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
    ++ aws
    ++ web
    ++ (with profiles; [ security.lldap.default ])
    ++ [
      ./profiles/authelia
      ./profiles/caddy
    ]
    ++ [ secrets.hosts.bastion.configuration ];

  deployment = {
    vmType = "aws-ec2";
    tags = [ "@external" ];
  };

  system.stateVersion = "25.05";
}
