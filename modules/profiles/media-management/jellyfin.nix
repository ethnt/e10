{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  provides.jellyfin = {
    name = "Jellyfin";
    http = {
      enable = true;
      port = 8096;
      domain = "jellyfin.e10.video";
      extraVirtualHostConfig = ''
        encode gzip zstd

        request_body {
          max_size 100MiB
        }
      '';
    };
  };
}
