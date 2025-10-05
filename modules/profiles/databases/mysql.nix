{ pkgs, ... }: {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  networking.firewall.allowedTCPPorts = [ 3306 ];
}
