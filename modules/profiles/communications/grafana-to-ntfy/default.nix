{ config, ... }: {
  sops.secrets = {
    grafana_to_ntfy_ntfy_bauth_pass = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    grafana_to_ntfy_bauth_pass = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };
  };

  services.grafana-to-ntfy = {
    enable = true;
    settings = {
      ntfyUrl = "https://ntfy.e10.camp/grafana-alerts";
      ntfyBAuthUser = "grafana";
      ntfyBAuthPass = config.sops.secrets.grafana_to_ntfy_ntfy_bauth_pass.path;
      bauthUser = "admin";
      bauthPass = config.sops.secrets.grafana_to_ntfy_bauth_pass.path;
    };
  };
}
