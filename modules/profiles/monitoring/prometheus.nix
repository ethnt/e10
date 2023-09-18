{
  services.prometheus = {
    enable = true;
    extraFlags = [ "--web.enable-admin-api" ];
  };
}
