{ config, ... }: {
  sops.secrets = {
    upsmon_password = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0400";
    };
  };

  power.ups = {
    enable = true;
    openFirewall = true;
    mode = "netserver";

    upsd = {
      listen = [{
        address = "0.0.0.0";
        port = 3493;
      }];
    };

    users = {
      leader = {
        upsmon = "master";
        passwordFile = config.sops.secrets.upsmon_password.path;
        actions = [ "SET" "FSD" ];
        instcmds = [ "ALL" ];
      };

      follower = {
        upsmon = "slave";
        passwordFile = config.sops.secrets.upsmon_password.path;
      };
    };
  };
}
