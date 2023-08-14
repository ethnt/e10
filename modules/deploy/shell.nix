{ inputs, ... }: {
  perSystem = { config, pkgs, inputs', self', ... }: {
    devenv.shells.default = _: {
      env.SSH_CONFIG_FILE = ./ssh_config;
      packages = [ inputs'.colmena.packages.colmena ];
    };
  };
}
