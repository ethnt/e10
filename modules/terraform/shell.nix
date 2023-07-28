{
  perSystem = { config, pkgs, ... }: {
    devenv.shells.terraform = { ... }: {
      languages.terraform.enable = true;
      packages = with pkgs; [
        terragrunt
        config.packages.terraform
        # (terraform.withPlugins (p: with p; [ dns tailscale ]))
      ];
    };
  };
}
