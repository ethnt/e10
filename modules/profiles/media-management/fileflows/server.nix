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
      inherit (config.services.fileflows.server) port;
      proxy = {
        enable = true;
        domain = "fileflows.e10.camp";
        protected = true;
      };
    };
  };
}
