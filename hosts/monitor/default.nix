{ config, suites, profiles, lib, ... }: {
  imports = with suites;
    base ++ network ++ aws ++ observability ++ web ++ (with profiles; [
      monitoring.prometheus
      monitoring.grafana
      monitoring.loki
      monitoring.rsyslogd
    ]);

  e10 = {
    privateAddress = config.services.nebula.networks.e10.address;
    publicAddress = "18.219.39.43";
    domain = "monitor.e10.network";
    deployable = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      nebula_host_key = { };
      nebula_host_cert = { };
    };
  };

  services.nebula.networks.e10 = {
    address = "10.10.0.2";
    key = config.sops.secrets.nebula_host_key.path;
    cert = config.sops.secrets.nebula_host_cert.path;
  };

  services.promtail.configuration.scrape_configs = lib.mkAfter [{
    job_name = "syslog";
    syslog = {
      listen_address = "0.0.0.0:1514";
      labels = { job = "syslog"; };
    };
    relabel_configs = [
      {
        source_labels = [ "__syslog_message_hostname" ];
        target_label = "host";
      }
      {
        source_labels = [ "__syslog_message_hostname" ];
        target_label = "hostname";
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

  networking.hostName = "monitor";
}
