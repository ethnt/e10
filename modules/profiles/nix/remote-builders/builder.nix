{ config, hosts, ... }: {
  imports = [ ./common.nix ];

  sops.secrets = {
    builder_private_key = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0400";
    };
  };

  nix.buildMachines = [{
    inherit (hosts.builder.config.networking) hostName;

    system = "x86_64-linux";
    protocol = "ssh-ng";
    maxJobs = 8;
    speedFactor = 1;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
    sshUser = hosts.builder.config.users.users.builder.name;
    sshKey = config.sops.secrets.builder_private_key.path;
  }];

  nix.settings = { builders-use-substitutes = true; };
}
