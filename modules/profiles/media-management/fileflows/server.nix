{ config, pkgs, ... }: {
  services.fileflows.server = {
    enable = true;
    extraPkgs = with pkgs; [ ffmpeg-full ];
    libraryDirs = [ "/mnt/blockbuster/media" ];
    openFirewall = true;
  };

  provides.fileflows = {
    name = "FileFlows";
    http = {
      enable = true;
      inherit (config.services.fileflows.server) port;
      domain = "fileflows.e10.camp";
      protected = true;
    };
  };
}
