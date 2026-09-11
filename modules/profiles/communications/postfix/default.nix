{ config, ... }: {
  sops = {
    secrets = {
      postfix_smtp2go_username = {
        owner = config.services.postfix.user;
        sopsFile = ./secrets.yml;
        format = "yaml";
      };
      postfix_smtp2go_password = {
        owner = config.services.postfix.user;
        sopsFile = ./secrets.yml;
        format = "yaml";
      };
    };

    templates.postfix_sasl_password_maps = {
      content = ''
        [mail.smtp2go.com]:2525 ${config.sops.placeholder.postfix_smtp2go_username}:${config.sops.placeholder.postfix_smtp2go_password}
      '';
      owner = config.services.postfix.user;
    };
  };

  services.postfix = {
    enable = true;
    settings = {
      main = {
        relayhost = [ "[mail.smtp2go.com]:2525" ];
        smtp_tls_security_level = "encrypt";
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_password_maps = "texthash:${config.sops.templates.postfix_sasl_password_maps.path}";
      };
    };
    setSendmail = true;
  };
}
