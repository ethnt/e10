{ config, pkgs, ... }: {
  services.bentopdf = {
    enable = true;
    package = pkgs.bentopdf.overrideAttrs { SIMPLE_MODE = true; };
    openFirewall = true;
  };

  provides.bentopdf = {
    name = "BentoPDF";
    http = {
      inherit (config.services.bentopdf) port;
      proxy = {
        enable = true;
        domain = "pdf.e10.camp";
        protected = true;
      };
    };
  };
}
