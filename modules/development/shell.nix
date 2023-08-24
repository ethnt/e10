{ inputs, ... }: {
  perSystem = { config, pkgs, inputs', self', ... }: {
    devenv.shells.default = _:
      {
        enterShell = let
          sops = pkgs.lib.getExe pkgs.sops;
          setSopsValueToEnvironmentVariable = key: ''
            export ${key}=$(${sops} -d --extract '["${key}"]' ./secrets.json)
          '';
        in ''
          ${setSopsValueToEnvironmentVariable "AWS_ACCESS_KEY_ID"}
          ${setSopsValueToEnvironmentVariable "AWS_SECRET_ACCESS_KEY"}
          ${setSopsValueToEnvironmentVariable "PM_API_TOKEN_ID"}
          ${setSopsValueToEnvironmentVariable "PM_API_TOKEN_SECRET"}
        '';

        packages = with pkgs;
          [
            config.treefmt.build.wrapper
            config.packages.tf

            statix
            sops
            terraform
          ] ++ (builtins.attrValues config.treefmt.build.programs);
      } // {
        containers = pkgs.lib.mkForce { };
      };
  };
}
