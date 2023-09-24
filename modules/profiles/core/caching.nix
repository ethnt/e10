{ inputs, ... }: {
  environment.systemPackages = [ inputs.attic.packages.x86_64-linux.attic ];

  nix.settings = {
    substituters = [
      "https://e10.cachix.org"
      "https://numtide.cachix.org"
      "https://attic.e10.camp"
    ];
    trusted-public-keys = [
      "e10.cachix.org-1:/++Tmo/ghEqnLwsQJdXn04c262agRCK5PaPYz8NcVfo="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "attic.e10.camp-e10:GRxL2EezM+0vZXpa9fePFqTM1qstxiV56tc5K3eDugk="
    ];
  };
}
