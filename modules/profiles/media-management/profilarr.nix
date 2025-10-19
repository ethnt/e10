# { config, ... }: {
#   systemd.tmpfiles.settings = {
#     "10-profilarr" = {
#       "/var/lib/profilarr" = {
#         d = {
#           group = config.virtualisation.oci-containers.backend;
#           user = config.virtualisation.oci-containers.backend;
#           mode = "0777";
#         };
#       };
#     };
#   };

#   virtualisation.oci-containers.containers.profilarr = {
#     image = "santiagosayshey/profilarr:latest";
#     ports = [ "6868:6868" ];
#     volumes = [ "/var/lib/profilarr:/config" ];
#     environment.TZ = config.time.timeZone;
#   };

#   networking.firewall.allowedTCPPorts = [ 6868 ];
# }

{
  services.profilarr = {
    enable = true;
    openFirewall = true;
  };
}
