{ self, pkgs }:
let
  runCodeAnalysis = name: command:
    pkgs.runCommand "tilde-${name}-check" { } ''
      cd ${self}
      mkdir $out
      ${command}
    '';
in {
  format = runCodeAnalysis "format" ''
    ${pkgs.nixfmt}/bin/nixfmt --check **/*.nix
  '';

  lint = runCodeAnalysis "lint" ''
    ${pkgs.statix}/bin/statix check .
  '';
}
