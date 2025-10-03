{ config, pkgs, ... }: {
  sops.secrets = {
    garage_rpc_secret = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0600";
      owner = config.users.users.garage.name;
    };

    garage_admin_token = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0600";
      owner = config.users.users.garage.name;
    };
  };

  users = {
    users.garage = {
      group = config.users.groups.garage.name;
      isSystemUser = true;
    };

    groups.garage = { };
  };

  systemd.tmpfiles.rules = [
    "d '${config.services.garage.settings.data_dir}' 0777 ${config.users.users.garage.name} ${config.users.groups.garage.name} - -"
  ];

  systemd.services.garage = {
    serviceConfig = {
      ReadWriteDirectories = [ config.services.garage.settings.data_dir ];
      DynamicUser = false;
      User = config.users.users.garage.name;
      Group = config.users.groups.garage.name;
    };
  };

  services.garage = {
    enable = true;
    package = pkgs.garage_1;
    settings = {
      metadata_dir = "/var/lib/garage/meta";
      data_dir = "/data/files/services/garage";
      db_engine = "sqlite";

      replication_factor = 1;

      rpc_bind_addr = "0.0.0.0:3901";
      rpc_secret_file = config.sops.secrets.garage_rpc_secret.path;

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "0.0.0.0:3900";
        root_domain = ".s3.garage.e10.camp";
      };

      s3_web = {
        bind_addr = "0.0.0.0:3902";
        root_domain = ".web.garage.e10.camp";
        index = "index.html";
      };

      admin = {
        api_bind_addr = "0.0.0.0:3903";
        admin_token_file = config.sops.secrets.garage_admin_token.path;
      };
    };
  };

  networking.firewall = { allowedTCPPorts = [ 3900 3901 3902 3903 ]; };
}
