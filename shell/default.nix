{ self, inputs, ... }: {
  modules = with inputs; [ ];
  exportedModules = [ ./e10.nix ];
}

