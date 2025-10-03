{ pkgs, lib, ... }: {
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
    };
  };

  virtualisation.oci-containers.backend = "docker";

  systemd.timers.docker-update-containers = {
    timerConfig = {
      unit = "docker-update-containers";
      OnCalendar = "Mon 02:00";
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.services.docker-update-containers = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let docker = lib.getExe pkgs.docker;
      in lib.getExe (pkgs.writeShellScriptBin "docker-update-containers" ''
        images=$(${docker} ps -a --format="{{.Image}}" | sort -u)

        for image in $images; do
          ${docker} pull "$image"
        done
      '');
    };
  };
}
