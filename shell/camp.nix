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
        ${pkgs.terraform}/bin/terraform -chdir=deploy $@ &&
          ${pkgs.terraform}/bin/terraform -chdir=deploy show -json > state.json
      '';
      help = "Wrapper for Terraform";
    }
  ];
}
