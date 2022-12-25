final: prev: {
  # xteve = prev.callPackage ./xteve {
  #   buildGoModule = prev.buildGoModule.override { go = prev.go_1_17; };
  # };
  xteve = prev.callPackage ./xteve { };
}
