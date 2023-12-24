{ inputs, ... }: {
  imports = [ inputs.devenv.flakeModule ];

  perSystem = { pkgs, ... }: {
    devenv.shells.default = _:
      {
        # TODO: Move this to be within the `keys/` directory?
        env.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";

        enterShell = let
          sops = pkgs.lib.getExe' pkgs.sops "sops";
          setSopsValueToEnvironmentVariable = key: ''
            export ${key}=$(${sops} -d --extract '["${key}"]' ./secrets.json)
          '';
        in ''
          export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

          ${setSopsValueToEnvironmentVariable "AWS_ACCESS_KEY_ID"}
          ${setSopsValueToEnvironmentVariable "AWS_SECRET_ACCESS_KEY"}
        '';

        packages = with pkgs; [ cachix deadnix just statix sops ];
      } // {
        containers = pkgs.lib.mkForce { };
      };
  };
}
