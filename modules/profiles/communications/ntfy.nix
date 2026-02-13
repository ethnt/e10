{
  # TODO: Provision user
  services.ntfy-sh = {
    enable = true;
    settings = {
      attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
      auth-default-access = "deny-all";
      auth-file = "/var/lib/ntfy-sh/user.db";
      base-url = "https://ntfy.e10.camp";
      behind-proxy = true;
      cache-file = "/var/lib/ntfy-sh/cache-file.db";
      enable-login = true;

      # https://docs.ntfy.sh/config/#ios-instant-notifications
      upstream-base-url = "https://ntfy.sh";
    };
  };

  provides.services.ntfy-sh = {
    name = "Ntfy";
    http = {
      port = 2586;
      proxy = {
        enable = true;
        domain = "ntfy.e10.camp";
        extraConfig = ''
          @httpget {
            protocol http
            method GET
            path_regexp ^/([-_a-z0-9]{0,64}$|docs/|static/)
          }

          redir @httpget https://{host}{uri}
        '';
      };
    };
  };
}
