{ lib }:
lib.makeExtensible (self: {
  # Filters hosts by if they are allowed to be deployed or not
  deployableHosts = lib.filterAttrs (name: cfg: cfg.config.e10.deployable);

  # Includes the SSH key automatically for deploy nodes
  mkDeployNode = { hostname }: {
    inherit hostname;
    sshUser = "root";
    sshOpts = [ "-F" "${../config/ssh_config}" ];
  };
})
