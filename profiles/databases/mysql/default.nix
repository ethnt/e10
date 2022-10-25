{ pkgs, ... }: {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_108;
    settings = { mysqld = { bind-address = "0.0.0.0"; }; };
    ensureDatabases = [ "blocky_external" "blocky_internal" ];
    initialScript = pkgs.writeText "mysql-initialScript" ''
      CREATE USER 'blocky'@'%' IDENTIFIED BY 'blocky';
      GRANT ALL PRIVILEGES ON *.* TO 'blocky'@'%';

      CREATE USER 'grafana'@'%' IDENTIFIED BY 'grafana';
      GRANT SELECT, REFERENCES ON *.* TO 'grafana'@'%';
    '';
  };

  networking.firewall.allowedTCPPorts = [ 3306 ];
}
