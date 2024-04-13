{
  services.openssh = {
    enable = true;
    extraConfig = ''
      Match Address 192.168.0.0/16,100.0.0.0/8
        PermitRootLogin yes
      Match Address 0.0.0.0/0
        PermitRootLogin yes
    '';
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
