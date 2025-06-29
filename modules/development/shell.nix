{ self, inputs, ... }: {
  perSystem = { pkgs, lib, system, ... }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = let
        shellNames = [ "ansible" "deploy" "flake-root" "terraform" "treefmt" ];
      in map (shell: self.devShells.${system}.${shell}) shellNames;

      nativeBuildInputs = with pkgs; [
        cachix
        deadnix
        inputs.attic.packages.${system}.attic
        inputs.devenv.packages.${system}.default
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
        ${setSopsValueToEnvironmentVariable "OMNIBUS_PASSWORD" "./secrets.json"}

        export TAILSCALE_AUTH_KEY=$(${sops} -d --extract '["tailscale_auth_key"]' ./modules/profiles/networking/tailscale/secrets.json)
      '';
    };
  };
}
