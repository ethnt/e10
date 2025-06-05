_: {
  services.calibre-web = {
    enable = true;
    listen.ip = "0.0.0.0";
    options = {
      enableBookConversion = true;
      calibreLibrary = "/mnt/blockbuster/media/books";
      reverseProxyAuth.enable = true;
    };
    openFirewall = true;
  };
}
