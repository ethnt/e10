{ suites, profiles, ... }: {
  imports = with suites;
    core ++ aws ++ web
    ++ [ profiles.security.authelia.default profiles.security.lldap.default ]
    ++ [ ./profiles/caddy ];

  deployment.tags = [ "@external" ];

  system.stateVersion = "24.05";
}
