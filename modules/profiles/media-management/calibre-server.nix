{
  services.calibre-server = {
    enable = true;
    port = 8081;
    openFirewall = true;
    libraries = [ "/mnt/blockbuster/media/books" ];
    auth = {
      enable = true;
      userDb = "/var/lib/calibre-server/users.sqlite";
    };
  };
}
