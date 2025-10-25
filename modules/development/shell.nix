{ self, ... }: {
  perSystem = { pkgs, system, ... }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = let
        shellNames = [ "ansible" "deploy" "flake-root" "terraform" "treefmt" ];
      in map (shell: self.devShells.${system}.${shell}) shellNames;

      nativeBuildInputs = with pkgs; [
        attic-client
        authelia
        awscli2
        cachix
        deadnix
        just
        nix-output-monitor
        sops
        statix
      ];

      shellHook = let
        sops = pkgs.lib.getExe' pkgs.sops "sops";
        setSopsValueToEnvironmentVariable = key: secretsFile: ''
          export ${key}=$(${sops} -d --extract '["${key}"]' ${secretsFile})
        '';
      in ''
        export SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt

        ${setSopsValueToEnvironmentVariable "AWS_ACCESS_KEY_ID"
        "./secrets.json"}
        ${setSopsValueToEnvironmentVariable "AWS_SECRET_ACCESS_KEY"
        "./secrets.json"}

        export AWS_REGION="us-east-2"

        ${setSopsValueToEnvironmentVariable "OMNIBUS_PASSWORD" "./secrets.json"}
        ${setSopsValueToEnvironmentVariable "OPNSENSE_API_KEY" "./secrets.json"}
        ${setSopsValueToEnvironmentVariable "OPNSENSE_API_SECRET"
        "./secrets.json"}

        export TAILSCALE_AUTH_KEY=$(${sops} -d --extract '["tailscale_auth_key"]' ./modules/profiles/networking/tailscale/secrets.json)
      '';
    };
  };
}
