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
        '';

        packages = with pkgs; [ statix sops ];
      } // {
        containers = pkgs.lib.mkForce { };
      };
  };
}
