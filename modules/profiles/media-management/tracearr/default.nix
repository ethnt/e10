{ config, ... }: {
  sops = {
    secrets.maxmind_license_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    templates.tracearr_environment_file = {
      content = ''
        MAXMIND_LICENSE_KEY=${config.sops.placeholder.maxmind_license_key}
      '';
      mode = "0660";
    };
  };

  services.tracearr = {
    enable = true;
    openFirewall = true;
    environmentFile = config.sops.templates.tracearr_environment_file.path;
  };
}
