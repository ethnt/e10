{ config, ... }: {
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d '/data/local/tmp/plex/transcode' 0777 ${config.services.plex.user} ${config.services.plex.group} - -"
  ];

  provides.plex = {
    name = "Plex";
    http = {
      enable = true;
      inherit (config.services.plex) port;
      domain = "e10.video";
      extraVirtualHostConfig = ''
        encode gzip zstd

        header {
          Strict-Transport-Security max-age=31536000;
          X-Content-Type-Options nosniff
          X-Frame-Options DENY
          Referrer-Policy no-referrer-when-downgrade
          X-XSS-Protection 1
        }

        request_body {
          max_size 100MiB
        }
      '';
      extraReverseProxyConfig = ''
        header_up X-Real-IP {http.request.remote.host}

        transport http {
          read_buffer 0
          write_buffer 0
        }
      '';
    };
  };
}
