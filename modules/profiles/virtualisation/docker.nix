{ pkgs, ... }: {
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_25;
  virtualisation.oci-containers.backend = "docker";
}
