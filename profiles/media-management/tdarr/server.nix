{ config, ... }: {
  services.tdarr.server = {
    enable = true;
    extraVolumes = [ "/mnt/omnibus:/mnt/omnibus" ];
    openFirewall = true;
  };
}
