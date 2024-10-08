{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ attic-client cachix ];

  nix.settings = {
    substituters = [
      "https://cache.e10.camp/e10"
      "https://nix-community.cachix.org"
      "https://e10.cachix.org"
      "https://numtide.cachix.org"
    ];

    trusted-public-keys = [
      "e10:h64l3MobkrdOGab0Xaambo3ROC/w05Yi70oJ8U8ZEfQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "e10.cachix.org-1:/++Tmo/ghEqnLwsQJdXn04c262agRCK5PaPYz8NcVfo="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };
}
