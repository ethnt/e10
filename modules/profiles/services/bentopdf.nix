{ config, pkgs, ... }: {
  services.bentopdf = {
    enable = true;
    package = pkgs.bentopdf.overrideAttrs { SIMPLE_MODE = true; };
    openFirewall = true;
  };

  provides.bentopdf = {
    name = "BentoPDF";
    http = {
      enable = true;
      inherit (config.services.bentopdf) port;
      domain = "pdf.e10.camp";
      protected = true;
    };
  };
}
