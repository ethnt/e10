{ config, ... }: {
  services.crowdsec = {
    enable = true;
    autoUpdateService = true;
    hub = {
      collections = [
        "crowdsecurity/linux"
        "crowdsecurity/iptables"
        "crowdsecurity/auditd"
        "crowdsecurity/sshd"
      ];
    };
    settings = {
      config.api.client.credentials_path = config.sops.templates.crowdsec_lapi_credentials.path;

      postOverflows.s01Whitelist = [
        {
          name = "custom/network-external-ip";
          description = "Whitelist network external IP";
          whitelist = {
            reason = "Trusted IP";
            expression = [ ''evt.Overflow.Alert.Source.IP in LookupHost("home.e10.network")'' ];
          };
        }
      ];

      parsers.s02Enrich = [
        {
          name = "custom/tailnet-whitelist";
          description = "Whitelist trusted tailnet subnets";
          whitelist = {
            reason = "Trusted tailnet peer";
            cidr = [
              "100.64.0.0/10"
              "fd7a:115c:a1e0::/48"
            ];
          };
        }
      ];

      acquisitions = [
        {
          source = "journalctl";
          journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
          labels.type = "syslog";
        }
      ];
    };
  };
}
