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
        upsmon = "primary";
        passwordFile = config.sops.secrets.upsmon_password.path;
        actions = [ "SET" "FSD" ];
        instcmds = [ "ALL" ];
      };

      follower = {
        upsmon = "secondary";
        passwordFile = config.sops.secrets.upsmon_password.path;
      };
    };
  };
}
