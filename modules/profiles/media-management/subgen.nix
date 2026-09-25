{ pkgs, ... }: {
  services.subgen = {
    enable = true;
    modelPackage = pkgs.faster-whisper-medium;
    transcribeDevice = "cuda";
    transcribeOrTranslate = "translate";
    listenAddress = "0.0.0.0";
    port = 9444;
    openFirewall = true;
  };
}
