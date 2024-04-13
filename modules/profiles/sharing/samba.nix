{ config, pkgs, ... }: {
  services = {
    samba-wsdd.enable = true;

    samba = {
      enable = true;
      securityType = "user";
      extraConfig = ''
        workgroup = WORKGROUP
        server string = ${config.networking.hostName}
        netbios name = ${config.networking.hostName}
        security = user
        hosts allow = 192., 100., 10., localhost
        guest account = nobody
        map to guest = bad user
      '';
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
          </service-group>
        '';
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 445 139 5357 ];
    allowedUDPPorts = [ 137 138 3702 ];
  };

  environment.systemPackages = with pkgs; [ cifs-utils ];
}
