{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
      host all all 10.10.0.0/24 trust
    '';
  };

  networking.firewall = { allowedTCPPorts = [ 5432 ]; };
}
