{ config, ... }: {
  sops.secrets.postfix_sasl_password = {
    owner = config.services.postfix.user;
    sopsFile = ./secrets.yml;
    format = "yaml";
  };

  services.postfix = {
    enable = true;
    relayHost = "email-smtp.us-east-2.amazonaws.com";
    relayPort = 587;
    config = {
      smtp_use_tls = "yes";
      smtp_sas_auth_enable = "yes";
      smtp_sasl_security_options = "";
      smtp_sasl_password_maps =
        "texthash:${config.sops.secrets.postfix_sasl_password.path}";
    };
  };
}
