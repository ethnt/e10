{ pkgs, ... }: {
  services.subgen = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9444;
    modelPackage = pkgs.faster-whisper-medium;
    openFirewall = true;
  };
}
