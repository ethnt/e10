{ pkgs, ... }: {
  services.bentopdf = {
    enable = true;
    package = pkgs.bentopdf.overrideAttrs { SIMPLE_MODE = true; };
    openFirewall = true;
  };
}
