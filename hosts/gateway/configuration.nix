{ suites, profiles, ... }: {
  imports = with suites;
    core ++ aws ++ [
      profiles.security.acme
      profiles.web-servers.caddy
      # ./profiles/nginx
      ./profiles/caddy
      profiles.security.lldap.default
      profiles.security.authelia.default
      # profiles.security.authelia.postgresql
    ];

  # sops.secrets = {
  #   lego_route53_credentials = {
  #     sopsFile = ./profiles/caddy/secrets.yml;
  #     format = "yaml";
  #   };
  # };

  # security.acme.defaults.environmentFile = config.sops.secrets.lego_route53_credentials.path;

  deployment.tags = [ "@external" ];

  system.stateVersion = "24.05";
}
