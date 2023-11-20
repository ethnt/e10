{
  services.rsyslogd = {
    enable = true;
    extraConfig = ''
      # https://www.rsyslog.com/doc/v8-stable/concepts/multi_ruleset.html#split-local-and-remote-logging
      ruleset(name="remote"){
        # https://www.rsyslog.com/doc/v8-stable/configuration/modules/omfwd.html
        # https://grafana.com/docs/loki/latest/clients/promtail/scraping/#rsyslog-output-configuration
        action(type="omfwd" Target="localhost" Port="1514" Protocol="tcp" Template="RSYSLOG_SyslogProtocol23Format" TCP_Framing="octet-counted")
      }

      # https://www.rsyslog.com/doc/v8-stable/configuration/modules/imudp.html
      module(load="imudp")
      input(type="imudp" port="514" ruleset="remote")

      # https://www.rsyslog.com/doc/v8-stable/configuration/modules/imtcp.html
      module(load="imtcp")
      input(type="imtcp" port="514" ruleset="remote")
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ 514 ];
    allowedUDPPorts = [ 514 ];
  };

  services.promtail.configuration.scrape_configs = [{
    job_name = "rsyslogd";
    syslog = {
      listen_address = "0.0.0.0:1514";
      labels = { job = "rsyslogd"; };
    };
    relabel_configs = [
      {
        source_labels = [ "__syslog_message_hostname" ];
        target_label = "host";
      }
      {
        source_labels = [ "__syslog_message_severity" ];
        target_label = "level";
      }
      {
        source_labels = [ "__syslog_message_app_name" ];
        target_label = "application";
      }
      {
        source_labels = [ "__syslog_message_facility" ];
        target_label = "facility";
      }
      {
        source_labels = [ "__syslog_connection_hostname" ];
        target_label = "connection_hostname";
      }
    ];
  }];
}
