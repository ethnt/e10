{
  services.speedtest-tracker = {
    enable = true;
    schedule = "5 * * * *";
    servers = [ "30514" ];
    openFirewall = true;
  };
}
