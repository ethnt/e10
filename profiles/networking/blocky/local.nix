{
  services.blocky.settings = {
    clientLookup.upstream = "tcp+udp:192.168.1.1:5353";
    conditional = {
      mapping = {
        "168.192.in-addr.arpa" = "192.168.1.1:5353";
        "." = "192.168.1.1:5353";
      };
    };
    customDNS = {
      mapping = {
        pve = "192.168.1.200";
        omnibus = "192.168.1.201";
      };
    };
  };
}
