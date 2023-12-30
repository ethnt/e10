{ config, ... }: {
  users.groups.builder = { };

  users.users.builder = {
    group = config.users.groups.builder.name;
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLar81/fqPHyNIq0wEpgXRhw5bVyb6TkYv8WcPBAwN8s/2wvs/tH0bGSfcdKvHk1mEJ1P6d7Bls4fp+FXWHJvPuSNPy6AgGd4drbGxaUWlluVtGdhu1qkaebqA4iEvRiUSVmroU3+xWNWx2dXya+1DWQGnOLBwrUJuQJCAeFg3qndvT7mExo5rY52jIsI/GD5nZQvIEiXa8HtbTzJTn3Qz0BQ6tCkwGQmLDOvsVpL4nnc4EXbiCuUuADdSNGFuScddXpRpDdCaddOtEORlLGqfrpXK0GI0+/DZVngshtIX+tB01giMmdE5IJmJ7bzoiGDoTaQQjA0qEYJq94tZx/6Z"
    ];
    extraGroups = [ "@wheel" ];
  };
}
