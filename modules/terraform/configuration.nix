{ ... }: {
  perSystem = { pkgs, config, ... }: {
    terraformConfiguration = pkgs.runCommand "config.tf.json" {
      unvalidatedTerraformConfiguration =
        inputs.terranix.lib.terranixConfiguration {
          inherit pkgs;
          modules = [ ];
        };
      nativeBuildInputs = [ config.packages.terraformWithPlugins ];
    } ''
      mkdir "$out"
      ln -s "$unvalidatedTerraformConfiguration" "$out/config.tf.json"
      terraform -chdir="$out" init -backend=false -compact-warnings
      terraform -chdir="$out" validate -compact-warnings
      rm -rf .terraform
    '';
  };
}
