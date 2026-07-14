{
  config,
  lib,
  pkgs,
  hosts,
  ...
}:

let
  port = 9130;
in
{
  sops = {
    secrets.controller_unifi_os_api_key = {
      sopsFile = ./secrets.json;
      owner = "unpoller";
    };

    templates.unpoller_conf = {
      owner = "unpoller";
      group = "unpoller";
      mode = "0400";
      content = ''
        [poller]
        quiet = false
        debug = true

        [unifi.defaults]
        url = "https://controller:11443"
        api_key = "${config.sops.placeholder.controller_unifi_os_api_key}"
        sites = ["all"]
        save_sites = true
        save_dpi = false
        save_events = true
        save_alarms = true
        save_anomalies = true
        save_ids = true
        save_traffic = true
        save_rogue = true
        save_syslog = true
        save_protect_logs = false
        verify_ssl = false

        [prometheus]
        disable = false
        http_listen = "[::]:${toString port}"

        [influxdb]
        disable = true

        [loki]
        url = "http://${hosts.monitor.config.networking.hostName}:${toString hosts.monitor.config.services.loki.configuration.server.http_listen_port}"
      '';
    };

  };

  users.users = {
    unpoller = {
      group = "unpoller";
      isSystemUser = true;
      linger = true;
    };
  };

  users.groups = {
    unpoller = { };
  };

  systemd.services.unpoller = {
    description = "Export UniFi Network metrics";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "network-online.target"
      "sops-install-secrets.service"
    ];
    after = [
      "network-online.target"
      "sops-install-secrets.service"
    ];
    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.unpoller "unpoller"} --config ${config.sops.templates.unpoller_conf.path}";
      User = "unpoller";
      Group = "unpoller";
      Restart = "on-failure";
      RestartSec = "10s";
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
