{ pkgs, extraModulesPath, inputs, lib, ... }:
let
  setSopsValueToEnvironmentVariable = var: key: ''
    export ${var}=$(${pkgs.sops}/bin/sops -d --extract '["${key}"]' ./secrets.yaml)
  '';
in {
  _file = toString ./.;

  devshell.startup.load_profiles = pkgs.lib.mkForce (pkgs.lib.noDepEntry ''
    _PATH=''${PATH}

    for file in "$DEVSHELL_DIR/etc/profile.d/"*.sh; do
      [[ -f "$file" ]] && source "$file"
    done

    ${setSopsValueToEnvironmentVariable "AWS_ACCESS_KEY_ID" "aws_access_key_id"}
    ${setSopsValueToEnvironmentVariable "AWS_SECRET_ACCESS_KEY"
    "aws_secret_access_key"}

    ${setSopsValueToEnvironmentVariable "PM_API_TOKEN_ID" "pm_api_token_id"}
    ${setSopsValueToEnvironmentVariable "PM_API_TOKEN_SECRET"
    "pm_api_token_secret"}

    export PATH=''${_PATH}
    unset _PATH
  '');

  commands = let addPackage = category: package: { inherit package category; };
  in [
    (addPackage "development" pkgs.nixUnstable)
    (addPackage "development" pkgs.cachix)

    (addPackage "code" pkgs.nixfmt)
    (addPackage "code" pkgs.statix)
    (addPackage "code" pkgs.editorconfig-checker)

    (addPackage "docs" pkgs.mdbook)

    (addPackage "deployment" inputs.deploy.packages.${pkgs.system}.deploy-rs)

    {
      category = "deployment";
      package = pkgs.writeShellScriptBin "tf" ''
        ${pkgs.terraform}/bin/terraform -chdir=deploy $@
      '';
      help = "Wrapper for Terraform";
    }

    {
      category = "management";
      package = let
        sshConfig = pkgs.writeTextFile {
          name = "ssh_config";
          text = ''
            Host gateway
              Hostname gateway.e10.network

            Host monitor
              Hostname monitor.e10.network

            Host matrix
              Hostname 192.168.1.202

            Host htpc
              Hostname 192.168.1.203

            Host *
              User root
              IdentityFile keys/id_rsa
          '';
        };
      in pkgs.writeShellScriptBin "e10-ssh" ''
        ssh -F ${sshConfig} $@
      '';
      help = "Wrapper for SSH";
    }
  ];
}
