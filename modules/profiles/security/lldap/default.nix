{ config, ... }: {
  imports = [ ./postgresql.nix ];

  sops.secrets = {
    lldap_key_seed = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    lldap_jwt_secret = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    lldap_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      group = "ldap";
    };
  };

  services.lldap = {
    enable = true;
    settings = {
      http_url = "https://ldap.e10.camp";
      ldap_base_dn = "dc=e10,dc=camp";
      ldap_user_email = "admin@e10.camp";
      database_url = "postgresql://lldap@localhost/lldap?host=/run/postgresql";
      force_ldap_user_pass_reset = true;
    };
    environment = {
      LLDAP_KEY_SEED = "%d/key-seed";
      LLDAP_KEY_FILE = "";
      LLDAP_JWT_SECRET_FILE = "%d/jwt-secret";
      LLDAP_LDAP_USER_PASS_FILE = "%d/password";
    };
  };

  systemd.services.lldap = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];

    serviceConfig.LoadCredential = [
      "key-seed:${config.sops.secrets.lldap_key_seed.path}"
      "jwt-secret:${config.sops.secrets.lldap_jwt_secret.path}"
      "password:${config.sops.secrets.lldap_password.path}"
    ];
  };

  users.groups.ldap = { gid = 979; };
}
