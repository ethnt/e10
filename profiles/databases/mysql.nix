{ pkgs, ... }: {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_108;
    settings = {
      mysqld = {
        bind-address = "0.0.0.0";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3306 ];
}
