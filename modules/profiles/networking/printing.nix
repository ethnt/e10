{ pkgs, ... }: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [ brlaser ];
    browsing = true;
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    defaultShared = true;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_HL-L2300D";
        location = "Office";
        deviceUri = "usb://Brother/HL-L2300D%20series?serial=U63878H0N332161";
        model = "drv:///brlaser.drv/brl2300d.ppd";
      }
    ];
    ensureDefaultPrinter = "Brother_HL-L2300D";
  };

  networking.firewall = {
    allowedUDPPorts = [ 631 ];
    allowedTCPPorts = [ 631 ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    settings = {
      server = {
        allow-interfaces = [
          "ens18"
          "vlan10"
        ];
        deny-interfaces = [
          "docker0"
          "veth*"
        ];
      };
      publish = {
        publish-domain = true;
        publish-workstation = true;
        publish-hinfo = true;
        publish-addresses = true;
        disable-user-service-publishing = false;
        disable-publishing = false;
      };
    };
  };
}
