{ config, ... }: {
  sops.secrets = {
    ntfy_admin_password.sopsFile = ./secrets.json;
    ntfy_grafana_password.sopsFile = ./secrets.json;
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
      ];
    };
    # settings = {
    #   # attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
    #   auth-default-access = "deny-all";
    #   auth-file = "/var/lib/ntfy-sh/user.db";
    #   # base-url = "https://ntfy.e10.camp";
    #   # behind-proxy = true;
    #   # cache-file = "/var/lib/ntfy-sh/cache-file.db";
    #   enable-login = true;

    #   # https://docs.ntfy.sh/config/#ios-instant-notifications
    #   # upstream-base-url = "https://ntfy.sh";
    # };
  };
}
