{ config, pkgs, ... }: {
  sops.secrets = { tailscale_auth_key = { sopsFile = ./secrets.json; }; };

  services.tailscale = { enable = true; };

  systemd.services.tailscale-autoconnect = {
    description = "Automatically connect to Tailscale";

    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = let
      tailscale = pkgs.lib.getExe pkgs.tailscale;
      jq = pkgs.lib.getExe pkgs.jq;
    in ''
        sleep 2

        status="$(${tailscale} status -json | ${jq} -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale} up -authkey $(cat ${config.sops.secrets.tailscale_auth_key.path})
    '';

  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
