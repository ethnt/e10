{ config, ... }: {
  users.groups.builder = { };

  users.users.builder = {
    group = config.users.groups.builder.name;
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDj/GdHYjewsfO1DnsFygbT/1hbjiUXX0wCnmXtbCk3VrjzUtrApSO0wV0WHh4mvBtlvIPmk4vA9RVz7Uy/o/0WvC+Mkv31uCJ2cEv8ojnMo9igXd6oHGc13cpqQcxY43lbBrw8JG4498FRRe2JE7SarbTGESxpVxXG3m57lalVvP2b7SQXD9i3LDGIiOQn9vTn4ieRp6C856geV0lTYHJ71rjiC+VsMbYw2njPUpmhBV089Ya2TuMCyXVlCgBOwpx9Wf7GTpDfGImJTb+3hroJIUTKozmR3BDTUrHtE3bzsOmjGRR3jrUO5dIpZKDO+uQOKAFdWh5D6ezK7xv7LghiL3MfJd5enzvBOme/yM31Tr55N6bww242wA2Kzy1DtEmITgRoCgrMoGxdN++fI0E0/jupXI96h0n/A+Hmm+AELe8+zHzYWejRK8LF62TfH6WidSYBmtb33MdG0kmU/UqU9AdMoiI/ULvkwTcUdnayQ7YJlJrcV4J3p/qcvh5vEqy1tvkT+Qs7vycsxDxibuY/eJOG4FOea0oQbP9MIrbNuyy+K/cPe7Pvp52zmITlT+mDWn0g0ax9JCyl2wVaoaWKg/hYnE6dsWAv2Pgh60QOAolXFriVY62Nj+8hm0jgjhqDBJrfgwHzy9iwPcLf1ywjwsNtdJb2hL9FnORe8g4mkQ== builder@e10.camp"
    ];
    extraGroups = [ "@wheel" ];
  };
}
