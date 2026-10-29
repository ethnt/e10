{
  services.crowdsec-firewall-bouncer = {
    enable = true;
    registerBouncer.enable = false; # Enabled on the host profile
  };
}
