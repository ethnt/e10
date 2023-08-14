{ inputs, self, ... }:
{
  # flake.checks =
  #   builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy)
  #   inputs.deploy-rs.lib;
}
