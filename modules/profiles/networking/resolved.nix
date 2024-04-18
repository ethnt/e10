{
  services.resolved = {
    enable = true;
    # dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1" ];
    # dnsovertls = "true";
  };
}
