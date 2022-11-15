{
  services.apcupsd = {
    enable = true;
    configText = ''
      UPSCABLE usb
      UPSTYPE usb
      DEVICE
      NETSERVER on
      NISIP 0.0.0.0
      BATTERYLEVEL 20
    '';
  };

  networking.firewall.allowedTCPPorts = [ 3551 ];
}
