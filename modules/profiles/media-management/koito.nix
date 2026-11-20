{
  services.koito = {
    enable = true;
    environment = {
      KOITO_BIND_ADDR = "0.0.0.0";
    };
    openFirewall = true;
  };
}
