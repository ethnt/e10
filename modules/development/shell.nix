{ inputs, ... }: {
  imports = [ inputs.devenv.flakeModule ];

  perSystem = { pkgs, ... }: {
    devenv.shells.default = _:
      {
        # TODO: Move this to be within the `keys/` directory?
        env.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";

        enterShell = let
          sops = pkgs.lib.getExe' pkgs.sops "sops";
          setSopsValueToEnvironmentVariable = key: secretsFile: ''
            export ${key}=$(${sops} -d --extract '["${key}"]' ${secretsFile})
          '';
        in ''
          export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

          ${setSopsValueToEnvironmentVariable "AWS_ACCESS_KEY_ID"
          "./secrets.json"}
          ${setSopsValueToEnvironmentVariable "AWS_SECRET_ACCESS_KEY"
          "./secrets.json"}

          export TAILSCALE_AUTH_KEY=$(${sops} -d --extract '["tailscale_auth_key"]' ./modules/profiles/networking/tailscale/secrets.json)
        '';

        packages = with pkgs; [ cachix deadnix just statix sops ];
      } // {
        containers = pkgs.lib.mkForce { };
      };
  };
}
