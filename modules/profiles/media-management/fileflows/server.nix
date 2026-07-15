{ pkgs, ... }: {
  services.fileflows.server = {
    enable = true;
    extraPkgs = with pkgs; [ ffmpeg-full ];
    libraryDirs = [ "/mnt/blockbuster/media" ];
    openFirewall = true;
  };

  systemd.services.fileflows-server.environment = {
    CUDA_DEVICE_ORDER = "PCI_BUS_ID";
    CUDA_VISIBLE_DEVICES = "0"; # P4000
  };
}
