{ config, ... }: {
  sops = {
    secrets = {
      termix_oauth_secret = {
        sopsFile = ./secrets.yml;
        format = "yaml";
      };
    };

    templates.termix_environment_file = {
      content = ''
        OIDC_ENABLED=true
        OIDC_CLIENT_ID=BhZjM_kfrPU38DOigEa9HToE2XTdYsmSMOxUBmUOgxLkZr4xMB45u2E8QoJYlqe3hwJMReZy
        OIDC_CLIENT_SECRET=${config.sops.placeholder.termix_oauth_secret}
        OIDC_AUTHORIZATION_URL=https://auth.e10.camp/api/oidc/authorization
        OIDC_ISSUER_URL=https://auth.e10.camp
        OIDC_TOKEN_URL=https://auth.e10.camp/api/oidc/token
        OIDC_AUTO_REDIRECT=true
      '';
      mode = "0660";
    };
  };

  services.termix = {
    enable = true;
    environmentFile = config.sops.templates.termix_environment_file.path;
    openFirewall = true;
  };
}
