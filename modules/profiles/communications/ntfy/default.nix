{ config, ... }: {
  sops.secrets = {
    ntfy_admin_password.sopsFile = ./secrets.json;
    ntfy_grafana_password.sopsFile = ./secrets.json;
    ntfy_nut_password.sopsFile = ./secrets.json;
  };

  services.ntfy-sh = {
    enable = true;
    baseUrl = "https://ntfy.e10.camp";
    auth = {
      enable = true;
      admin = {
        username = "admin";
        passwordFile = config.sops.secrets.ntfy_admin_password.path;
      };
      extraUsers = [
        {
          username = "grafana";
          passwordFile = config.sops.secrets.ntfy_grafana_password.path;
          grants = [
            {
              topic = "grafana-alerts";
              access = "read-write";
            }
          ];
        }
        {
          username = "nut";
          passwordFile = config.sops.secrets.ntfy_nut_password.path;
          grants = [
            {
              topic = "nut-alerts";
              access = "read-write";
            }
          ];
        }
      ];
    };
  };
}
