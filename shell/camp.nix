{ pkgs, inputs, ... }:
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
    export PATH=''${_PATH}
    unset _PATH

    ${setSopsValueToEnvironmentVariable "AWS_ACCESS_KEY_ID" "aws_access_key_id"}
    ${setSopsValueToEnvironmentVariable "AWS_SECRET_ACCESS_KEY"
    "aws_secret_access_key"}

    export SOPS_AGE_KEY_DIR="$HOME/.config/sops/age"
  '');

  commands = let addPackage = category: package: { inherit package category; };
  in [
    (addPackage "runtime" pkgs.nixUnstable)
    (addPackage "runtime" pkgs.cachix)

    {
      package = inputs.sops-nix.defaultPackage.${pkgs.system};
      category = "development";
      help = "SOPS tool for initializing GPG keys";
    }

    (addPackage "deployment" pkgs.terraform)

    {
      package = (pkgs.writeShellScriptBin "tf" ''
        ${pkgs.terraform}/bin/terraform -chdir=deploy/ $@ &&
          ${pkgs.terraform}/bin/terraform -chdir=deploy/ show -json > state.json
      '');
      category = "deployment";
      help = "Wrapper for Terraform";
    }

    (addPackage "code" pkgs.nixfmt)
    (addPackage "code" pkgs.statix)
  ];
}
