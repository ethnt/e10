{
  services.resolved = {
    enable = true;
    settings.Resolve = {
      Domains = [ "~." ];
      FallbackDNS = [ "1.1.1.1" ];
    };
  };
}
