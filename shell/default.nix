{ self, inputs, ... }: {
  modules = with inputs; [ ];
  exportedModules = [ ./camp.nix ];
}

