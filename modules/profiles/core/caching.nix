{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ cachix ];

  nix.settings = {
    substituters = [ "https://e10.cachix.org" "https://numtide.cachix.org" ];

    trusted-public-keys = [
      "e10.cachix.org-1:/++Tmo/ghEqnLwsQJdXn04c262agRCK5PaPYz8NcVfo="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };
}
