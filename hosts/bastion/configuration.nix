{ suites, profiles, ... }: {
  imports = with suites;
    core ++ aws ++ web
    ++ (with profiles; [ security.authelia.default security.lldap.default ])
    ++ [ ./profiles/caddy ];

  deployment.tags = [ "@external" ];

  system.stateVersion = "25.05";
}
